import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../../app/services/seoul_subway_service.dart';
import '../onboarding/onboarding_controller.dart';

class RouteArrivalController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController subwaySearchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  
  // 지하철역 검색
  final RxList<SeoulSubwayStation> subwaySearchResults = <SeoulSubwayStation>[].obs;
  final RxBool isSubwaySearching = false.obs;
  Timer? _subwayDebounceTimer;
  
  final RxString savedWorkAddress = ''.obs;
  final Rx<LocationData?> selectedLocation = Rx<LocationData?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    
    // 디버깅: API 키 상태 확인
    print('🚇 RouteArrivalController 초기화');
    print('🔑 서울시 지하철역 API 키 상태: ${SeoulSubwayService.hasValidApiKey}');
  }
  
  @override
  void onClose() {
    _subwayDebounceTimer?.cancel();
    searchController.dispose();
    subwaySearchController.dispose();
    super.onClose();
  }
  
  void _loadSavedData() {
    final workAddress = _storage.read('work_address') ?? '';
    savedWorkAddress.value = workAddress;
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
  
  void useSavedWorkAddress() {
    if (savedWorkAddress.value.isNotEmpty) {
      final locationData = LocationData(
        address: savedWorkAddress.value,
        placeName: '회사',
        latitude: _storage.read('work_latitude')?.toDouble(),
        longitude: _storage.read('work_longitude')?.toDouble(),
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    }
  }
  
  void selectFromMap() async {
    final result = await Get.toNamed('/map-selection', arguments: {
      'type': 'arrival',
      'title': '도착지 선택 (버스정류장)',
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
  
  void _saveLocationAndReturn(LocationData location) {
    selectedLocation.value = location;
    
    // 결과 반환
    Get.back(result: location);
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