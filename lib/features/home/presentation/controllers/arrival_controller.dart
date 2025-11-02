import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../location_search/domain/entities/subway_arrival_entity.dart';
import '../../../location_search/domain/entities/bus_arrival_info_entity.dart';
import '../../../location_search/domain/entities/seoul_bus_arrival_entity.dart';
import '../../../location_search/domain/usecases/get_subway_arrival_usecase.dart';
import '../../../location_search/domain/usecases/get_bus_arrival_item_usecase.dart';
import '../../../location_search/domain/usecases/get_seoul_bus_arrival_usecase.dart';

/// 도착정보 관련 Controller
class ArrivalController extends GetxController {
  final GetStorage _storage = GetStorage();
  final GetSubwayArrivalUseCase getSubwayArrivalUseCase;
  final GetBusArrivalItemUseCase getBusArrivalItemUseCase;
  final GetSeoulBusArrivalUseCase getSeoulBusArrivalUseCase;

  ArrivalController({
    required this.getSubwayArrivalUseCase,
    required this.getBusArrivalItemUseCase,
    required this.getSeoulBusArrivalUseCase,
  });

  // 지하철 도착정보 상태
  final RxList<SubwayArrivalEntity> departureArrivalInfo = <SubwayArrivalEntity>[].obs;
  final RxList<List<SubwayArrivalEntity>> transferArrivalInfo = <List<SubwayArrivalEntity>>[].obs;
  final RxList<SubwayArrivalEntity> destinationArrivalInfo = <SubwayArrivalEntity>[].obs;
  final RxBool isLoadingArrival = false.obs;
  final RxBool isLoadingTransferArrival = false.obs;
  final RxBool isLoadingDestinationArrival = false.obs;
  final RxString arrivalError = ''.obs;
  final RxString transferArrivalError = ''.obs;
  final RxString destinationArrivalError = ''.obs;

  // 버스 도착정보 상태
  final RxList<BusArrivalInfoEntity> departureBusArrivalInfo = <BusArrivalInfoEntity>[].obs;
  final RxList<List<BusArrivalInfoEntity>> transferBusArrivalInfo = <List<BusArrivalInfoEntity>>[].obs;
  final RxList<BusArrivalInfoEntity> destinationBusArrivalInfo = <BusArrivalInfoEntity>[].obs;
  final RxList<SeoulBusArrivalEntity> departureSeoulBusArrivalInfo = <SeoulBusArrivalEntity>[].obs;
  final RxList<List<SeoulBusArrivalEntity>> transferSeoulBusArrivalInfo = <List<SeoulBusArrivalEntity>>[].obs;
  final RxList<SeoulBusArrivalEntity> destinationSeoulBusArrivalInfo = <SeoulBusArrivalEntity>[].obs;

  // 모든 역의 실시간 도착정보 로딩
  Future<void> loadAllArrivalInfo({
    required String departureStationName,
    required String arrivalStationName,
    required List<Map<String, dynamic>> transferStations,
    required String activeRouteId,
  }) async {
    await Future.wait([
      loadDepartureArrivalInfo(departureStationName, activeRouteId),
      loadTransferArrivalInfo(transferStations),
      loadDestinationArrivalInfo(arrivalStationName, activeRouteId),
    ]);
  }

  // 출발지 실시간 도착정보 로딩 (버스/지하철 구분)
  Future<void> loadDepartureArrivalInfo(String departureStationName, String activeRouteId) async {
    print('🚦 loadDepartureArrivalInfo 호출됨: departureStationName="$departureStationName", activeRouteId="$activeRouteId"');

    if (departureStationName.isEmpty) {
      print('⚠️ 출발지 이름이 비어있어 반환합니다');
      return;
    }

    // 현재 활성 경로에서 출발지 데이터 가져오기
    final savedRoutes = _storage.read<List>('saved_routes');
    print('📦 저장된 경로 개수: ${savedRoutes?.length ?? 0}');

    Map<String, dynamic>? departureData;

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      print('🔍 활성 경로 ID로 검색 중: $activeRouteId');
      Map<String, dynamic>? activeRoute;

      try {
        activeRoute = savedRoutes.firstWhere(
          (route) => (route as Map)['id'] == activeRouteId,
        ) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️ 활성 경로 ID를 찾지 못함. 첫 번째 경로 사용');
        activeRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
      }

      print('✓ 활성 경로 찾음: ${activeRoute['name']}');
      departureData = activeRoute['departure'] as Map<String, dynamic>?;
      print('📍 출발지 데이터: $departureData');
    }

    if (departureData == null) {
      print('⚠️ 출발지 상세 데이터를 찾을 수 없습니다');
      return;
    }

    final type = departureData['type'] ?? 'subway';
    final stationCode = departureData['code'] ?? '';
    final lineInfo = departureData['lineInfo'] ?? '';

