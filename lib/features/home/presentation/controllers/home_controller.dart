import 'package:get/get.dart';
import '../../../../core/models/weather_forecast.dart';
import '../../../../core/models/weather_info.dart';
import '../../../location_search/domain/entities/subway_arrival_entity.dart';
import 'weather_controller.dart';
import 'route_controller.dart';
import 'location_controller.dart';
import 'arrival_controller.dart';

/// Home 화면 통합 Controller
/// 개별 Controllers를 조합하여 화면의 전체 상태를 관리합니다
class HomeController extends GetxController {
  // Controllers
  late WeatherController weatherController;
  late RouteController routeController;
  late LocationController locationController;
  late ArrivalController arrivalController;

  @override
  void onInit() {
    super.onInit();
    print('=== 홈 화면 초기화 ===');

    // Controllers 초기화 (이미 binding에서 등록되어 있음)
    weatherController = Get.find<WeatherController>();
    routeController = Get.find<RouteController>();
    locationController = Get.find<LocationController>();
    arrivalController = Get.find<ArrivalController>();
  }

  @override
  void onReady() {
    super.onReady();
    print('홈 화면 준비 완료');
    // 경로 데이터를 먼저 로드한 후 날씨 데이터와 도착정보를 병렬로 로드
    Future.microtask(() => _initializeHomeScreen());
  }

  @override
  void onClose() {
    print('홈 화면 종료');
    super.onClose();
  }

  // 홈 화면 초기화 (경로 데이터를 먼저 로드한 후 날씨/도착정보를 로드)
  Future<void> _initializeHomeScreen() async {
    try {
      // 1. 경로 데이터를 먼저 로드 (필수)
      print('📍 [초기화] 1단계: 경로 데이터 로딩...');
      routeController.loadRouteData();

      // 2. 경로 데이터 로드 완료 후 날씨 데이터와 도착정보를 병렬로 로드
      print('📍 [초기화] 2단계: 날씨/도착정보 로딩...');
      await loadWeatherData();

      print('📍 [초기화] 완료!');
    } catch (e) {
      print('❌ 홈 화면 초기화 중 오류: $e');
    }
  }

  // 날씨 데이터 로딩
  Future<void> loadWeatherData() async {
    try {
      weatherController.isWeatherLoading.value = true;
      weatherController.weatherError.value = '';

      // 저장된 좌표 정보 확인
      final coordinates = locationController.getSavedCoordinates();

      // 좌표 준비
      Map<String, dynamic>? finalCoordinates = coordinates;
      if (finalCoordinates == null) {
        print('저장된 위치 정보가 없음. 현재 위치 요청 시작');
        final success = await locationController.requestCurrentLocation();

        if (!success) {
          weatherController.weatherError.value = '위치 정보를 가져올 수 없습니다';
          // 위치 실패해도 도착정보는 로드하도록 계속 진행
        } else {
          finalCoordinates = locationController.getSavedCoordinates();
        }
      } else {
        print('저장된 좌표 사용: ${finalCoordinates['latitude']}, ${finalCoordinates['longitude']}');
      }

      // 날씨 데이터와 도착정보를 병렬로 로드
      // 좌표가 있으면 날씨 데이터 로드, 없으면 에러 메시지만 표시
      if (finalCoordinates != null) {
        weatherController.loadingMessage.value = '날씨 정보 불러오는 중...';
        await Future.wait([
          weatherController.fetchWeatherData(
            finalCoordinates['latitude']!,
            finalCoordinates['longitude']!,
          ),
          loadAllArrivalInfo(),
        ]);
      } else {
        // 좌표를 얻지 못한 경우에도 도착정보는 로드
        await loadAllArrivalInfo();
      }
    } catch (e) {
      weatherController.weatherError.value = '날씨 정보를 불러오는데 실패했습니다';
      print('날씨 데이터 로딩 오류: $e');
    } finally {
      weatherController.isWeatherLoading.value = false;
    }
  }

  // 모든 역의 실시간 도착정보 로딩
  Future<void> loadAllArrivalInfo() async {
    if (!routeController.hasRouteData.value) {
      print('경로 데이터가 없어 도착정보를 로드할 수 없습니다');
      return;
    }

    print('📍 도착정보 로드 전:');
    print('   departureStation.value="${routeController.departureStation.value}"');
    print('   arrivalStation.value="${routeController.arrivalStation.value}"');
    print('   transferStations 개수: ${routeController.transferStations.length}');
    print('   activeRouteId="${routeController.activeRouteId.value}"');

    await arrivalController.loadAllArrivalInfo(
      departureStationName: routeController.departureStation.value,
      arrivalStationName: routeController.arrivalStation.value,
      transferStations: routeController.transferStations,
      activeRouteId: routeController.activeRouteId.value,
    );
  }

  // 날씨 새로고침
  Future<void> refreshWeather() async {
    print('날씨 데이터 새로고침 - 현재 위치로 갱신');
    weatherController.isWeatherLoading.value = true;
    weatherController.weatherError.value = '';

    try {
      final success = await locationController.requestCurrentLocation();

      if (!success) {
        weatherController.weatherError.value = '위치 정보를 다시 가져올 수 없습니다';
        return;
      }

      // 위치 요청 후 날씨 데이터 로드
      final coordinates = locationController.getSavedCoordinates();
      if (coordinates != null) {
        await weatherController.fetchWeatherData(
          coordinates['latitude']!,
          coordinates['longitude']!,
        );
      }
    } catch (e) {
      weatherController.weatherError.value = '날씨 정보를 새로고침하는데 실패했습니다';
      print('새로고침 오류: $e');
    } finally {
      weatherController.isWeatherLoading.value = false;
    }
  }

  // 경로 데이터 새로고침
  void refreshRouteData() {
    routeController.refreshRouteData();
  }

  // 경로 적용하기
  void applyRoute(String routeId) {
    routeController.applyRoute(routeId);
  }

  // 모든 도착정보 새로고침
  Future<void> refreshAllArrivalInfo() async {
    print('🔄 모든 도착정보 새로고침 시작');
    await arrivalController.refreshAllArrivalInfo(
      departureStationName: routeController.departureStation.value,
      arrivalStationName: routeController.arrivalStation.value,
      transferStations: routeController.transferStations,
      activeRouteId: routeController.activeRouteId.value,
    );
    print('✅ 모든 도착정보 새로고침 완료');
  }

  // 경로 설정 화면으로 이동
  void goToRouteSettings() {
    Get.toNamed('/route-setup');
  }

  // 앱 설정 페이지 열기
  Future<void> openAppSettings() async {
    await locationController.openAppSettings();
  }

  // 호선별 도착정보만 필터링
  List<SubwayArrivalEntity> getArrivalsByLine(String targetSubwayId) {
    return arrivalController.getArrivalsByLine(targetSubwayId);
  }

  // 호선별로 그룹화된 도착정보
  Map<String, List<SubwayArrivalEntity>> get groupedArrivalInfo {
    return arrivalController.groupedArrivalInfo;
  }

  // ===== RouteController 프록시 메서드 =====

  // 활성 경로 ID 접근
  RxString get activeRouteId {
    return routeController.activeRouteId;
  }

  // ===== 편의 메서드 (Controller 접근) =====

  // WeatherController 접근
  String getWeatherIcon(WeatherInfo? weather) {
    return weatherController.getWeatherIcon(weather);
  }

  String getWeatherIconForForecast(WeatherForecast forecast) {
    return weatherController.getWeatherIconForForecast(forecast);
  }

  String getWeatherStatusText(WeatherInfo? weather) {
    return weatherController.getWeatherStatusText(weather);
  }
}