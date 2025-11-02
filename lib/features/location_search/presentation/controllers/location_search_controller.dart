import 'dart:async';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../domain/entities/subway_station_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/gyeonggi_bus_stop_entity.dart';
import '../../domain/entities/seoul_bus_stop_entity.dart';
import '../../domain/entities/bus_search_result_entity.dart';
import '../../domain/usecases/search_subway_stations_usecase.dart';
import '../../domain/usecases/get_subway_arrival_usecase.dart';
import '../../domain/usecases/search_places_usecase.dart';
import '../../domain/usecases/search_nearby_bus_stops_usecase.dart';
import '../views/components/transport_bottom_sheet.dart';

class LocationSearchController extends GetxController {
  final SearchSubwayStationsUseCase searchSubwayStationsUseCase;
  final GetSubwayArrivalUseCase getSubwayArrivalUseCase;
  final SearchPlacesUseCase searchPlacesUseCase;
  final SearchNearbyBusStopsUseCase searchNearbyBusStopsUseCase;

  LocationSearchController({
    required this.searchSubwayStationsUseCase,
    required this.getSubwayArrivalUseCase,
    required this.searchPlacesUseCase,
    required this.searchNearbyBusStopsUseCase,
  });

  // 카카오맵 컨트롤러
  KakaoMapController? mapController;

  // 검색 관련
  final RxString searchQuery = ''.obs;
  final RxInt selectedCategory = 0.obs; // 0: 지하철, 1: 버스
  final RxBool isLoading = false.obs;
  final RxBool showSearchResults = false.obs;

  // 검색 결과
  final RxList<AddressEntity> addressSearchResults = <AddressEntity>[].obs;

  // 화면 설정
  final RxString mode = ''.obs;
  final RxString title = ''.obs;

  // 지도 마커 및 상태
  final RxList<Marker> markers = <Marker>[].obs;
  final RxBool isBottomSheetVisible = false.obs;
  final RxBool showResearchButton = false.obs;
  LatLng? lastDragPosition;

  // 데이터 매핑
  final Map<String, SubwayStationEntity> subwayStationMap = {};
  final Map<String, GyeonggiBusStopEntity> gyeonggiBusStopMap = {};
  final Map<String, SeoulBusStopEntity> seoulBusStopMap = {};

