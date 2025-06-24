import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 🆕 위치 및 날씨 서비스 import
import '../../app/services/location_service.dart';
import '../../app/services/weather_service.dart';

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 사용자 정보
  final RxString userName = ''.obs;
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = '09:00'.obs;
  final RxString workEndTime = '18:00'.obs;

  // 🆕 실제 위치 정보
  final Rx<UserLocation?> currentLocation = Rx<UserLocation?>(null);
  final RxBool isLocationLoading = true.obs;

  // 🆕 위치 기반 날씨 정보
  final Rx<WeatherInfo?> currentWeather = Rx<WeatherInfo?>(null);
  final RxList<WeatherForecast> weatherForecast = <WeatherForecast>[].obs;

  // UI 표시용 날씨 정보 (기존 코드와 호환성 유지)
  final RxString weatherInfo = '위치 확인 중...'.obs;
  final RxString weatherAdvice = '현재 위치를 조회하고 있습니다'.obs;

  // 출근 정보
  final RxString recommendedDepartureTime = '8:15 출발 권장'.obs;
  final RxString commuteRoute = '집 → 2호선 → 9호선 → 회사'.obs;
  final RxString estimatedTime = '52분'.obs;
  final RxString transportFee = '1,370원'.obs;

  // 퇴근 정보
  final RxString recommendedOffTime = '6:10 퇴근 권장'.obs;
  final RxString eveningSchedule = '7시 강남 약속 시간 고려'.obs;
  final RxString bufferTime = '40분'.obs;

  // 교통 상황
  final RxList<TransportStatus> transportStatus = <TransportStatus>[].obs;

  // 로딩 상태
  final RxBool isLoading = false.obs;
  final RxBool isWeatherLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeTransportStatus();
    _loadTodayData();
    _initializeLocation(); // 🆕 위치 초기화
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    // 온보딩에서 저장한 데이터 불러오기
    homeAddress.value = _storage.read('home_address') ?? '서울특별시 강남구';
    workAddress.value = _storage.read('work_address') ?? '서울특별시 마포구';
    workStartTime.value = _storage.read('work_start_time') ?? '09:00';
    workEndTime.value = _storage.read('work_end_time') ?? '18:00';

    // Mock 사용자 이름
    userName.value = '김출근';

    print('사용자 데이터 로드 완료');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
    print('근무시간: ${workStartTime.value} ~ ${workEndTime.value}');
  }

  // 🆕 위치 초기화 및 날씨 조회
  Future<void> _initializeLocation() async {
    try {
      isLocationLoading.value = true;
      isWeatherLoading.value = true;

      print('=== GPS 위치 조회 시작 ===');

      // 1. 마지막 위치 먼저 확인 (빠른 응답)
      final lastLocation = await LocationService.getLastKnownLocation();
      if (lastLocation != null) {
        currentLocation.value = lastLocation;
        weatherInfo.value = '${lastLocation.address} 기준 날씨 조회 중...';

        // 마지막 위치로 먼저 날씨 조회
        _loadWeatherForLocation(lastLocation);
      }

      // 2. 현재 위치 정확히 조회
      final location = await LocationService.getCurrentLocation();

      if (location != null) {
        currentLocation.value = location;

        // GPS 정확도에 따른 메시지
        final accuracyMsg = location.accuracyStatus == LocationAccuracyStatus.excellent
            ? '정확한 위치'
            : location.accuracyText;

        weatherInfo.value = '📍 ${location.address} ($accuracyMsg)';

        print('GPS 위치 확인: ${location.address}');
        print('좌표: ${location.latitude}, ${location.longitude}');
        print('정확도: ${location.accuracyText}');

        // 저장소에 위치 저장
        _storage.write('current_latitude', location.latitude);
        _storage.write('current_longitude', location.longitude);
        _storage.write('current_address', location.address);

        // 현재 위치로 날씨 조회
        await _loadWeatherForLocation(location);

      } else {
        // GPS 조회 실패시 기본 위치 사용 (강남역)
        print('GPS 조회 실패 - 기본 위치 사용');
        await _useDefaultLocation();
      }

    } catch (e) {
      print('위치 초기화 오류: $e');
      await _useDefaultLocation();
    } finally {
      isLocationLoading.value = false;
    }
  }

  // 🆕 기본 위치 사용 (GPS 실패시)
  Future<void> _useDefaultLocation() async {
    final defaultLocation = UserLocation(
      latitude: 37.498095, // 강남역
      longitude: 127.027610,
      address: '강남역 (기본위치)',
      accuracy: 1000,
      timestamp: DateTime.now(),
    );

    currentLocation.value = defaultLocation;
    weatherInfo.value = '📍 ${defaultLocation.address}';
    weatherAdvice.value = 'GPS 권한을 허용하면 현재 위치 날씨를 확인할 수 있어요';

    await _loadWeatherForLocation(defaultLocation);
  }

  // 🆕 특정 위치의 날씨 조회
  Future<void> _loadWeatherForLocation(UserLocation location) async {
    try {
      isWeatherLoading.value = true;

      print('날씨 조회 시작: ${location.address}');

      // 현재 날씨 조회
      final weatherData = await WeatherService.getCurrentWeather(
          location.latitude,
          location.longitude
      );

      if (weatherData != null) {
        currentWeather.value = weatherData;

        // UI 표시용 텍스트 업데이트
        weatherInfo.value = '${weatherData.weatherEmoji} ${weatherData.weatherDescription} ${weatherData.temperature.round()}°C';
        weatherAdvice.value = weatherData.advice;

        print('날씨 조회 성공: ${weatherData.weatherDescription} ${weatherData.temperature}°C');
      } else {
        // API 오류시
        weatherInfo.value = '🌤️ 날씨 정보를 불러올 수 없습니다';
        weatherAdvice.value = '잠시 후 다시 시도해주세요';
        print('날씨 조회 실패');
      }

      // 날씨 예보 조회
      final forecastData = await WeatherService.getWeatherForecast(
          location.latitude,
          location.longitude
      );

      if (forecastData.isNotEmpty) {
        weatherForecast.value = forecastData;
        print('날씨 예보 조회 성공: ${forecastData.length}개');

        // 오늘 비 예보 확인
        _checkRainForecast(forecastData);
      }

    } catch (e) {
      print('날씨 조회 오류: $e');
      weatherInfo.value = '🌤️ 날씨 정보 오류';
      weatherAdvice.value = '잠시 후 다시 시도해주세요';
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // 🆕 위치 새로고침 (사용자가 수동으로 호출)
  Future<void> refreshLocation() async {
    await _initializeLocation();

    final location = currentLocation.value;
    if (location != null) {
      Get.snackbar(
        '위치 업데이트 완료',
        '📍 ${location.address}\n${location.accuracyText}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.location_on, color: Colors.white),
      );
    }
  }

  // 🆕 비 예보 확인 및 조언 업데이트
  void _checkRainForecast(List<WeatherForecast> forecasts) {
    final today = DateTime.now();
    final todayForecasts = forecasts.where((forecast) =>
    forecast.dateTime.day == today.day &&
        forecast.dateTime.month == today.month
    ).toList();

    bool willRain = todayForecasts.any((forecast) =>
    forecast.precipitationType == PrecipitationType.rain ||
        forecast.precipitationType == PrecipitationType.rainDrop
    );

    if (willRain && currentWeather.value?.precipitationType == PrecipitationType.none) {
      // 현재는 안 비지만 오늘 비 예보가 있는 경우
      weatherInfo.value = '🌧️ 오늘 오후 비 예보';
      weatherAdvice.value = '우산을 챙기시고 조기 출발을 권장드려요';
    }
  }

  // 교통 상황 초기화
  void _initializeTransportStatus() {
    transportStatus.value = [
      TransportStatus(
        name: '지하철',
        icon: Icons.train,
        status: TransportStatusType.normal,
        statusText: '정상 운행',
        color: Colors.green,
      ),
      TransportStatus(
        name: '버스',
        icon: Icons.directions_bus,
        status: TransportStatusType.delayed,
        statusText: '약간 지연',
        color: Colors.orange,
      ),
      TransportStatus(
        name: '도로',
        icon: Icons.local_taxi,
        status: TransportStatusType.heavy,
        statusText: '정체 심함',
        color: Colors.red,
      ),
      TransportStatus(
        name: '따릉이',
        icon: Icons.pedal_bike,
        status: TransportStatusType.normal,
        statusText: '이용 가능',
        color: Colors.blue,
      ),
    ];
  }

  // 오늘 데이터 로드 (교통 정보 등)
  Future<void> _loadTodayData() async {
    isLoading.value = true;

    try {
      // Mock: API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 현재 시간에 따른 동적 메시지
      final now = DateTime.now();
      final hour = now.hour;

      if (hour < 12) {
        _updateMorningData();
      } else if (hour < 18) {
        _updateAfternoonData();
      } else {
        _updateEveningData();
      }

      print('교통 데이터 로드 완료: ${hour}시');

    } catch (e) {
      print('교통 데이터 로드 오류: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateMorningData() {
    recommendedDepartureTime.value = '8:15 출발 권장';
    commuteRoute.value = '집 → 2호선 → 9호선 → 회사';
    estimatedTime.value = '52분';
    transportFee.value = '1,370원';
  }

  void _updateAfternoonData() {
    recommendedDepartureTime.value = '이미 출근 시간 지남';
    estimatedTime.value = '평균 45분';
    recommendedOffTime.value = '6:10 퇴근 권장';
    eveningSchedule.value = '7시 강남 약속 시간 고려';
    bufferTime.value = '40분';
  }

  void _updateEveningData() {
    recommendedDepartureTime.value = '내일 출근 준비';
    recommendedOffTime.value = '퇴근 완료';
    eveningSchedule.value = '수고하셨습니다!';
  }

  // 인사말 생성
  String get greetingMessage {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return '좋은 새벽이에요! 🌙';
    } else if (hour < 12) {
      return '좋은 아침이에요! 👋';
    } else if (hour < 18) {
      return '좋은 오후에요! ☀️';
    } else {
      return '좋은 저녁이에요! 🌆';
    }
  }

  // 서브 텍스트 (위치 기반 메시지 추가)
  String get subGreetingMessage {
    final hour = DateTime.now().hour;
    final location = currentLocation.value;

    String baseMessage;
    if (hour < 6) {
      baseMessage = '일찍 일어나셨네요. 충분한 휴식 취하세요';
    } else if (hour < 12) {
      baseMessage = '오늘도 안전한 출퇴근 되세요';
    } else if (hour < 18) {
      baseMessage = '오후도 힘내세요!';
    } else {
      baseMessage = '하루 수고 많으셨어요';
    }

    // 위치 정보가 있으면 추가
    if (location != null && !location.address.contains('기본위치')) {
      return '$baseMessage\n📍 ${location.address}';
    }

    return baseMessage;
  }

  // 🆕 날씨 새로고침 (위치 유지)
  Future<void> refreshWeather() async {
    final location = currentLocation.value;
    if (location != null) {
      await _loadWeatherForLocation(location);
    } else {
      await _initializeLocation();
    }
  }

  // 전체 새로고침 (위치 + 날씨 + 교통)
  Future<void> refresh() async {
    await Future.wait([
      _loadTodayData(),
      refreshLocation(), // 위치도 새로 조회
    ]);

    Get.snackbar(
      '새로고침 완료',
      '최신 위치, 날씨, 교통 정보를 불러왔습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  // 경로 상세 화면 네비게이션
  void showCommuteRouteDetail() {
    print('출근 경로 상세 화면으로 이동');

    Get.toNamed('/route-detail', arguments: {
      'type': 'commute',
      'title': '출근 경로 상세',
      'departureTime': '8:15',
      'duration': estimatedTime.value,
      'cost': transportFee.value,
    });
  }

  void showReturnRouteDetail() {
    print('퇴근 경로 상세 화면으로 이동');

    Get.toNamed('/route-detail', arguments: {
      'type': 'return',
      'title': '퇴근 경로 상세',
      'departureTime': '18:10',
      'duration': '48분',
      'cost': transportFee.value,
    });
  }
}

// 교통 상황 모델 (기존과 동일)
class TransportStatus {
  final String name;
  final IconData icon;
  final TransportStatusType status;
  final String statusText;
  final Color color;

  TransportStatus({
    required this.name,
    required this.icon,
    required this.status,
    required this.statusText,
    required this.color,
  });
}

enum TransportStatusType {
  normal,   // 정상
  delayed,  // 지연
  heavy,    // 심함
  closed,   // 중단
}