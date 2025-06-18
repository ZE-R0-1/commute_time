import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/routes/app_pages.dart';

enum CommuteStatus {
  beforeWork,   // 출근 전
  goingToWork,  // 출근 중
  atWork,       // 회사에 있음
  goingHome,    // 퇴근 중
  atHome,       // 집에 있음
}

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 사용자 정보
  final RxString userName = ''.obs;
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = ''.obs;
  final RxString workEndTime = ''.obs;

  // 현재 상태
  final Rx<CommuteStatus> currentStatus = CommuteStatus.beforeWork.obs;
  final RxString currentLocation = ''.obs;
  final RxString currentWeather = ''.obs;
  final RxInt currentTemp = 0.obs;

  // 교통 정보
  final RxString recommendedRoute = ''.obs;
  final RxInt estimatedTime = 0.obs;
  final RxString trafficCondition = ''.obs;
  final RxList<Map<String, dynamic>> trafficAlerts = <Map<String, dynamic>>[].obs;

  // 이번 주 통계
  final RxMap<String, dynamic> weeklyStats = <String, dynamic>{}.obs;

  // 로딩 상태
  final RxBool isLoadingWeather = false.obs;
  final RxBool isLoadingTraffic = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateCurrentStatus();
    _loadWeatherInfo();
    _loadTrafficInfo();
    _loadWeeklyStats();

    // 30초마다 상태 업데이트
    _startPeriodicUpdate();
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    userName.value = _storage.read('user_name') ?? '사용자';
    homeAddress.value = _storage.read('home_address') ?? '';
    workAddress.value = _storage.read('work_address') ?? '';
    workStartTime.value = _storage.read('work_start_time') ?? '09:00';
    workEndTime.value = _storage.read('work_end_time') ?? '18:00';

    print('=== 홈 화면 데이터 로드 ===');
    print('사용자: ${userName.value}');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
    print('근무시간: ${workStartTime.value} ~ ${workEndTime.value}');
  }

  // 현재 출퇴근 상태 업데이트
  void _updateCurrentStatus() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    // Mock: 시간대별 상태 결정
    final workStart = _parseTimeOfDay(workStartTime.value);
    final workEnd = _parseTimeOfDay(workEndTime.value);

    if (_isTimeBefore(currentTime, workStart)) {
      // 출근 시간 전
      if (_isTimeAfter(currentTime, TimeOfDay(hour: workStart.hour - 1, minute: 0))) {
        currentStatus.value = CommuteStatus.goingToWork; // 출근 1시간 전부터는 출근 중으로 가정
      } else {
        currentStatus.value = CommuteStatus.beforeWork;
      }
    } else if (_isTimeBetween(currentTime, workStart, workEnd)) {
      // 근무 시간 중
      currentStatus.value = CommuteStatus.atWork;
    } else if (_isTimeAfter(currentTime, workEnd)) {
      // 퇴근 시간 후
      if (_isTimeBefore(currentTime, TimeOfDay(hour: workEnd.hour + 1, minute: 0))) {
        currentStatus.value = CommuteStatus.goingHome; // 퇴근 1시간 내는 퇴근 중으로 가정
      } else {
        currentStatus.value = CommuteStatus.atHome;
      }
    }

    print('현재 상태: ${currentStatus.value}');
  }

  // 날씨 정보 로드 (Mock)
  Future<void> _loadWeatherInfo() async {
    try {
      isLoadingWeather.value = true;

      // Mock: 날씨 API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // Mock 날씨 데이터
      final mockWeather = [
        {'location': '강남구', 'weather': '맑음', 'temp': 23},
        {'location': '서초구', 'weather': '흐림', 'temp': 21},
        {'location': '마포구', 'weather': '비', 'temp': 18},
        {'location': '용산구', 'weather': '눈', 'temp': -2},
      ];

      final random = mockWeather[DateTime.now().millisecond % mockWeather.length];
      currentLocation.value = random['location'] as String;
      currentWeather.value = random['weather'] as String;
      currentTemp.value = random['temp'] as int;

    } catch (e) {
      print('날씨 정보 로드 오류: $e');
      // 기본값 설정
      currentLocation.value = '서울';
      currentWeather.value = '맑음';
      currentTemp.value = 20;
    } finally {
      isLoadingWeather.value = false;
    }
  }

  // 교통 정보 로드 (Mock)
  Future<void> _loadTrafficInfo() async {
    try {
      isLoadingTraffic.value = true;

      // Mock: 교통 API 호출 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock 교통 데이터
      final routes = [
        {'name': '강남대로 경유', 'time': 35, 'condition': '원활'},
        {'name': '테헤란로 경유', 'time': 42, 'condition': '지체'},
        {'name': '한강대로 경유', 'time': 28, 'condition': '원활'},
        {'name': '올림픽대로 경유', 'time': 55, 'condition': '정체'},
      ];

      final random = routes[DateTime.now().second % routes.length];
      recommendedRoute.value = random['name'] as String;
      estimatedTime.value = random['time'] as int;
      trafficCondition.value = random['condition'] as String;

      // Mock 교통 알림
      trafficAlerts.value = [
        {
          'type': 'accident',
          'location': '강남역 사거리',
          'description': '교통사고로 인한 지체',
          'severity': 'medium',
        },
        {
          'type': 'construction',
          'location': '테헤란로 일대',
          'description': '도로 공사로 인한 차선 축소',
          'severity': 'low',
        },
      ];

    } catch (e) {
      print('교통 정보 로드 오류: $e');
    } finally {
      isLoadingTraffic.value = false;
    }
  }

  // 이번 주 통계 로드 (Mock)
  Future<void> _loadWeeklyStats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 통계 데이터
    weeklyStats.value = {
      'average_commute_time': 38, // 평균 출퇴근 시간 (분)
      'total_distance': 147,      // 총 이동 거리 (km)
      'on_time_percentage': 85,   // 정시 출근 비율 (%)
      'early_departure_count': 3, // 일찍 퇴근한 날
      'late_arrival_count': 1,    // 늦게 출근한 날
      'best_route': '강남대로 경유',
      'worst_day': '화요일',
      'best_day': '금요일',
    };
  }

  // 새로고침
  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;

      await Future.wait([
        _loadWeatherInfo(),
        _loadTrafficInfo(),
        _loadWeeklyStats(),
      ]);

      _updateCurrentStatus();

      Get.snackbar(
        '새로고침 완료',
        '최신 정보로 업데이트되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 1),
        icon: const Icon(Icons.refresh, color: Colors.white),
      );

    } catch (e) {
      print('새로고침 오류: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // 정기 업데이트 시작
  void _startPeriodicUpdate() {
    // 30초마다 상태 업데이트
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      _updateCurrentStatus();
    });

    // 5분마다 교통 정보 업데이트
    Stream.periodic(const Duration(minutes: 5)).listen((_) {
      _loadTrafficInfo();
    });
  }

  // 경로 안내 시작
  void startNavigation() {
    final destination = currentStatus.value == CommuteStatus.beforeWork ||
        currentStatus.value == CommuteStatus.goingToWork
        ? workAddress.value
        : homeAddress.value;

    Get.snackbar(
      '경로 안내 시작',
      '$destination으로 안내를 시작합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.navigation, color: Colors.white),
    );

    // TODO: 실제 지도 화면으로 이동
    // Get.toNamed(Routes.map);
  }

  // 지도 화면으로 이동
  void goToMap() {
    Get.toNamed(Routes.map);
  }

  // 분석 화면으로 이동
  void goToAnalysis() {
    Get.toNamed(Routes.analysis);
  }

  // 설정 화면으로 이동
  void goToSettings() {
    Get.toNamed(Routes.settings);
  }

  // 유틸리티 메서드들
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _isTimeBefore(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour < time2.hour ||
        (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour > time2.hour ||
        (time1.hour == time2.hour && time1.minute > time2.minute);
  }

  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    return !_isTimeBefore(time, start) && _isTimeBefore(time, end);
  }

  // 상태별 메시지
  String get statusMessage {
    switch (currentStatus.value) {
      case CommuteStatus.beforeWork:
        return '출근 준비를 시작하세요!';
      case CommuteStatus.goingToWork:
        return '출근 중입니다. 안전 운행하세요!';
      case CommuteStatus.atWork:
        return '회사에서 업무 중입니다.';
      case CommuteStatus.goingHome:
        return '퇴근 중입니다. 오늘 하루 수고하셨어요!';
      case CommuteStatus.atHome:
        return '집에서 휴식 중입니다.';
    }
  }

  // 상태별 아이콘
  IconData get statusIcon {
    switch (currentStatus.value) {
      case CommuteStatus.beforeWork:
        return Icons.home;
      case CommuteStatus.goingToWork:
        return Icons.directions_car;
      case CommuteStatus.atWork:
        return Icons.business;
      case CommuteStatus.goingHome:
        return Icons.directions_car;
      case CommuteStatus.atHome:
        return Icons.home;
    }
  }

  // 상태별 색상
  Color get statusColor {
    switch (currentStatus.value) {
      case CommuteStatus.beforeWork:
        return Colors.orange;
      case CommuteStatus.goingToWork:
        return Colors.blue;
      case CommuteStatus.atWork:
        return Colors.green;
      case CommuteStatus.goingHome:
        return Colors.purple;
      case CommuteStatus.atHome:
        return Colors.indigo;
    }
  }
}