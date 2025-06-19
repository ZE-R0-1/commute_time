import 'dart:async';
import 'package:get/get.dart';

import 'models/route_detail.dart';
import 'models/route_step.dart';
import 'models/transport_mode.dart';

class RouteDetailController extends GetxController {
  // 상태 관리
  final Rx<RouteDetail?> currentRoute = Rx<RouteDetail?>(null);
  final RxList<RouteDetail> alternativeRoutes = <RouteDetail>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedRouteId = ''.obs;
  final RxString routeType = ''.obs;

  // 실시간 업데이트용 타이머
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();

    // arguments에서 경로 타입과 ID 가져오기
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    routeType.value = args['routeType'] ?? 'morning';
    selectedRouteId.value = args['routeId'] ?? 'route_1';

    print('=== 경로 상세 컨트롤러 초기화 ===');
    print('경로 타입: ${routeType.value}');
    print('경로 ID: ${selectedRouteId.value}');

    // 경로 데이터 로드
    loadRouteDetail();

    // 실시간 업데이트 시작 (30초마다)
    startRealTimeUpdates();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  // 경로 상세 정보 로드
  Future<void> loadRouteDetail() async {
    isLoading.value = true;

    try {
      print('=== 경로 데이터 로딩 시작 ===');

      // 시뮬레이션: API 호출 지연
      await Future.delayed(const Duration(milliseconds: 800));

      // 더미 데이터 생성
      currentRoute.value = _generateDummyRoute(selectedRouteId.value);
      alternativeRoutes.value = _generateAlternativeRoutes();

      print('=== 경로 데이터 로딩 완료 ===');
      print('메인 경로: ${currentRoute.value?.routeName}');
      print('대안 경로 수: ${alternativeRoutes.length}');

    } catch (e) {
      print('경로 데이터 로드 오류: $e');
      Get.snackbar(
        '오류',
        '경로 정보를 불러올 수 없습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 대안 경로 선택
  void selectAlternativeRoute(String routeId) {
    final selectedRoute = alternativeRoutes.firstWhereOrNull(
          (route) => route.routeId == routeId,
    );

    if (selectedRoute != null) {
      // 현재 경로를 대안 목록에 추가
      if (currentRoute.value != null) {
        alternativeRoutes.insert(0, currentRoute.value!);
      }

      // 선택된 경로를 현재 경로로 설정
      currentRoute.value = selectedRoute;
      alternativeRoutes.remove(selectedRoute);
      selectedRouteId.value = routeId;

      print('=== 경로 변경 ===');
      print('새 경로: ${selectedRoute.routeName}');
    }
  }

  // 실시간 정보 업데이트
  Future<void> refreshRealTimeInfo() async {
    if (currentRoute.value == null) return;

    print('=== 실시간 정보 업데이트 ===');

    // 시뮬레이션: 일부 단계에 지연 정보 추가
    final updatedSteps = currentRoute.value!.steps.map((step) {
      // 30% 확률로 지하철/버스에 지연 발생
      if ((step.mode == TransportMode.subway || step.mode == TransportMode.bus) &&
          DateTime.now().millisecond % 10 < 3) {
        return step.copyWith(
          isDelayed: true,
          delayMessage: '${step.mode.displayName} 지연 (2-3분)',
          duration: step.duration + 2,
        );
      }
      return step.copyWith(isDelayed: false, delayMessage: null);
    }).toList();

    currentRoute.value = currentRoute.value!.copyWith(
      steps: updatedSteps,
      lastUpdated: DateTime.now(),
    );
  }

  // 실시간 업데이트 시작
  void startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshRealTimeInfo();
    });
  }

