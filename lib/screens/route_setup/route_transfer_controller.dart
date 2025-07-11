import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../../app/services/seoul_subway_service.dart';
import '../onboarding/onboarding_controller.dart';

class RouteTransferController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController subwaySearchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  
  // 지하철역 검색
  final RxList<SeoulSubwayStation> subwaySearchResults = <SeoulSubwayStation>[].obs;
  final RxBool isSubwaySearching = false.obs;
  Timer? _subwayDebounceTimer;
  
  final RxList<TransferLocation> transferLocations = <TransferLocation>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // 디버깅: API 키 상태 확인
    print('🚇 RouteTransferController 초기화');
    print('🔑 서울시 지하철역 API 키 상태: ${SeoulSubwayService.hasValidApiKey}');
  }
  
  @override
  void onReady() {
    super.onReady();
    // 지도 선택 결과 처리
    _handleMapSelectionResult();
  }
  
  @override
  void onClose() {
    _subwayDebounceTimer?.cancel();
    searchController.dispose();
    subwaySearchController.dispose();
    super.onClose();
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
    final transferLocation = TransferLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: station.displayAddress,
      placeName: station.displayName,
      latitude: null, // 서울시 API는 좌표 정보 없음
      longitude: null,
      lastUsed: DateTime.now(),
    );
    
    transferLocations.add(transferLocation);
    
    // 검색 결과 초기화
    subwaySearchResults.clear();
    subwaySearchController.clear();
    
    Get.snackbar(
      '환승지 추가',
      '${station.displayName}이 추가되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  void selectFromMap() async {
    final result = await Get.toNamed('/map-selection', arguments: {
      'type': 'transfer',
      'title': '환승지 선택 (버스정류장)',
    });
    
    if (result != null) {
      _handleMapSelectionResult(result);
    }
  }
  
  void removeTransferLocation(TransferLocation location) {
    transferLocations.remove(location);
    
    Get.snackbar(
      '환승지 제거',
      '${location.placeName ?? location.address}가 제거되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  void reorderTransferLocations(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final item = transferLocations.removeAt(oldIndex);
    transferLocations.insert(newIndex, item);
    
    Get.snackbar(
      '순서 변경',
      '환승지 순서가 변경되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }
  
  void _handleMapSelectionResult([dynamic result]) {
    if (result == null) return;
    
    try {
      final Map<String, dynamic> mapResult = result as Map<String, dynamic>;
      
      final transferLocation = TransferLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        address: mapResult['address'] ?? '',
        placeName: mapResult['placeName'],
        latitude: mapResult['latitude']?.toDouble(),
        longitude: mapResult['longitude']?.toDouble(),
        lastUsed: DateTime.now(),
      );
      
      // 중복 체크
      if (!transferLocations.any((location) => 
          location.address == transferLocation.address ||
          (location.latitude != null && location.longitude != null &&
           transferLocation.latitude != null && transferLocation.longitude != null &&
           (location.latitude! - transferLocation.latitude!).abs() < 0.001 &&
           (location.longitude! - transferLocation.longitude!).abs() < 0.001))) {
        
        transferLocations.add(transferLocation);
        
        Get.snackbar(
          '환승지 추가',
          '${transferLocation.placeName ?? transferLocation.address}가 추가되었습니다.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '중복 위치',
          '이미 선택된 환승지입니다.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
      
    } catch (e) {
      print('지도 선택 결과 처리 오류: $e');
    }
  }
  
  bool isLocationSelected(String selectedAddress) {
    return transferLocations.any((location) => location.address == selectedAddress);
  }
  
  bool isLocationSelectedByAddress(String address) {
    return transferLocations.any((location) => location.address == address);
  }
}

class TransferLocation {
  final String id;
  final String address;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final DateTime lastUsed;

  TransferLocation({
    required this.id,
    required this.address,
    this.placeName,
    this.latitude,
    this.longitude,
    required this.lastUsed,
  });
}