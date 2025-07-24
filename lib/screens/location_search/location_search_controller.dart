import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

class LocationSearchController extends GetxController {
  // 카카오맵 관련
  KakaoMapController? mapController;
  
  // 검색어
  final RxString searchQuery = ''.obs;
  
  // 선택된 카테고리 (0: 지하철, 1: 버스)
  final RxInt selectedCategory = 0.obs;
  
  // 검색 결과
  final RxList<LocationInfo> searchResults = <LocationInfo>[].obs;
  
  // 로딩 상태
  final RxBool isLoading = false.obs;
  
  // 현재 모드 (departure, transfer, arrival)
  final RxString mode = ''.obs;
  
  // 화면 타이틀
  final RxString title = ''.obs;
  
  // 마커 관련
  final RxList<Marker> markers = <Marker>[].obs;
  
  // 디바운스 타이머
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    
    // arguments에서 모드와 타이틀 받기
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    mode.value = args['mode'] ?? 'departure';
    title.value = args['title'] ?? '위치 검색';
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    // 맵 컨트롤러 정리
    mapController = null;
    markers.clear();
    super.onClose();
  }

  void onMapCreated(KakaoMapController controller) {
    mapController = controller;
    print('🗺️ 카카오맵 초기화 완료');
    print('🔍 지도 컨트롤러 상태: 정상');
  }

  // 검색 실행
  void performSearch(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    searchQuery.value = query;
    isLoading.value = true;

    // 실제 구현에서는 API 호출
    Future.delayed(const Duration(milliseconds: 500), () {
      List<LocationInfo> allResults = [
        // 지하철역 데이터
        LocationInfo(
          name: '강남역',
          type: 'subway',
          lineInfo: '2호선, 신분당선',
          code: '222',
          latitude: 37.4980,
          longitude: 127.0276,
        ),
        LocationInfo(
          name: '역삼역',
          type: 'subway',
          lineInfo: '2호선',
          code: '223',
          latitude: 37.5002,
          longitude: 127.0364,
        ),
        LocationInfo(
          name: '선릉역',
          type: 'subway',
          lineInfo: '2호선, 분당선',
          code: '224',
          latitude: 37.5045,
          longitude: 127.0487,
        ),
        LocationInfo(
          name: '서초역',
          type: 'subway',
          lineInfo: '2호선',
          code: '225',
          latitude: 37.4837,
          longitude: 127.0104,
        ),
        
        // 버스정류장 데이터
        LocationInfo(
          name: '강남역.강남구청',
          type: 'bus',
          lineInfo: '간선 146, 472',
          code: '23-180',
          latitude: 37.4979,
          longitude: 127.0265,
        ),
        LocationInfo(
          name: '역삼역.포스코센터',
          type: 'bus',
          lineInfo: '지선 3412, 4319',
          code: '23-181',
          latitude: 37.5001,
          longitude: 127.0355,
        ),
        LocationInfo(
          name: '선릉역.엘타워',
          type: 'bus',
          lineInfo: '간선 240, 341',
          code: '23-182',
          latitude: 37.5046,
          longitude: 127.0478,
        ),
      ];

      // 카테고리에 따른 필터링
      List<LocationInfo> filteredResults;
      if (selectedCategory.value == 0) {
        // 지하철만
        filteredResults = allResults
            .where((station) => station.type == 'subway' && station.name.contains(query))
            .toList();
      } else {
        // 버스만
        filteredResults = allResults
            .where((station) => station.type == 'bus' && station.name.contains(query))
            .toList();
      }

      searchResults.value = filteredResults;
      isLoading.value = false;
    });
  }


  // 카테고리 변경
  void changeCategory(int category) {
    selectedCategory.value = category;
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }

  // 위치 선택
  void selectLocation(LocationInfo location) {
    // 선택된 위치 정보를 이전 화면으로 반환
    Get.back(result: {
      'name': location.name,
      'type': location.type,
      'lineInfo': location.lineInfo,
      'code': location.code,
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
  }
}

// LocationInfo 클래스 정의
class LocationInfo {
  final String name;
  final String type; // 'subway' 또는 'bus'
  final String lineInfo;
  final String code;
  final double latitude;
  final double longitude;

  LocationInfo({
    required this.name,
    required this.type,
    required this.lineInfo,
    required this.code,
    required this.latitude,
    required this.longitude,
  });
}