import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../../app/services/seoul_subway_service.dart';
import '../../app/services/location_service.dart';
import '../onboarding/onboarding_controller.dart';

class RouteDepartureController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController subwaySearchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  
  // 기존 주소 검색 (버스정류장용)
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;
  Timer? _debounceTimer;
  
  // 지하철역 검색
  final RxList<SeoulSubwayStation> subwaySearchResults = <SeoulSubwayStation>[].obs;
  final RxBool isSubwaySearching = false.obs;
  Timer? _subwayDebounceTimer;
  
  final RxString savedHomeAddress = ''.obs;
  final RxList<LocationData> recentLocations = <LocationData>[].obs;
  final Rx<LocationData?> selectedLocation = Rx<LocationData?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    _loadRecentLocations();
    
    // 디버깅: API 키 상태 확인
    print('🚇 RouteDepartureController 초기화');
    print('🔑 서울시 지하철역 API 키 상태: ${SeoulSubwayService.hasValidApiKey}');
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    _subwayDebounceTimer?.cancel();
    searchController.dispose();
    subwaySearchController.dispose();
    super.onClose();
  }
  
  void _loadSavedData() {
    final homeAddress = _storage.read('home_address') ?? '';
    savedHomeAddress.value = homeAddress;
  }
  
  void _loadRecentLocations() {
    final recentData = _storage.read('recent_departure_locations') as List?;
    if (recentData != null) {
      recentLocations.value = recentData.map((item) => LocationData(
        address: item['address'] ?? '',
        placeName: item['placeName'],
        latitude: item['latitude']?.toDouble(),
        longitude: item['longitude']?.toDouble(),
        lastUsed: DateTime.parse(item['lastUsed'] ?? DateTime.now().toIso8601String()),
      )).toList();
      
      // 최근 사용 순으로 정렬
      recentLocations.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    }
  }
  
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.length <= 1) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.length > 1) {
        await _searchAddress(query);
      }
    });
  }
  
  Future<void> _searchAddress(String query) async {
    try {
      isSearching.value = true;
      
      // OnboardingController의 searchAddress 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      final results = await onboardingController.searchAddress(query);
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트 (10개로 증가)
      if (searchController.text.trim() == query) {
        searchResults.value = results.take(10).toList();
      }
      
    } catch (e) {
      print('역/정류장 검색 오류: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }
  
  void selectLocation(String selectedAddress) async {
    try {
      // OnboardingController의 selectAddressFromSearch 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      await onboardingController.selectAddressFromSearch(
        searchController.text.trim(),
        selectedAddress,
        true, // isHome - 일단 true로 설정
      );
      
      // 선택된 주소로 LocationData 생성
      final locationData = LocationData(
        address: selectedAddress,
        placeName: null,
        latitude: null,
        longitude: null,
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    } catch (e) {
      print('위치 선택 오류: $e');
    }
  }
  
  void useCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        final locationData = LocationData(
          address: location.address,
          placeName: '현재 위치',
          latitude: location.latitude,
          longitude: location.longitude,
          lastUsed: DateTime.now(),
        );
        
        _saveLocationAndReturn(locationData);
      } else {
        Get.snackbar(
          '위치 오류',
          '현재 위치를 가져올 수 없습니다.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        '위치 오류',
        '현재 위치를 가져올 수 없습니다.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  void useSavedHomeAddress() {
    if (savedHomeAddress.value.isNotEmpty) {
      final locationData = LocationData(
        address: savedHomeAddress.value,
        placeName: '집',
        latitude: _storage.read('home_latitude')?.toDouble(),
        longitude: _storage.read('home_longitude')?.toDouble(),
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    }
  }
  
  void selectFromMap() async {
    final result = await Get.toNamed('/map-selection', arguments: {
      'type': 'departure',
      'title': '출발지 선택',
    });
    
    if (result != null) {
      final locationData = LocationData(
        address: result['address'] ?? '',
        placeName: result['placeName'] ?? '지도에서 선택',
        latitude: result['latitude']?.toDouble(),
        longitude: result['longitude']?.toDouble(),
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    }
  }
  
  void selectRecentLocation(LocationData location) {
    final updatedLocation = LocationData(
      address: location.address,
      placeName: location.placeName,
      latitude: location.latitude,
      longitude: location.longitude,
      lastUsed: DateTime.now(),
    );
    
    _saveLocationAndReturn(updatedLocation);
  }
  
  void _saveLocationAndReturn(LocationData location) {
    selectedLocation.value = location;
    
    // 최근 위치에 추가
    _addToRecentLocations(location);
    
    // 결과 반환
    Get.back(result: location);
  }
  
  void _addToRecentLocations(LocationData location) {
    // 중복 제거
    recentLocations.removeWhere((item) => item.address == location.address);
    
    // 새 위치를 맨 앞에 추가
    recentLocations.insert(0, location);
    
    // 최대 10개까지만 유지
    if (recentLocations.length > 10) {
      recentLocations.removeRange(10, recentLocations.length);
    }
    
    // 저장
    _saveRecentLocations();
  }
  
  void _saveRecentLocations() {
    final recentData = recentLocations.map((location) => {
      'address': location.address,
      'placeName': location.placeName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lastUsed': location.lastUsed.toIso8601String(),
    }).toList();
    
    _storage.write('recent_departure_locations', recentData);
  }
  
  // 지하철역 검색 관련 메서드
  void onSubwaySearchChanged(String query) {
    _subwayDebounceTimer?.cancel();
    
    if (query.isEmpty) {
      print('🧹 검색어 비어있음 - 결과 초기화');
      subwaySearchResults.clear();
      isSubwaySearching.value = false;
      return;
    }
    
    print('⏱️ 검색 대기: $query');
    
    _subwayDebounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        await _searchSubwayStations(query);
      }
    });
  }
  
  Future<void> _searchSubwayStations(String query) async {
    try {
      isSubwaySearching.value = true;
      
      print('🚇 지하철역 검색 시작: $query');
      print('🔑 API 키 상태: ${SeoulSubwayService.hasValidApiKey}');
      
      final results = await SeoulSubwayService.searchSubwayStations(query);
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트 (10개로 증가)
      if (subwaySearchController.text.trim() == query) {
        final limitedResults = results.take(10).toList();
        subwaySearchResults.value = limitedResults;
        
        print('✅ 검색 결과 업데이트: 전체 ${results.length}개 → 표시 ${limitedResults.length}개');
        
        // 디버깅: UI에 표시될 역 데이터 출력
        for (int i = 0; i < limitedResults.length; i++) {
          final station = limitedResults[i];
          print('  UI ${i + 1}. 역명: ${station.displayName}, 호선: ${station.displayAddress}');
        }
      }
      
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      subwaySearchResults.clear();
    } finally {
      isSubwaySearching.value = false;
    }
  }
  
  void selectSubwayStation(SeoulSubwayStation station) {
    final locationData = LocationData(
      address: station.displayAddress,
      placeName: station.displayName,
      latitude: null, // 서울시 API는 좌표 정보 없음
      longitude: null,
      lastUsed: DateTime.now(),
    );
    
    _saveLocationAndReturn(locationData);
  }
  
  // 버스정류장 관련 메서드
  void searchByAddress() {
    // 주소 검색 모드 활성화
    Get.dialog(
      _AddressSearchDialog(),
      barrierDismissible: true,
    );
  }
}

/// 주소 검색 다이얼로그
class _AddressSearchDialog extends StatefulWidget {
  @override
  State<_AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<_AddressSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<String> _searchResults = <String>[].obs;
  final RxBool _isSearching = false.obs;
  Timer? _debounceTimer;
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.length <= 1) {
      _searchResults.clear();
      _isSearching.value = false;
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.length > 1) {
        await _searchAddress(query);
      }
    });
  }
  
  Future<void> _searchAddress(String query) async {
    try {
      _isSearching.value = true;
      
      // OnboardingController의 searchAddress 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      final results = await onboardingController.searchAddress(query);
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트
      if (_searchController.text.trim() == query) {
        _searchResults.value = results.take(10).toList();
      }
      
    } catch (e) {
      print('주소 검색 오류: $e');
      _searchResults.clear();
    } finally {
      _isSearching.value = false;
    }
  }
  
  void _selectAddress(String selectedAddress) async {
    try {
      final controller = Get.find<RouteDepartureController>();
      
      // OnboardingController의 selectAddressFromSearch 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      await onboardingController.selectAddressFromSearch(
        _searchController.text.trim(),
        selectedAddress,
        false, // isHome = false (버스정류장이므로)
      );
      
      // 선택된 주소로 LocationData 생성
      final locationData = LocationData(
        address: selectedAddress,
        placeName: '버스정류장',
        latitude: null,
        longitude: null,
        lastUsed: DateTime.now(),
      );
      
      // 다이얼로그 닫기
      Get.back();
      
      // 선택된 위치 저장하고 이전 화면으로 돌아가기
      controller._saveLocationAndReturn(locationData);
      
    } catch (e) {
      print('주소 선택 오류: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(
                  Icons.search,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '주소로 버스정류장 검색',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 검색 입력 필드
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '주소나 건물명을 입력하세요',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                autofocus: true,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 안내 텍스트
            Text(
              '주소나 건물명을 입력하면 근처 버스정류장을 찾을 수 있습니다.',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 검색 결과
            Expanded(
              child: Obx(() {
                if (_isSearching.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (_searchResults.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '주소나 건물명을 검색해보세요',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final address = _searchResults[index];
                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Get.theme.primaryColor,
                      ),
                      title: Text(
                        address,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () => _selectAddress(address),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationData {
  final String address;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final DateTime lastUsed;

  LocationData({
    required this.address,
    this.placeName,
    this.latitude,
    this.longitude,
    required this.lastUsed,
  });
}