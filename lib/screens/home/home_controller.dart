import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// 위치 및 날씨 서비스 import
import '../../app/services/location_service.dart';
import '../../app/services/weather_service.dart';

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 사용자 정보
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = '09:00'.obs;
  final RxString workEndTime = '18:00'.obs;

  // 실제 위치 정보
  final Rx<UserLocation?> currentLocation = Rx<UserLocation?>(null);
  final RxBool isLocationLoading = true.obs;

  // 위치 기반 날씨 정보
  final Rx<WeatherInfo?> currentWeather = Rx<WeatherInfo?>(null);
  final RxList<WeatherForecast> weatherForecast = <WeatherForecast>[].obs;

  // 🆕 상세 비 예보 정보
  final Rx<RainForecastInfo?> rainForecast = Rx<RainForecastInfo?>(null);


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
    _initializeLocation(); // 초기 로드만 자동 실행
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    // 온보딩에서 저장한 데이터 불러오기
    homeAddress.value = _storage.read('home_address') ?? '서울특별시 강남구';
    workAddress.value = _storage.read('work_address') ?? '서울특별시 마포구';
    workStartTime.value = _storage.read('work_start_time') ?? '09:00';
    workEndTime.value = _storage.read('work_end_time') ?? '18:00';


    print('사용자 데이터 로드 완료');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
    print('근무시간: ${workStartTime.value} ~ ${workEndTime.value}');
  }

  // 위치 초기화 및 날씨 조회 (초기 로드용)
  Future<void> _initializeLocation() async {
    try {
      isLocationLoading.value = true;
      isWeatherLoading.value = true;

      print('=== GPS 위치 조회 시작 (초기 로드) ===');

      // 1. 마지막 위치 먼저 확인 (빠른 응답)
      final lastLocation = await LocationService.getLastKnownLocation();
      if (lastLocation != null) {
        currentLocation.value = lastLocation;

        // 마지막 위치로 먼저 날씨 조회
        _loadWeatherForLocation(lastLocation);
      }

      // 2. 현재 위치 정확히 조회
      final location = await LocationService.getCurrentLocation();

      if (location != null) {
        currentLocation.value = location;


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

  // 기본 위치 사용 (GPS 실패시)
  Future<void> _useDefaultLocation() async {
    final defaultLocation = UserLocation(
      latitude: 37.498095, // 강남역
      longitude: 127.027610,
      address: '강남역 (기본위치)',
      accuracy: 1000,
      timestamp: DateTime.now(),
    );

    currentLocation.value = defaultLocation;

    await _loadWeatherForLocation(defaultLocation);
  }

  // 특정 위치의 날씨 조회
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
        print('날씨 조회 성공: ${weatherData.weatherDescription} ${weatherData.temperature}°C');
      } else {
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

        // 🆕 상세 비 예보 분석
        _analyzeDetailedRainForecast(forecastData);
      }

    } catch (e) {
      print('날씨 조회 오류: $e');
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // 🆕 상세 비 예보 분석
  void _analyzeDetailedRainForecast(List<WeatherForecast> forecasts) {
    try {
      final rainInfo = WeatherService.analyzeTodayRainForecast(forecasts);
      rainForecast.value = rainInfo;

      if (rainInfo != null && rainInfo.willRain) {
        print('=== 상세 비 예보 ===');
        print('메시지: ${rainInfo.message}');
        print('조언: ${rainInfo.advice}');
        if (rainInfo.startTime != null) {
          print('시작 시간: ${rainInfo.startTime}');
        }
        if (rainInfo.endTime != null) {
          print('종료 시간: ${rainInfo.endTime}');
        }
        print('강도: ${rainInfo.intensity}');
      } else if (rainInfo != null && !rainInfo.willRain) {
        print('=== 비 예보 없음 ===');
        print('메시지: ${rainInfo.message}');
      }
    } catch (e) {
      print('비 예보 분석 오류: $e');
    }
  }


  // 🔥 수동 전체 새로고침 (새로고침 버튼 전용)
  @override
  Future<void> refresh() async {
    print('=== 수동 전체 새로고침 시작 ===');

    await Future.wait([
      _loadTodayData(),       // 교통 정보 새로고침
      _initializeLocation(),  // 위치 + 날씨 + 비 예보 새로고침
    ]);

    print('최신 위치, 날씨, 교통 정보를 불러왔습니다.');

    final rain = rainForecast.value;
    if (rain != null && rain.willRain && rain.startTime != null) {
      final hour = rain.startTime!.hour;
      final timeStr = hour < 12 ? '오전 ${hour}시' :
      hour == 12 ? '정오' :
      hour < 18 ? '오후 ${hour - 12}시' : '저녁 ${hour - 12}시';
      print('☔ $timeStr부터 비 예보');
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