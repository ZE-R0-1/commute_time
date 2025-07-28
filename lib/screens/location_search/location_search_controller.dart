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
  
  // 주소검색 결과
  final RxList<AddressInfo> addressSearchResults = <AddressInfo>[].obs;
  
  // 로딩 상태
  final RxBool isLoading = false.obs;
  
  // 검색 결과 표시 여부
  final RxBool showSearchResults = false.obs;
  
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

  // 주소검색 실행
  void performAddressSearch(String query) {
    if (query.isEmpty) {
      addressSearchResults.clear();
      showSearchResults.value = false;
      return;
    }

    searchQuery.value = query;
    isLoading.value = true;
    showSearchResults.value = true;

    // 디바운스 타이머 설정
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchAddressWithAPI(query);
    });
  }

  // 카카오 주소검색 API 호출
  Future<void> _searchAddressWithAPI(String query) async {
    print('🔍 주소검색 API 호출 시작 - 쿼리: "$query"');
    
    try {
      final apiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      print('🔑 API 키 확인: ${apiKey.isNotEmpty ? "존재함 (${apiKey.substring(0, 5)}...)" : "없음"}');
      
      if (apiKey.isEmpty) {
        print('❌ 카카오 REST API 키가 없습니다.');
        addressSearchResults.clear();
        return;
      }

      // 키워드 검색과 주소 검색을 모두 시도
      await _performKeywordSearch(query, apiKey);
      
    } catch (e, stackTrace) {
      print('❌ 주소검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      addressSearchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // 키워드 검색 수행
  Future<void> _performKeywordSearch(String query, String apiKey) async {
    try {
      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=${Uri.encodeComponent(query)}'
        '&page=1'
        '&size=10'
      );

      print('🔍 키워드 검색 API 요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 키워드 검색 응답 상태: ${response.statusCode}');
      print('📄 응답 내용 (첫 500자): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 키워드 검색 완료! 총 ${documents.length}개의 결과 발견');
        
        List<AddressInfo> results = [];
        for (int i = 0; i < documents.length; i++) {
          final doc = documents[i];
          final lat = double.parse(doc['y'].toString());
          final lng = double.parse(doc['x'].toString());
          
          results.add(AddressInfo(
            placeName: doc['place_name'] ?? '',
            addressName: doc['address_name'] ?? '',
            roadAddressName: doc['road_address_name'] ?? '',
            latitude: lat,
            longitude: lng,
          ));
          
          print('${i + 1}. ${doc['place_name'] ?? 'N/A'}');
          print('   - 주소: ${doc['address_name'] ?? 'N/A'}');
          print('   - 도로명주소: ${doc['road_address_name'] ?? 'N/A'}');
          print('   - 카테고리: ${doc['category_name'] ?? 'N/A'}');
          print('   - 좌표: ($lat, $lng)');
          print('');
        }
        
        print('🔄 결과를 UI에 업데이트 중...');
        addressSearchResults.value = results;
        print('✅ UI 업데이트 완료! 결과 개수: ${addressSearchResults.length}');
        
      } else {
        print('❌ 키워드 검색 API 호출 실패: ${response.statusCode}');
        print('📄 응답 내용: ${response.body}');
        addressSearchResults.clear();
      }

    } catch (e, stackTrace) {
      print('❌ 키워드 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      addressSearchResults.clear();
    }
  }

  // 주소 선택
  void selectAddress(AddressInfo address) async {
    if (mapController == null) return;
    
    print('📍 주소 선택됨: ${address.placeName}');
    print('🗺️ 지도 중심을 (${address.latitude}, ${address.longitude})로 이동');
    
    // 선택된 주소로 지도 중심 이동
    await mapController!.setCenter(LatLng(address.latitude, address.longitude));
    
    // 검색 결과 숨기기
    showSearchResults.value = false;
    addressSearchResults.clear();
    
    print('✅ 지도 이동 완료 및 검색 결과 숨김');
    
    // 화면 종료하지 않고 여기서 끝 (사용자가 계속 지도를 사용할 수 있음)
  }

  // 검색 실행 (기존 로직 - 현재는 사용하지 않음)
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
    
    // 버스정류장 카테고리 선택 시 REST API로 버스정류장 검색
    if (category == 1) {
      _searchBusStopsWithRestAPI();
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
        
        // 기존 마커 제거
        markers.clear();
        await mapController!.clearMarker();
        
        // 검색 결과를 마커로 표시
        for (int i = 0; i < documents.length; i++) {
          final station = documents[i];
          final lat = double.parse(station['y'].toString());
          final lng = double.parse(station['x'].toString());
          
          // 마커 생성
          final marker = Marker(
            markerId: 'subway_${station['id']}',
            latLng: LatLng(lat, lng),
            width: 30,
            height: 35,
            offsetX: 15,
            offsetY: 35,
          );
          
          markers.add(marker);
          
          print('${i + 1}. ${station['place_name']}');
          print('   - 주소: ${station['address_name']}');
          print('   - 거리: ${station['distance']}m');
          print('   - 좌표: (${lat}, ${lng})');
          print('');
        }
        
        // 지도에 마커 추가
        if (markers.isNotEmpty) {
          await mapController!.addMarker(markers: markers);
          print('🗺️ ${markers.length}개의 지하철역 마커를 지도에 표시했습니다.');
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

  // 특정 위치에서 지하철역 검색 (드래그 완료 시 사용)
  Future<void> _searchSubwayStationsAtLocation(LatLng center) async {
    if (mapController == null) return;

    try {
      print('🚇 새 위치에서 지하철역 검색 시작');
      
      // 200m 반경 원 표시
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

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 새 위치 검색 완료! 총 ${documents.length}개의 지하철역 발견');
        
        // 기존 마커 제거
        markers.clear();
        await mapController!.clearMarker();
        
        // 검색 결과를 마커로 표시
        for (int i = 0; i < documents.length; i++) {
          final station = documents[i];
          final lat = double.parse(station['y'].toString());
          final lng = double.parse(station['x'].toString());
          
          // 마커 생성
          final marker = Marker(
            markerId: 'subway_${station['id']}',
            latLng: LatLng(lat, lng),
            width: 30,
            height: 35,
            offsetX: 15,
            offsetY: 35,
          );
          
          markers.add(marker);
        }
        
        // 지도에 마커 추가
        if (markers.isNotEmpty) {
          await mapController!.addMarker(markers: markers);
          print('🗺️ ${markers.length}개의 지하철역 마커를 새 위치에 표시했습니다.');
        }
        
      } else {
        print('❌ 새 위치 API 호출 실패: ${response.statusCode}');
      }

    } catch (e, stackTrace) {
      print('❌ 새 위치 지하철역 검색 중 오류 발생: $e');
    }
  }

  // REST API로 버스정류장 검색 (키워드 검색 사용)
  Future<void> _searchBusStopsWithRestAPI() async {
    if (mapController == null) {
      print('❌ 맵 컨트롤러가 초기화되지 않았습니다.');
      return;
    }

    try {
      print('🚌 버스정류장 카테고리 선택됨 - 키워드 검색 시작');
      
      // 현재 맵의 중심 좌표 가져오기
      final center = await mapController!.getCenter();
      print('📍 현재 맵 중심 좌표: (${center.latitude}, ${center.longitude})');

      // 200m 반경 원 표시 (희미하게)
      await _showBusSearchRadius(center);

      // 카카오 REST API로 키워드 검색 (버스정류장 키워드 사용)
      final apiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 카카오 REST API 키가 없습니다.');
        return;
      }

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=지하철'
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
        
        print('✅ 검색 완료! 총 ${documents.length}개의 버스정류장 발견');
        
        // 기존 마커 제거
        markers.clear();
        await mapController!.clearMarker();
        
        // 검색 결과를 마커로 표시
        for (int i = 0; i < documents.length; i++) {
          final busStop = documents[i];
          final lat = double.parse(busStop['y'].toString());
          final lng = double.parse(busStop['x'].toString());
          
          // 마커 생성 (버스 마커)
          final marker = Marker(
            markerId: 'bus_${busStop['id']}',
            latLng: LatLng(lat, lng),
            width: 30,
            height: 35,
            offsetX: 15,
            offsetY: 35,
          );
          
          markers.add(marker);
          
          // 모든 데이터 필드 출력
          print('${i + 1}. ${busStop['place_name']}');
          print('   - ID: ${busStop['id'] ?? 'N/A'}');
          print('   - 주소: ${busStop['address_name'] ?? 'N/A'}');
          print('   - 도로명주소: ${busStop['road_address_name'] ?? 'N/A'}');
          print('   - 카테고리명: ${busStop['category_name'] ?? 'N/A'}');
          print('   - 카테고리그룹코드: ${busStop['category_group_code'] ?? 'N/A'}');
          print('   - 카테고리그룹명: ${busStop['category_group_name'] ?? 'N/A'}');
          print('   - 전화번호: ${busStop['phone'] ?? 'N/A'}');
          print('   - 플레이스 URL: ${busStop['place_url'] ?? 'N/A'}');
          print('   - 거리: ${busStop['distance']}m');
          print('   - 좌표: (${lat}, ${lng})');
          print('   - 전체 데이터: ${busStop.toString()}');
          print('');
        }
        
        // 지도에 마커 추가
        if (markers.isNotEmpty) {
          await mapController!.addMarker(markers: markers);
          print('🗺️ ${markers.length}개의 버스정류장 마커를 지도에 표시했습니다.');
        }
        
      } else {
        print('❌ API 호출 실패: ${response.statusCode}');
        print('📄 응답 내용: ${response.body}');
      }

    } catch (e, stackTrace) {
      print('❌ REST API 버스정류장 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
    }
  }

  // 버스정류장용 검색 반경 원 표시 (희미한 초록색)
  Future<void> _showBusSearchRadius(LatLng center) async {
    if (mapController == null) return;

    try {
      // 기존 원 제거
      circles.clear();
      
      // 200m 반경 원 생성 (희미한 초록색)
      final searchRadiusCircle = Circle(
        circleId: 'search_radius',
        center: center,
        radius: 200, // 200m
        strokeWidth: 1,
        strokeColor: Colors.green.withValues(alpha: 0.3), // 희미한 초록색 테두리
        strokeOpacity: 0.3,
        fillColor: Colors.green.withValues(alpha: 0.1), // 매우 희미한 초록색 채우기
        fillOpacity: 0.1,
        zIndex: 1, // 다른 요소들보다 뒤에 표시
      );

      circles.add(searchRadiusCircle);
      
      // 지도에 원 추가
      await mapController!.addCircle(circles: circles);
      
      print('🟢 200m 버스정류장 검색 반경 원 표시 완료');
      
    } catch (e) {
      print('❌ 버스정류장 검색 반경 원 표시 실패: $e');
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

// AddressInfo 클래스 정의
class AddressInfo {
  final String placeName;
  final String addressName;
  final String roadAddressName;
  final double latitude;
  final double longitude;

  AddressInfo({
    required this.placeName,
    required this.addressName,
    required this.roadAddressName,
    required this.latitude,
    required this.longitude,
  });
}