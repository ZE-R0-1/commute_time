import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  
  // 서클 관련 (검색 반경 표시)
  final RxList<Circle> circles = <Circle>[].obs;
  
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
    
    // 지하철역 카테고리 선택 시 REST API로 지하철역 검색
    if (category == 0) {
      _searchSubwayStationsWithRestAPI();
    }
    
    // 버스정류장 카테고리 선택 시 버스정류장 데이터 출력
    if (category == 1) {
      print('🚌 버스정류장 카테고리 선택됨');
      print('📋 사용 가능한 버스정류장 데이터:');
      
      List<LocationInfo> busStops = [
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
      
      for (int i = 0; i < busStops.length; i++) {
        LocationInfo stop = busStops[i];
        print('${i + 1}. ${stop.name}');
        print('   - 코드: ${stop.code}');
        print('   - 노선: ${stop.lineInfo}');
        print('   - 위치: (${stop.latitude}, ${stop.longitude})');
        print('');
      }
    }
    
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }

  // 실제 카카오 API로 지하철역 검색
  Future<void> _searchSubwayStations() async {
    if (mapController == null) {
      print('❌ 맵 컨트롤러가 초기화되지 않았습니다.');
      return;
    }

    try {
      print('🚇 지하철역 카테고리 선택됨 - 카카오 API 검색 시작');
      
      // 현재 맵의 중심 좌표 가져오기
      final center = await mapController!.getCenter();
      print('📍 현재 맵 중심 좌표: (${center.latitude}, ${center.longitude})');

      // 카테고리 검색 요청 생성 (SW8 = 지하철역)
      final request = CategorySearchRequest(
        categoryGroupCode: CategoryType.sw8, // 지하철역
        y: center.latitude,
        x: center.longitude,
        radius: 2000, // 2km 반경
        sort: SortBy.distance,
        page: 1,
        size: 15, // 최대 15개
        useMapCenter: true,
        useMapBounds: true,
      );

      print('🔍 검색 요청: ${request.toString()}');
      print('⏳ API 호출 시작...');

      // API 호출 with timeout
      final result = await mapController!.categorySearch(request).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ API 호출 타임아웃 (10초)');
          throw TimeoutException('카테고리 검색 타임아웃', const Duration(seconds: 10));
        },
      );
      
      print('✅ 검색 완료! 총 ${result.list.length}개의 지하철역 발견');
      
      if (result.list.isEmpty) {
        print('📭 검색 결과가 없습니다. 다른 카테고리로 테스트해보겠습니다.');
        await _testOtherCategories();
        return;
      }
      
      print('📋 지하철역 목록:');
      
      // 검색 결과 출력
      for (int i = 0; i < result.list.length; i++) {
        final station = result.list[i];
        print('${i + 1}. ${station.placeName}');
        print('   - 주소: ${station.addressName}');
        print('   - 도로명주소: ${station.roadAddressName}');
        print('   - 카테고리: ${station.categoryName}');
        print('   - 거리: ${station.distance}m');
        print('   - 좌표: (${station.y}, ${station.x})');
        print('   - ID: ${station.id}');
        if (station.phone?.isNotEmpty == true) {
          print('   - 전화번호: ${station.phone}');
        }
        print('');
      }

    } on TimeoutException catch (e) {
      print('❌ API 호출 타임아웃: $e');
      print('🔄 대안으로 다른 카테고리 테스트를 시도합니다.');
      await _testOtherCategories();
    } catch (e, stackTrace) {
      print('❌ 지하철역 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      print('🔄 대안으로 다른 카테고리 테스트를 시도합니다.');
      await _testOtherCategories();
    }
  }

  // REST API로 지하철역 검색 (카카오맵 플러그인 대신)
  Future<void> _searchSubwayStationsWithRestAPI() async {
    if (mapController == null) {
      print('❌ 맵 컨트롤러가 초기화되지 않았습니다.');
      return;
    }

    try {
      print('🚇 지하철역 카테고리 선택됨 - REST API 검색 시작');
      
      // 현재 맵의 중심 좌표 가져오기
      final center = await mapController!.getCenter();
      print('📍 현재 맵 중심 좌표: (${center.latitude}, ${center.longitude})');

      // 200m 반경 원 표시 (희미하게)
      await _showSearchRadius(center);

      // 카카오 REST API로 카테고리 검색
      final apiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 카카오 REST API 키가 없습니다.');
        return;
      }

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/category.json'
        '?category_group_code=SW8'
        '&x=${center.longitude}'
        '&y=${center.latitude}'
        '&radius=200'
        '&sort=distance'
        '&page=1'
        '&size=15'
      );

      print('🔍 API 요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 검색 완료! 총 ${documents.length}개의 지하철역 발견');
        print('📋 지하철역 목록:');
        
        for (int i = 0; i < documents.length; i++) {
          final station = documents[i];
          print('${i + 1}. ${station['place_name']}');
          print('   - 주소: ${station['address_name']}');
          print('   - 도로명주소: ${station['road_address_name']}');
          print('   - 카테고리: ${station['category_name']}');
          print('   - 거리: ${station['distance']}m');
          print('   - 좌표: (${station['y']}, ${station['x']})');
          print('   - ID: ${station['id']}');
          if (station['phone']?.toString().isNotEmpty == true) {
            print('   - 전화번호: ${station['phone']}');
          }
          print('');
        }
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        print('📄 응답 내용: ${response.body}');
      }

    } catch (e, stackTrace) {
      print('❌ REST API 지하철역 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
    }
  }

  // 검색 반경 원 표시 (희미하게)
  Future<void> _showSearchRadius(LatLng center) async {
    if (mapController == null) return;

    try {
      // 기존 원 제거
      circles.clear();
      
      // 200m 반경 원 생성 (희미한 파란색)
      final searchRadiusCircle = Circle(
        circleId: 'search_radius',
        center: center,
        radius: 200, // 200m
        strokeWidth: 1,
        strokeColor: Colors.blue.withValues(alpha: 0.3), // 희미한 파란색 테두리
        strokeOpacity: 0.3,
        fillColor: Colors.blue.withValues(alpha: 0.1), // 매우 희미한 파란색 채우기
        fillOpacity: 0.1,
        zIndex: 1, // 다른 요소들보다 뒤에 표시
      );

      circles.add(searchRadiusCircle);
      
      // 지도에 원 추가
      await mapController!.addCircle(circles: circles);
      
      print('🔵 200m 검색 반경 원 표시 완료');
      
    } catch (e) {
      print('❌ 검색 반경 원 표시 실패: $e');
    }
  }

  // 다른 카테고리로 테스트 (은행, 편의점 등)
  Future<void> _testOtherCategories() async {
    if (mapController == null) return;

    final testCategories = [
      {'type': CategoryType.bk9, 'name': '은행'},
      {'type': CategoryType.cs2, 'name': '편의점'},
      {'type': CategoryType.mt1, 'name': '대형마트'},
    ];

    for (final category in testCategories) {
      try {
        print('🧪 ${category['name']} 카테고리 테스트 중...');
        
        final center = await mapController!.getCenter();
        final request = CategorySearchRequest(
          categoryGroupCode: category['type'] as CategoryType,
          y: center.latitude,
          x: center.longitude,
          radius: 2000,
          sort: SortBy.distance,
          page: 1,
          size: 5,
          useMapCenter: true,
          useMapBounds: true,
        );

        final result = await mapController!.categorySearch(request).timeout(
          const Duration(seconds: 5),
        );

        print('✅ ${category['name']} 검색 결과: ${result.list.length}개');
        
        if (result.list.isNotEmpty) {
          for (int i = 0; i < result.list.length && i < 3; i++) {
            final place = result.list[i];
            print('  ${i + 1}. ${place.placeName} (${place.distance}m)');
          }
          break; // 성공하면 테스트 중단
        }
        
      } catch (e) {
        print('❌ ${category['name']} 테스트 실패: $e');
        continue;
      }
      
      // 카테고리 간 딜레이
      await Future.delayed(const Duration(milliseconds: 500));
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