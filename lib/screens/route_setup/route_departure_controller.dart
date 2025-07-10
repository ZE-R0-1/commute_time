import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../../app/services/kakao_subway_service.dart';
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
  final RxList<SubwayStation> subwaySearchResults = <SubwayStation>[].obs;
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
    print('🔑 카카오 API 키 상태: ${KakaoSubwayService.hasValidApiKey}');
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
  
  void selectFromMap() {
    Get.toNamed('/map-selection', arguments: {
      'type': 'departure',
      'title': '출발지 선택',
    });
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
      print('🔑 API 키 상태: ${KakaoSubwayService.hasValidApiKey}');
      
      final results = await KakaoSubwayService.searchSubwayStations(query);
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트 (10개로 증가)
      if (subwaySearchController.text.trim() == query) {
        final limitedResults = results.take(10).toList();
        subwaySearchResults.value = limitedResults;
        
        print('✅ 검색 결과 업데이트: 전체 ${results.length}개 → 표시 ${limitedResults.length}개');
        
        // 디버깅: UI에 표시될 역 데이터 출력
        for (int i = 0; i < limitedResults.length; i++) {
          final station = limitedResults[i];
          print('  UI ${i + 1}. 역명: ${station.stationName}, 주소: ${station.displayAddress}');
        }
      }
      
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      subwaySearchResults.clear();
    } finally {
      isSubwaySearching.value = false;
    }
  }
  
  void selectSubwayStation(SubwayStation station) {
    final locationData = LocationData(
      address: station.displayAddress,
      placeName: station.stationName,
      latitude: station.latitude,
      longitude: station.longitude,
      lastUsed: DateTime.now(),
    );
    
    _saveLocationAndReturn(locationData);
  }
  
  // 버스정류장 관련 메서드
  void searchByAddress() {
    // 주소 검색 화면으로 이동하거나 주소 검색 모드 활성화
    Get.snackbar(
      '주소 검색',
      '주소로 버스정류장을 검색합니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
    // TODO: 주소 검색 화면 구현
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