  // 더미 경로 데이터 생성
  RouteDetail _generateDummyRoute(String routeId) {
    final now = DateTime.now();
    final isEvening = routeType.value == 'evening';

    if (isEvening) {
      return RouteDetail(
        routeId: routeId,
        routeName: '최단시간',
        origin: '서초구 서초대로 456 (회사)',
        destination: '강남구 테헤란로 123 (집)',
        departureTime: DateTime(now.year, now.month, now.day, 18, 0),
        arrivalTime: DateTime(now.year, now.month, now.day, 18, 47),
        totalDuration: 47,
        totalCost: 1470,
        totalDistance: 8200,
        routeType: 'evening',
        description: '환승 1회, 지하철 중심 경로',
        hasRealTimeInfo: true,
        lastUpdated: now,
        steps: [
          RouteStep(
            id: 'step_1',
            mode: TransportMode.walk,
            instruction: '서초역까지 도보',
            duration: 5,
            distance: 400,
            startLocation: '서초구 서초대로 456',
            endLocation: '서초역 3번 출구',
            details: {},
            cost: 0,
          ),
          RouteStep(
            id: 'step_2',
            mode: TransportMode.subway,
            instruction: '2호선 서초역 → 강남역',
            duration: 8,
            distance: 6200,
            startLocation: '서초역',
            endLocation: '강남역',
            details: {
              'line': '2호선',
              'station': '서초역 → 강남역',
              'direction': '잠실 방면',
            },
            departureTime: DateTime(now.year, now.month, now.day, 18, 5),
            arrivalTime: DateTime(now.year, now.month, now.day, 18, 13),
            cost: 1370,
          ),
          RouteStep(
            id: 'step_3',
            mode: TransportMode.transfer,
            instruction: '강남역에서 신분당선으로 환승',
            duration: 3,
            distance: 200,
            startLocation: '강남역 (2호선)',
            endLocation: '강남역 (신분당선)',
            details: {
              'transferInfo': '2호선 → 신분당선',
              'station': '강남역',
            },
            cost: 0,
          ),
          RouteStep(
            id: 'step_4',
            mode: TransportMode.subway,
            instruction: '신분당선 강남역 → 선릉역',
            duration: 4,
            distance: 1100,
            startLocation: '강남역 (신분당선)',
            endLocation: '선릉역',
            details: {
              'line': '신분당선',
              'station': '강남역 → 선릉역',
              'direction': '정자 방면',
            },
            departureTime: DateTime(now.year, now.month, now.day, 18, 16),
            arrivalTime: DateTime(now.year, now.month, now.day, 18, 20),
            cost: 100,
          ),
          RouteStep(
            id: 'step_5',
            mode: TransportMode.walk,
            instruction: '선릉역에서 목적지까지 도보',
            duration: 27,
            distance: 500,
            startLocation: '선릉역 1번 출구',
            endLocation: '강남구 테헤란로 123',
            details: {},
            cost: 0,
          ),
        ],
      );
    } else {
      return RouteDetail(
        routeId: routeId,
        routeName: '최단시간',
        origin: '강남구 테헤란로 123 (집)',
        destination: '서초구 서초대로 456 (회사)',
        departureTime: DateTime(now.year, now.month, now.day, 8, 7),
        arrivalTime: DateTime(now.year, now.month, now.day, 8, 52),
        totalDuration: 45,
        totalCost: 1470,
        totalDistance: 8200,
        routeType: 'morning',
        description: '환승 1회, 지하철 중심 경로',
        hasRealTimeInfo: true,
        lastUpdated: now,
        steps: [
          RouteStep(
            id: 'step_1',
            mode: TransportMode.walk,
            instruction: '선릉역까지 도보',
            duration: 6,
            distance: 500,
            startLocation: '강남구 테헤란로 123',
            endLocation: '선릉역 1번 출구',
            details: {},
            cost: 0,
          ),
          RouteStep(
            id: 'step_2',
            mode: TransportMode.subway,
            instruction: '신분당선 선릉역 → 강남역',
            duration: 4,
            distance: 1100,
            startLocation: '선릉역',
            endLocation: '강남역 (신분당선)',
            details: {
              'line': '신분당선',
              'station': '선릉역 → 강남역',
              'direction': '광교 방면',
            },
            departureTime: DateTime(now.year, now.month, now.day, 8, 13),
            arrivalTime: DateTime(now.year, now.month, now.day, 8, 17),
            cost: 100,
          ),
          RouteStep(
            id: 'step_3',
            mode: TransportMode.transfer,
            instruction: '강남역에서 2호선으로 환승',
            duration: 3,
            distance: 200,
            startLocation: '강남역 (신분당선)',
            endLocation: '강남역 (2호선)',
            details: {
              'transferInfo': '신분당선 → 2호선',
              'station': '강남역',
            },
            cost: 0,
          ),
          RouteStep(
            id: 'step_4',
            mode: TransportMode.subway,
            instruction: '2호선 강남역 → 서초역',
            duration: 8,
            distance: 6200,
            startLocation: '강남역 (2호선)',
            endLocation: '서초역',
            details: {
              'line': '2호선',
              'station': '강남역 → 서초역',
              'direction': '신도림 방면',
            },
            departureTime: DateTime(now.year, now.month, now.day, 8, 20),
            arrivalTime: DateTime(now.year, now.month, now.day, 8, 28),
            cost: 1370,
          ),
          RouteStep(
            id: 'step_5',
            mode: TransportMode.walk,
            instruction: '서초역에서 회사까지 도보',
            duration: 24,
            distance: 400,
            startLocation: '서초역 3번 출구',
            endLocation: '서초구 서초대로 456',
            details: {},
            cost: 0,
          ),
        ],
      );
    }
  }

