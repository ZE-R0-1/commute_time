import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../services/gyeonggi_bus_service.dart';
import '../../services/bus_arrival_service.dart';

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

  // 선택된 버스정류장 정보
  final Rx<GyeonggiBusStop?> selectedBusStop = Rx<GyeonggiBusStop?>(null);
  
  // 버스 도착정보
  final RxList<BusArrivalInfo> busArrivalInfos = <BusArrivalInfo>[].obs;
  
  // 바텀시트 로딩 상태
  final RxBool isBottomSheetLoading = false.obs;

  // 마커ID와 버스정류장 정보 매핑
  final Map<String, GyeonggiBusStop> busStopMap = <String, GyeonggiBusStop>{};


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
    
    // 초기화 완료 후 기본 선택된 카테고리(지하철역) 마커 표시
    if (selectedCategory.value == 0) {
      _searchSubwayStationsWithRestAPI();
    }
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
    if (selectedCategory.value == category) return; // 같은 카테고리 선택 시 무시
    
    selectedCategory.value = category;
    
    // 검색 결과 숨기기
    showSearchResults.value = false;
    addressSearchResults.clear();
    
    // 지하철역 카테고리 선택 시 REST API로 지하철역 검색
    if (category == 0) {
      _searchSubwayStationsWithRestAPI();
    }
    
    // 버스정류장 카테고리 선택 시 REST API로 버스정류장 검색
    if (category == 1) {
      _searchBusStopsWithRestAPI();
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
        '&radius=500'
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
          
          // 마커 생성 (기본 마커)
          final marker = Marker(
            markerId: 'subway_${station['id']}',
            latLng: LatLng(lat, lng),
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
        '&radius=500'
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
          
          // 마커 생성 (기본 마커)
          final marker = Marker(
            markerId: 'subway_${station['id']}',
            latLng: LatLng(lat, lng),
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

  // REST API로 버스정류장 검색 (경기도 API + 카카오 키워드 검색)
  Future<void> _searchBusStopsWithRestAPI() async {
    if (mapController == null) {
      print('❌ 맵 컨트롤러가 초기화되지 않았습니다.');
      return;
    }

    try {
      print('🚌 버스정류장 카테고리 선택됨 - 통합 검색 시작');
      
      // 현재 맵의 중심 좌표 가져오기
      final center = await mapController!.getCenter();
      print('📍 현재 맵 중심 좌표: (${center.latitude}, ${center.longitude})');


      // 기존 마커 제거
      markers.clear();
      await mapController!.clearMarker();

      // 1. 경기도 버스정류장 API 검색
      await _searchGyeonggiBusStops(center);

      // 2. 카카오 키워드 검색으로 추가 버스정류장 검색
      await _searchKakaoBusStops(center);

      // 지도에 마커 추가
      if (markers.isNotEmpty) {
        await mapController!.addMarker(markers: markers);
        print('🗺️ 총 ${markers.length}개의 버스정류장 마커를 지도에 표시했습니다.');
      }

    } catch (e, stackTrace) {
      print('❌ REST API 버스정류장 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
    }
  }

  // 경기도 버스정류장 API 검색
  Future<void> _searchGyeonggiBusStops(LatLng center) async {
    try {
      print('🏛️ 경기도 버스정류장 API 검색 시작');
      
      final gyeonggiBusStops = await GyeonggiBusService.getBusStopsByLocation(
        center.latitude, 
        center.longitude,
        radius: 500, // 500m 반경
      );

      print('✅ 경기도 API 검색 완료! 총 ${gyeonggiBusStops.length}개의 버스정류장 발견');

      for (int i = 0; i < gyeonggiBusStops.length; i++) {
        final busStop = gyeonggiBusStops[i];
        
        // 마커 생성 (경기도 버스정류장용)
        final markerId = 'gyeonggi_bus_${busStop.stationId}';
        final marker = Marker(
          markerId: markerId,
          latLng: LatLng(busStop.y, busStop.x),
        );
        
        markers.add(marker);
        
        // 마커ID와 버스정류장 정보 매핑 저장
        busStopMap[markerId] = busStop;
        
        print('${i + 1}. ${busStop.stationName}');
        print('   - ID: ${busStop.stationId}');
        print('   - 지역: ${busStop.regionName}');
        print('   - 좌표: (${busStop.y}, ${busStop.x})');
        if (busStop.mobileNo.isNotEmpty) {
          print('   - 모바일번호: ${busStop.mobileNo}');
        }
        print('');
      }

    } catch (e, stackTrace) {
      print('❌ 경기도 버스정류장 API 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
    }
  }

  // 카카오 키워드 검색으로 추가 버스정류장 검색
  Future<void> _searchKakaoBusStops(LatLng center) async {
    try {
      print('🔍 카카오 키워드 검색으로 추가 버스정류장 검색 시작');
      
      final apiKey = dotenv.env['KAKAO_REST_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        print('❌ 카카오 REST API 키가 없습니다.');
        return;
      }

      final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/keyword.json'
        '?query=버스정류장'
        '&x=${center.longitude}'
        '&y=${center.latitude}'
        '&radius=500'
        '&sort=distance'
        '&page=1'
        '&size=10'
      );

      print('🔍 카카오 API 요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 카카오 HTTP 응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;
        
        print('✅ 카카오 검색 완료! 총 ${documents.length}개의 추가 버스정류장 발견');
        
        // 기존 마커와 중복 확인을 위한 Set
        final existingLocations = markers.map((m) => '${m.latLng.latitude}_${m.latLng.longitude}').toSet();
        
        for (int i = 0; i < documents.length; i++) {
          final busStop = documents[i];
          final lat = double.parse(busStop['y'].toString());
          final lng = double.parse(busStop['x'].toString());
          
          // 중복 위치 확인 (100m 이내는 같은 정류장으로 간주)
          final locationKey = '${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';
          if (existingLocations.contains(locationKey)) {
            continue; // 중복이면 스킵
          }
          
          // 마커 생성 (카카오 버스정류장용)
          final marker = Marker(
            markerId: 'kakao_bus_${busStop['id']}',
            latLng: LatLng(lat, lng),
          );
          
          markers.add(marker);
          existingLocations.add(locationKey);
          
          print('카카오 ${i + 1}. ${busStop['place_name']}');
          print('   - 주소: ${busStop['address_name'] ?? 'N/A'}');
          print('   - 거리: ${busStop['distance']}m');
          print('   - 좌표: ($lat, $lng)');
          print('');
        }
        
      } else {
        print('❌ 카카오 API 호출 실패: ${response.statusCode}');
      }

    } catch (e, stackTrace) {
      print('❌ 카카오 버스정류장 검색 중 오류: $e');
    }
  }




  // 마커 탭 이벤트 처리
  void onMarkerTap(String markerId, LatLng latLng, int zoomLevel) {
    print('🖱️ 마커 탭됨: $markerId');
    
    // 버스정류장 마커인지 확인
    if (markerId.startsWith('gyeonggi_bus_')) {
      final busStop = busStopMap[markerId];
      if (busStop != null) {
        selectedBusStop.value = busStop;
        _showBusArrivalBottomSheet(busStop);
      }
    }
  }

  // 버스 도착정보 바텀시트 표시
  void _showBusArrivalBottomSheet(GyeonggiBusStop busStop) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 핸들바
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 정류장 정보 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      color: Colors.green[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          busStop.stationName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          busStop.regionName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            // 구분선
            Divider(color: Colors.grey[200], height: 1),
            
            // 도착정보 리스트
            Expanded(
              child: Obx(() {
                if (isBottomSheetLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          '버스 도착정보를 불러오는 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                if (busArrivalInfos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '현재 도착 예정인 버스가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: busArrivalInfos.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final info = busArrivalInfos[index];
                    return _buildBusArrivalCard(info);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
    
    // 바텀시트 표시 후 도착정보 로드
    _loadBusArrivalInfo(busStop.stationId);
  }

  // 버스 도착정보 카드 위젯
  Widget _buildBusArrivalCard(BusArrivalInfo info) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 버스 노선 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBusTypeColor(info.routeTypeName),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.routeTypeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.routeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 도착 예정 시간
          Row(
            children: [
              Expanded(
                child: _buildArrivalTimeInfo(
                  '첫 번째 버스',
                  info.predictTime1,
                  info.locationNo1,
                  info.lowPlate1,
                  info.remainSeatCnt1,
                  isPrimary: true,
                ),
              ),
              if (info.predictTime2 > 0) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildArrivalTimeInfo(
                    '두 번째 버스',
                    info.predictTime2,
                    info.locationNo2,
                    info.lowPlate2,
                    info.remainSeatCnt2,
                    isPrimary: false,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 도착 시간 정보 위젯
  Widget _buildArrivalTimeInfo(
    String label,
    int predictTime,
    int locationNo,
    String lowPlate,
    int remainSeatCnt, {
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPrimary ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            predictTime == 0 ? '곧 도착' : '${predictTime}분 후',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPrimary ? Colors.blue[700] : Colors.grey[700],
            ),
          ),
          if (locationNo > 0) ...[
            const SizedBox(height: 2),
            Text(
              '${locationNo}정류장 전',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (lowPlate == 'Y') ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '저상버스',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 버스 유형별 색상 반환
  Color _getBusTypeColor(String routeTypeName) {
    switch (routeTypeName) {
      case '직행좌석':
        return Colors.red;
      case '좌석':
        return Colors.blue;
      case '일반':
        return Colors.green;
      case '광역급행':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // 버스 도착정보 로드
  Future<void> _loadBusArrivalInfo(String stationId) async {
    isBottomSheetLoading.value = true;
    busArrivalInfos.clear();
    
    try {
      final arrivalInfos = await BusArrivalService.getBusArrivalInfo(stationId);
      busArrivalInfos.addAll(arrivalInfos);
      print('✅ 버스 도착정보 로드 완료: ${arrivalInfos.length}개');
    } catch (e) {
      print('❌ 버스 도착정보 로드 실패: $e');
    } finally {
      isBottomSheetLoading.value = false;
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