    print('🚦 출발지 도착정보 로딩 시작: ${departureData['name']} (type: $type, code: $stationCode, lineInfo: $lineInfo)');

    try {
      isLoadingArrival.value = true;
      arrivalError.value = '';

      if (type == 'bus') {
        await _loadBusArrivalInfo('departure', departureData);
      } else if (type == 'subway') {
        await _loadSubwayArrivalInfo('departure', departureData);
      }
    } catch (e) {
      arrivalError.value = '도착정보 로딩 실패';
      departureArrivalInfo.clear();
      departureBusArrivalInfo.clear();
      departureSeoulBusArrivalInfo.clear();
      print('❌ 출발지 도착정보 로딩 오류: $e');
    } finally {
      isLoadingArrival.value = false;
    }
  }

  // 버스 도착정보 로딩
  Future<void> _loadBusArrivalInfo(String locationType, Map<String, dynamic> locationData) async {
    final stationCode = locationData['code'] ?? '';
    final lineInfo = locationData['lineInfo'] ?? '';
    final stationName = locationData['name'] ?? '';

    print('🚌 $locationType 버스 도착정보 로딩: $stationName (code: $stationCode, region: $lineInfo)');

    if (lineInfo.contains('경기도')) {
      // 경기도 버스 도착정보 (v2 API 사용)
      final routeId = locationData['routeId']?.toString() ?? '';
      final staOrder = locationData['staOrder'] ?? 0;

      List<BusArrivalInfoEntity> arrivals = [];

      if (routeId.isNotEmpty && staOrder > 0) {
        print('🚌 경기도 버스 v2 API 호출: stationId=$stationCode, routeId=$routeId, staOrder=$staOrder');
        final arrivalInfo = await getBusArrivalItemUseCase(stationCode, routeId, staOrder);
        if (arrivalInfo != null) {
          arrivals = [arrivalInfo];
        }
      } else {
        print('⚠️ 경기도 버스 routeId 또는 staOrder가 없어 도착정보를 가져올 수 없습니다.');
        arrivals = [];
      }

      if (locationType == 'departure') {
        departureBusArrivalInfo.value = arrivals;
        departureSeoulBusArrivalInfo.clear();
        departureArrivalInfo.clear();
      } else if (locationType == 'destination') {
        destinationBusArrivalInfo.value = arrivals;
        destinationSeoulBusArrivalInfo.clear();
      } else if (locationType.startsWith('transfer_')) {
        final transferIndex = int.tryParse(locationType.replaceFirst('transfer_', '')) ?? 0;

        while (transferBusArrivalInfo.length <= transferIndex) {
          transferBusArrivalInfo.add(<BusArrivalInfoEntity>[].obs);
        }

        transferBusArrivalInfo[transferIndex] = arrivals.obs;
        print('✅ 환승지 ${transferIndex + 1} 경기도 버스 도착정보 저장: ${arrivals.length}개');
      }
    } else if (lineInfo.contains('서울')) {
      final cityCode = locationData['cityCode']?.toString() ?? '';
      print('🏙️ 서울 버스 API 호출: cityCode=$cityCode, nodeId=$stationCode');
      final arrivals = await getSeoulBusArrivalUseCase(cityCode, stationCode);

      if (locationType == 'departure') {
        departureSeoulBusArrivalInfo.value = arrivals;
        departureBusArrivalInfo.clear();
        departureArrivalInfo.clear();
      } else if (locationType == 'destination') {
        destinationSeoulBusArrivalInfo.value = arrivals;
        destinationBusArrivalInfo.clear();
      } else if (locationType.startsWith('transfer_')) {
        final transferIndex = int.tryParse(locationType.replaceFirst('transfer_', '')) ?? 0;

        while (transferSeoulBusArrivalInfo.length <= transferIndex) {
          transferSeoulBusArrivalInfo.add(<SeoulBusArrivalEntity>[].obs);
        }

        transferSeoulBusArrivalInfo[transferIndex] = arrivals.obs;
        print('✅ 환승지 ${transferIndex + 1} 서울 버스 도착정보 저장: ${arrivals.length}개');
      }
    }
  }

  // 지하철 도착정보 로딩
  Future<void> _loadSubwayArrivalInfo(String locationType, Map<String, dynamic> locationData) async {
    final stationName = locationData['name'] ?? '';

    String cleanStationName = _cleanStationName(stationName);

    print('🚇 $locationType 지하철 도착정보 로딩: $stationName → $cleanStationName');

    final allArrivals = await getSubwayArrivalUseCase(cleanStationName);

    final filteredArrivals = _filterArrivalsByLine(allArrivals, stationName);

    if (locationType == 'departure') {
      departureBusArrivalInfo.clear();
      departureSeoulBusArrivalInfo.clear();

      if (filteredArrivals.isNotEmpty) {
        departureArrivalInfo.value = filteredArrivals;
        print('✅ 지하철 도착정보 로딩 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
      } else {
        departureArrivalInfo.clear();
        print('⚠️ 지하철 도착정보 없음 (전체 ${allArrivals.length}개 → 필터링 후 0개)');
      }
    }
  }

  // 역명에서 호선 정보 제거
  String _cleanStationName(String stationName) {
    final parts = stationName.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return stationName;
  }

  // 호선별 도착정보 필터링
  List<SubwayArrivalEntity> _filterArrivalsByLine(List<SubwayArrivalEntity> arrivals, String lineFilter) {
    if (lineFilter.isEmpty) {
      return arrivals;
    }

    String extractedLine = '';
    String extractedDirection = '';

    if (lineFilter.contains('1호선')) extractedLine = '1호선';
    else if (lineFilter.contains('2호선')) extractedLine = '2호선';
    else if (lineFilter.contains('3호선')) extractedLine = '3호선';
    else if (lineFilter.contains('4호선')) extractedLine = '4호선';
    else if (lineFilter.contains('5호선')) extractedLine = '5호선';
    else if (lineFilter.contains('6호선')) extractedLine = '6호선';
    else if (lineFilter.contains('7호선')) extractedLine = '7호선';
    else if (lineFilter.contains('8호선')) extractedLine = '8호선';
    else if (lineFilter.contains('9호선')) extractedLine = '9호선';
    else if (lineFilter.contains('신분당선')) extractedLine = '신분당선';
    else if (lineFilter.contains('분당선')) extractedLine = '분당선';
    else if (lineFilter.contains('경의중앙선')) extractedLine = '경의중앙선';
    else if (lineFilter.contains('공항철도')) extractedLine = '공항철도';
    else if (lineFilter.contains('경춘선')) extractedLine = '경춘선';
    else if (lineFilter.contains('수인분당선')) extractedLine = '수인분당선';
    else if (lineFilter.contains('우이신설선')) extractedLine = '우이신설선';
    else if (lineFilter.contains('서해선')) extractedLine = '서해선';
    else if (lineFilter.contains('김포골드라인')) extractedLine = '김포골드라인';
    else if (lineFilter.contains('신림선')) extractedLine = '신림선';

    final directionMatch = RegExp(r'\(([^)]+)방면\)').firstMatch(lineFilter);
    if (directionMatch != null) {
      extractedDirection = directionMatch.group(1) ?? '';
    }

    if (extractedLine.isEmpty) {
      return arrivals;
    }

    print('🔍 필터링 적용: $lineFilter → 호선: $extractedLine, 방면: $extractedDirection');

    List<SubwayArrivalEntity> filtered = arrivals.where((arrival) {
      return arrival.lineDisplayName.contains(extractedLine);
    }).toList();

    if (extractedDirection.isNotEmpty && filtered.isNotEmpty) {
      final directionFiltered = filtered.where((arrival) {
        return arrival.cleanTrainLineNm.contains(extractedDirection) ||
            arrival.cleanTrainLineNm.contains('${extractedDirection}행') ||
            arrival.bstatnNm.contains(extractedDirection);
      }).toList();

      if (directionFiltered.isNotEmpty) {
        filtered = directionFiltered;
        print('📊 방면 필터링 적용: ${arrivals.length}개 → 호선: ${filtered.length}개 → 방면: ${directionFiltered.length}개');
      } else {
        print('📊 방면 필터링 결과 없음, 호선 필터링만 사용: ${arrivals.length}개 → ${filtered.length}개');
      }
    } else {
      print('📊 호선 필터링만 적용: ${arrivals.length}개 → ${filtered.length}개');
    }

    return filtered;
  }

  // 특정 호선의 도착정보만 필터링
  List<SubwayArrivalEntity> getArrivalsByLine(String targetSubwayId) {
    return departureArrivalInfo
        .where((arrival) => arrival.subwayId == targetSubwayId)
        .take(2)
        .toList();
  }

  // 호선별로 그룹화된 도착정보
  Map<String, List<SubwayArrivalEntity>> get groupedArrivalInfo {
    final Map<String, List<SubwayArrivalEntity>> grouped = {};

    for (final arrival in departureArrivalInfo) {
      final lineKey = arrival.lineDisplayName;
      if (!grouped.containsKey(lineKey)) {
        grouped[lineKey] = [];
      }
      grouped[lineKey]!.add(arrival);
    }

    return grouped;
  }

  // 모든 도착정보 새로고침
  Future<void> refreshAllArrivalInfo({
    required String departureStationName,
    required String arrivalStationName,
    required List<Map<String, dynamic>> transferStations,
    required String activeRouteId,
  }) async {
    print('🔄 모든 도착정보 새로고침 시작');
    await loadAllArrivalInfo(
      departureStationName: departureStationName,
      arrivalStationName: arrivalStationName,
      transferStations: transferStations,
      activeRouteId: activeRouteId,
    );
    print('✅ 모든 도착정보 새로고침 완료');
  }

  // 환승지들 실시간 도착정보 로딩
  Future<void> loadTransferArrivalInfo(List<Map<String, dynamic>> transferStations) async {
    try {
      isLoadingTransferArrival.value = true;
      transferArrivalError.value = '';

      List<List<SubwayArrivalEntity>> allTransferArrivals = [];

      for (int i = 0; i < transferStations.length; i++) {
        final transferStation = transferStations[i];
        final type = transferStation['type'] ?? 'subway';
        final stationCode = transferStation['code'] ?? '';
        final lineInfo = transferStation['lineInfo'] ?? '';
        final stationName = transferStation['name']?.toString() ?? '';

        print('🚦 환승지 ${i + 1} 도착정보 로딩 시작: $stationName (type: $type, code: $stationCode)');

        if (stationName.isNotEmpty) {
          try {
            if (type == 'bus') {
              await _loadBusArrivalInfo('transfer_$i', transferStation);
              allTransferArrivals.add([]);
              print('✅ 환승지 ${i + 1} 버스 도착정보 완료');
            } else if (type == 'subway') {
              String cleanStationName = _cleanStationName(stationName);
              final allArrivals = await getSubwayArrivalUseCase(cleanStationName);
              final filteredArrivals = _filterArrivalsByLine(allArrivals, stationName);
              allTransferArrivals.add(filteredArrivals);
              print('✅ 환승지 ${i + 1} 지하철 도착정보 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
            } else {
              allTransferArrivals.add([]);
            }
          } catch (e) {
            print('❌ 환승지 ${i + 1} 도착정보 로딩 오류: $e');
            allTransferArrivals.add([]);
          }
        } else {
          allTransferArrivals.add([]);
        }
      }

      transferArrivalInfo.value = allTransferArrivals;
    } catch (e) {
      transferArrivalError.value = '환승지 도착정보 로딩 실패';
      print('❌ 환승지 도착정보 전체 로딩 오류: $e');
    } finally {
      isLoadingTransferArrival.value = false;
    }
  }

  // 도착지 실시간 도착정보 로딩
  Future<void> loadDestinationArrivalInfo(String arrivalStationName, String activeRouteId) async {
    if (arrivalStationName.isEmpty) return;

    final savedRoutes = _storage.read<List>('saved_routes');
    Map<String, dynamic>? destinationData;

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      Map<String, dynamic>? activeRoute;

      try {
        activeRoute = savedRoutes.firstWhere(
          (route) => (route as Map)['id'] == activeRouteId,
        ) as Map<String, dynamic>;
      } catch (e) {
        activeRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
      }

      destinationData = activeRoute['arrival'] as Map<String, dynamic>?;
    }

    if (destinationData == null) {
      print('⚠️ 도착지 상세 데이터를 찾을 수 없습니다');
      return;
    }

    final type = destinationData['type'] ?? 'subway';
    final stationCode = destinationData['code'] ?? '';
    final lineInfo = destinationData['lineInfo'] ?? '';

    print('🚦 도착지 도착정보 로딩 시작: ${destinationData['name']} (type: $type, code: $stationCode)');

    try {
      isLoadingDestinationArrival.value = true;
      destinationArrivalError.value = '';

      if (type == 'bus') {
        await _loadBusArrivalInfo('destination', destinationData);
        destinationArrivalInfo.clear();
      } else if (type == 'subway') {
        await _loadSubwayArrivalInfo('destination', destinationData);
        String cleanStationName = _cleanStationName(arrivalStationName);
        final allArrivals = await getSubwayArrivalUseCase(cleanStationName);
        final filteredArrivals = _filterArrivalsByLine(allArrivals, arrivalStationName);

        if (filteredArrivals.isNotEmpty) {
          destinationArrivalInfo.value = filteredArrivals;
          print('✅ 도착지 지하철 도착정보 로딩 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
        } else {
          destinationArrivalInfo.clear();
          destinationArrivalError.value = '도착정보가 없습니다';
          print('⚠️ 도착지 지하철 도착정보 없음 (전체 ${allArrivals.length}개 → 필터링 후 0개)');
        }
      }
    } catch (e) {
      destinationArrivalError.value = '도착정보 로딩 실패';
      destinationArrivalInfo.clear();
      print('❌ 도착지 도착정보 로딩 오류: $e');
    } finally {
      isLoadingDestinationArrival.value = false;
    }
  }
}