  // 대안 경로들 생성
  List<RouteDetail> _generateAlternativeRoutes() {
    final now = DateTime.now();
    final isEvening = routeType.value == 'evening';

    return [
      // 저렴한 경로 (버스 이용)
      RouteDetail(
        routeId: 'route_cheap',
        routeName: '최저요금',
        origin: isEvening ? '서초구 서초대로 456 (회사)' : '강남구 테헤란로 123 (집)',
        destination: isEvening ? '강남구 테헤란로 123 (집)' : '서초구 서초대로 456 (회사)',
        departureTime: isEvening
            ? DateTime(now.year, now.month, now.day, 18, 0)
            : DateTime(now.year, now.month, now.day, 8, 5),
        arrivalTime: isEvening
            ? DateTime(now.year, now.month, now.day, 18, 58)
            : DateTime(now.year, now.month, now.day, 8, 58),
        totalDuration: 58,
        totalCost: 1200,
        totalDistance: 9100,
        routeType: routeType.value,
        description: '버스 이용, 환승 없음',
        hasRealTimeInfo: true,
        lastUpdated: now,
        steps: [
          RouteStep(
            id: 'alt_step_1',
            mode: TransportMode.walk,
            instruction: '버스정류장까지 도보',
            duration: 8,
            distance: 300,
            startLocation: isEvening ? '서초구 서초대로 456' : '강남구 테헤란로 123',
            endLocation: '버스정류장',
            details: {},
            cost: 0,
          ),
          RouteStep(
            id: 'alt_step_2',
            mode: TransportMode.bus,
            instruction: '146번 버스 이용',
            duration: 42,
            distance: 8500,
            startLocation: '출발 정류장',
            endLocation: '도착 정류장',
            details: {
              'busNumber': '146',
              'station': '광역버스',
            },
            cost: 1200,
          ),
          RouteStep(
            id: 'alt_step_3',
            mode: TransportMode.walk,
            instruction: '버스정류장에서 목적지까지 도보',
            duration: 8,
            distance: 300,
            startLocation: '버스정류장',
            endLocation: isEvening ? '강남구 테헤란로 123' : '서초구 서초대로 456',
            details: {},
            cost: 0,
          ),
        ],
      ),

      // 편안한 경로 (환승 최소화)
      RouteDetail(
        routeId: 'route_comfort',
        routeName: '편안한 경로',
        origin: isEvening ? '서초구 서초대로 456 (회사)' : '강남구 테헤란로 123 (집)',
        destination: isEvening ? '강남구 테헤란로 123 (집)' : '서초구 서초대로 456 (회사)',
        departureTime: isEvening
            ? DateTime(now.year, now.month, now.day, 18, 0)
            : DateTime(now.year, now.month, now.day, 8, 10),
        arrivalTime: isEvening
            ? DateTime(now.year, now.month, now.day, 18, 53)
            : DateTime(now.year, now.month, now.day, 8, 55),
        totalDuration: 53,
        totalCost: 1570,
        totalDistance: 8800,
        routeType: routeType.value,
        description: '택시 구간 포함, 환승 없음',
        hasRealTimeInfo: true,
        lastUpdated: now,
        steps: [
          RouteStep(
            id: 'comfort_step_1',
            mode: TransportMode.taxi,
            instruction: '택시로 지하철역까지 이동',
            duration: 12,
            distance: 2200,
            startLocation: isEvening ? '서초구 서초대로 456' : '강남구 테헤란로 123',
            endLocation: '지하철역',
            details: {},
            cost: 4500,
          ),
          RouteStep(
            id: 'comfort_step_2',
            mode: TransportMode.subway,
            instruction: '지하철 이용',
            duration: 35,
            distance: 6200,
            startLocation: '지하철역',
            endLocation: '도착역',
            details: {
              'line': '3호선',
              'station': '직통 운행',
            },
            cost: 1370,
          ),
          RouteStep(
            id: 'comfort_step_3',
            mode: TransportMode.walk,
            instruction: '지하철역에서 목적지까지 도보',
            duration: 6,
            distance: 400,
            startLocation: '도착역',
            endLocation: isEvening ? '강남구 테헤란로 123' : '서초구 서초대로 456',
            details: {},
            cost: 0,
          ),
        ],
      ),
    ];
  }

  // 길찾기 시작 (외부 앱 연동)
  void startNavigation() {
    // TODO: 카카오맵/네이버맵 등 외부 앱으로 길찾기 연동
    Get.snackbar(
      '길찾기',
      '카카오맵으로 연결합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }

  // 즐겨찾기 추가
  void addToFavorites() {
    // TODO: 즐겨찾기 기능 구현
    Get.snackbar(
      '즐겨찾기',
      '경로가 즐겨찾기에 추가되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Get.theme.colorScheme.onPrimary,
    );
  }
}