  // 디바운스 타이머
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    mode.value = args['mode'] ?? 'departure';
    title.value = args['title'] ?? '위치 검색';
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    mapController = null;
    markers.clear();
    super.onClose();
  }

  // 카카오맵 초기화
  void onMapCreated(KakaoMapController controller) {
    mapController = controller;
    print('🗺️ 카카오맵 초기화 완료');

    // 초기 지하철역 검색
    if (selectedCategory.value == 0) {
      _searchSubwayStations();
    }
  }

  // 주소 검색 실행
  void performAddressSearch(String query) {
    if (query.isEmpty) {
      addressSearchResults.clear();
      showSearchResults.value = false;
      return;
    }

    searchQuery.value = query;
    isLoading.value = true;
    showSearchResults.value = true;

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchAddresses(query);
    });
  }

  // 주소 검색 (SearchPlacesUseCase 사용)
  Future<void> _searchAddresses(String query) async {
    try {
      final results = await searchPlacesUseCase(query);
      addressSearchResults.value = results;
      print('✅ 주소 검색 완료: ${results.length}개');
    } catch (e) {
      print('❌ 주소 검색 오류: $e');
      addressSearchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // 주소 선택
  void selectAddress(AddressEntity address) async {
    if (mapController == null) return;

    print('📍 주소 선택: ${address.placeName}');

    await mapController!.setCenter(LatLng(address.latitude, address.longitude));
    showSearchResults.value = false;
    addressSearchResults.clear();

    // 지도 이동 후 현재 선택된 카테고리에 따라 마커 표시
    await _refreshMarkersAfterMove();
  }

  // 카테고리 변경
  void changeCategory(int category) {
    if (selectedCategory.value == category) return;

    print('🏷️ 카테고리 탭: ${category == 0 ? "지하철역" : "버스정류장"}');

    selectedCategory.value = category;
    showSearchResults.value = false;
    addressSearchResults.clear();

    if (category == 0) {
      _searchSubwayStations();
    } else {
      _searchBusStops();
    }
  }

  // 지하철역 검색
  Future<void> _searchSubwayStations() async {
    if (mapController == null) return;

    try {
      final center = await mapController!.getCenter();
      // 새로운 Usecase 사용
      final stations = await searchSubwayStationsUseCase(center);

      await _updateSubwayMarkers(stations);
      print('🚇 지하철역 마커 업데이트 완료: ${stations.length}개');
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
    }
  }

  // 지하철 마커 업데이트
  Future<void> _updateSubwayMarkers(List<SubwayStationEntity> stations) async {
    if (mapController == null) return;

    // 기존 마커 제거
    await mapController!.clearMarker();
    markers.clear();
    subwayStationMap.clear();

    // 새 마커 생성
    for (final station in stations) {
      final markerId = 'subway_${station.id}';
      final marker = Marker(
        markerId: markerId,
        latLng: LatLng(station.latitude, station.longitude),
      );

      markers.add(marker);
      subwayStationMap[markerId] = station;
    }

    // 지도에 마커 추가
    if (markers.isNotEmpty) {
      await mapController!.addMarker(markers: markers);
    }
  }

  // 버스정류장 검색
  Future<void> _searchBusStops() async {
    if (mapController == null) return;

    try {
      final center = await mapController!.getCenter();
      final result = await searchNearbyBusStopsUseCase(center);

      await _updateBusMarkers(result);
      print('🚌 버스정류장 마커 업데이트 완료: ${result.totalCount}개');
    } catch (e) {
      print('❌ 버스정류장 검색 오류: $e');
    }
  }

  // 버스 마커 업데이트
  Future<void> _updateBusMarkers(BusSearchResultEntity result) async {
    if (mapController == null) return;

    // 기존 마커 제거
    await mapController!.clearMarker();
    markers.clear();
    gyeonggiBusStopMap.clear();
    seoulBusStopMap.clear();

    // 경기도 버스정류장 마커
    for (final busStop in result.gyeonggiBusStops) {
      final markerId = 'gyeonggi_bus_${busStop.stationId}';
      final marker = Marker(
        markerId: markerId,
        latLng: LatLng(busStop.y, busStop.x),
      );

      markers.add(marker);
      gyeonggiBusStopMap[markerId] = busStop;
    }

    // 서울 버스정류장 마커
    for (final busStop in result.seoulBusStops) {
      final markerId = 'seoul_bus_${busStop.stationId}';
      final marker = Marker(
        markerId: markerId,
        latLng: LatLng(busStop.gpsY, busStop.gpsX),
      );

      markers.add(marker);
      seoulBusStopMap[markerId] = busStop;
    }

    // 지도에 마커 추가
    if (markers.isNotEmpty) {
      await mapController!.addMarker(markers: markers);
    }
  }

  // 마커 탭 이벤트
  void onMarkerTap(String markerId, LatLng latLng, int zoomLevel) {
    if (isBottomSheetVisible.value) {
      print('⚠️ 바텀시트가 이미 열려있어서 마커 탭을 무시합니다.');
      return;
    }

    print('🖱️ 마커 탭: $markerId');

    if (markerId.startsWith('subway_')) {
      _handleSubwayMarkerTap(markerId);
    } else if (markerId.startsWith('gyeonggi_bus_')) {
      _handleGyeonggiBusMarkerTap(markerId);
    } else if (markerId.startsWith('seoul_bus_')) {
      _handleSeoulBusMarkerTap(markerId);
    }
  }

  // 지하철 마커 탭 처리
  void _handleSubwayMarkerTap(String markerId) {
    final station = subwayStationMap[markerId];
    if (station == null) return;

    print('🚇 지하철역 placeName: ${station.placeName}');

    _setMapDraggable(false);
    isBottomSheetVisible.value = true;

    // placeName에서 노선 정보 추출 (예: "강남역 2호선" -> "2호선")
    String lineFilter = _extractLineFromPlaceName(station.placeName);

    TransportBottomSheet.showSubwayArrival(
      stationName: station.cleanStationName,
      mode: mode.value,
      onClose: () {
        isBottomSheetVisible.value = false;
        _setMapDraggable(true);
      },
      onSelect: (selectedStationName) => _selectSubwayStationWithDirection(selectedStationName, station),
      placeName: station.placeName,
      lineFilter: lineFilter,
    );
  }

  // placeName에서 노선 정보 추출
  String _extractLineFromPlaceName(String placeName) {
    if (placeName.contains('1호선')) return '1호선';
    if (placeName.contains('2호선')) return '2호선';
    if (placeName.contains('3호선')) return '3호선';
    if (placeName.contains('4호선')) return '4호선';
    if (placeName.contains('5호선')) return '5호선';
    if (placeName.contains('6호선')) return '6호선';
    if (placeName.contains('7호선')) return '7호선';
    if (placeName.contains('8호선')) return '8호선';
    if (placeName.contains('9호선')) return '9호선';
    if (placeName.contains('신분당선')) return '신분당선';
    if (placeName.contains('분당선')) return '분당선';
    if (placeName.contains('경의중앙선')) return '경의중앙선';
    if (placeName.contains('공항철도')) return '공항철도';
    if (placeName.contains('경춘선')) return '경춘선';
    if (placeName.contains('수인분당선')) return '수인분당선';
    if (placeName.contains('우이신설선')) return '우이신설선';
    if (placeName.contains('서해선')) return '서해선';
    if (placeName.contains('김포골드라인')) return '김포골드라인';
    if (placeName.contains('신림선')) return '신림선';

    return ''; // 노선 정보가 없으면 빈 문자열 반환
  }

  // 경기도 버스 마커 탭 처리
  void _handleGyeonggiBusMarkerTap(String markerId) {
    final busStop = gyeonggiBusStopMap[markerId];
    if (busStop == null) return;

    _setMapDraggable(false);
    isBottomSheetVisible.value = true;

    TransportBottomSheet.showGyeonggiBusArrival(
      busStop: busStop,
      mode: mode.value,
      onClose: () {
        isBottomSheetVisible.value = false;
        _setMapDraggable(true);
      },
      onSelect: (busStop) => _selectBusStop(busStop),
    );
  }

  // 서울 버스 마커 탭 처리
  void _handleSeoulBusMarkerTap(String markerId) {
    final busStop = seoulBusStopMap[markerId];
    if (busStop == null) return;

    _setMapDraggable(false);
    isBottomSheetVisible.value = true;

    TransportBottomSheet.showSeoulBusArrival(
      busStop: busStop,
      mode: mode.value,
      onClose: () {
        isBottomSheetVisible.value = false;
        _setMapDraggable(true);
      },
      onSelect: (busStop) => _selectBusStop(busStop),
    );
  }

  // 드래그 이벤트 처리
  void onDragChange(LatLng latLng, int zoomLevel, DragType dragType) {
    switch (dragType) {
      case DragType.start:
        showResearchButton.value = false;
        break;
      case DragType.move:
        break;
      case DragType.end:
        print('🖱️ 드래그 완료: (${latLng.latitude}, ${latLng.longitude})');
        lastDragPosition = latLng;
        showResearchButton.value = true;
        break;
    }
  }

  // 재검색 버튼 탭
  void onResearchButtonTap() async {
    if (lastDragPosition == null) return;

    showResearchButton.value = false;

    if (selectedCategory.value == 0) {
      await _searchSubwayStationsAtLocation(lastDragPosition!);
    } else {
      await _searchBusStopsAtLocation(lastDragPosition!);
    }
  }

  // 특정 위치에서 지하철역 검색
  Future<void> _searchSubwayStationsAtLocation(LatLng center) async {
    try {
      // 새로운 Usecase 사용
      final stations = await searchSubwayStationsUseCase(center);
      await _updateSubwayMarkers(stations);
      print('🚇 새 위치 지하철역 검색 완료: ${stations.length}개');
    } catch (e) {
      print('❌ 새 위치 지하철역 검색 오류: $e');
    }
  }

  // 특정 위치에서 버스정류장 검색
  Future<void> _searchBusStopsAtLocation(LatLng center) async {
    try {
      final result = await searchNearbyBusStopsUseCase(center);
      await _updateBusMarkers(result);
      print('🚌 새 위치 버스정류장 검색 완료: ${result.totalCount}개');
    } catch (e) {
      print('❌ 새 위치 버스정류장 검색 오류: $e');
    }
  }

  // 지하철역 선택 (방면 정보 포함)
  void _selectSubwayStationWithDirection(String selectedStationName, SubwayStationEntity station) {
    if (mode.value.isEmpty) return;

    Get.back(result: {
      'name': selectedStationName, // 바텀시트에서 선택한 방면 정보 포함된 이름 사용
      'type': 'subway',
      'lineInfo': '지하철역',
      'code': station.id,
      'latitude': station.latitude,
      'longitude': station.longitude,
    });
  }

  // 지하철역 선택 (기존 - 호환성 유지)
  void _selectSubwayStation(SubwayStationEntity station) {
    if (mode.value.isEmpty) return;

    Get.back(result: {
      'name': station.placeName.isNotEmpty ? station.placeName : '${station.cleanStationName}역',
      'type': 'subway',
      'lineInfo': '지하철역',
      'code': station.id,
      'latitude': station.latitude,
      'longitude': station.longitude,
    });
  }

  // 버스정류장 선택
  void _selectBusStop(dynamic busStop) {
    if (mode.value.isEmpty) return;

    String stationName = '';
    String lineInfo = '';
    String code = '';
    String cityCode = '';
    double latitude = 0;
    double longitude = 0;

    if (busStop is GyeonggiBusStopEntity) {
      stationName = busStop.stationName;
      lineInfo = '경기도 버스정류장';
      code = busStop.stationId;
      cityCode = ''; // 경기도 버스는 cityCode가 필요 없음
      latitude = busStop.y;
      longitude = busStop.x;
    } else if (busStop is SeoulBusStopEntity) {
      stationName = busStop.stationNm;
      lineInfo = '서울 버스정류장';
      code = busStop.stationId;
      cityCode = '23'; // 서울 버스의 cityCode
      latitude = busStop.gpsY;
      longitude = busStop.gpsX;
    }

    Get.back(result: {
      'name': stationName,
      'type': 'bus',
      'lineInfo': lineInfo,
      'code': code,
      'cityCode': cityCode,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // 지도 이동 후 마커 새로고침 (public 메서드)
  Future<void> refreshMarkersAfterMove() async {
    print('🔄 지도 이동 완료 - 마커 새로고침 시작');

    if (selectedCategory.value == 0) {
      await _searchSubwayStations();
    } else {
      await _searchBusStops();
    }
  }

  // 지도 이동 후 마커 새로고침 (private 메서드 - 내부 호출용)
  Future<void> _refreshMarkersAfterMove() async {
    await refreshMarkersAfterMove();
  }

  // 지도 드래그 설정
  void _setMapDraggable(bool draggable) {
    if (mapController != null) {
      mapController!.setDraggable(draggable);
      print('🗺️ 지도 드래그 ${draggable ? "활성화" : "비활성화"}');
    }
  }
}