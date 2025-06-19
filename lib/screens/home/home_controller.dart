import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 사용자 정보
  final RxString userName = ''.obs;
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = ''.obs;
  final RxString workEndTime = ''.obs;

  // 현재 시간 및 상태
  final Rx<DateTime> currentTime = DateTime.now().obs;
  final RxString currentGreeting = ''.obs;
  final RxString currentWeatherAlert = ''.obs;

  // 출퇴근 정보
  final RxString recommendedDepartureTime = ''.obs;
  final RxString morningRoute = ''.obs;
  final RxInt morningDuration = 0.obs;
  final RxInt morningCost = 0.obs;

  final RxString eveningDepartureTime = ''.obs;
  final RxString eveningNote = ''.obs;
  final RxInt eveningBuffer = 0.obs;

  // 교통 상황
  final RxString subwayStatus = '정상 운행'.obs;
  final RxString busStatus = '정상 운행'.obs;
  final Rx<Color> subwayStatusColor = Colors.green.obs;
  final Rx<Color> busStatusColor = Colors.green.obs;

  // 로딩 상태
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateCurrentTime();
    _generateRecommendations();
    _checkTrafficStatus();

    // 1분마다 시간 업데이트
    _startTimeUpdater();
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    // 온보딩에서 저장된 데이터 불러오기
    homeAddress.value = _storage.read('home_address') ?? '서울시 강남구 역삼동';
    workAddress.value = _storage.read('work_address') ?? '서울시 영등포구 여의도동';
    workStartTime.value = _storage.read('work_start_time') ?? '09:00';
    workEndTime.value = _storage.read('work_end_time') ?? '18:00';

    // Mock 사용자 이름 (실제로는 로그인 정보에서 가져옴)
    final loginUserData = _storage.read('user_data');
    if (loginUserData != null) {
      userName.value = loginUserData['name'] ?? '김출근';
    } else {
      userName.value = '김출근';
    }

    print('=== 홈 화면 사용자 데이터 로드 ===');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
    print('근무시간: ${workStartTime.value} - ${workEndTime.value}');
  }

  // 현재 시간 업데이트 및 인사말 생성
  void _updateCurrentTime() {
    currentTime.value = DateTime.now();
    final hour = currentTime.value.hour;

    if (hour >= 5 && hour < 12) {
      currentGreeting.value = '좋은 아침이에요! 👋';
    } else if (hour >= 12 && hour < 18) {
      currentGreeting.value = '좋은 오후예요! ☀️';
    } else if (hour >= 18 && hour < 22) {
      currentGreeting.value = '좋은 저녁이에요! 🌆';
    } else {
      currentGreeting.value = '안녕하세요! 🌙';
    }
  }

  // 시간 업데이트 타이머
  void _startTimeUpdater() {
    // 실제로는 Timer.periodic을 사용하지만, 여기서는 간단히 구현
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      _updateCurrentTime();
      return true;
    });
  }

  // 출퇴근 추천 생성
  void _generateRecommendations() {
    final now = DateTime.now();
    final workStart = _parseTime(workStartTime.value);
    final workEnd = _parseTime(workEndTime.value);

    // 출근 추천
    final departureTime = workStart.subtract(const Duration(minutes: 52, seconds: 15));
    recommendedDepartureTime.value = _formatTime(departureTime);
    morningRoute.value = '집 → 2호선 → 9호선 → 회사';
    morningDuration.value = 52;
    morningCost.value = 1370;

    // 퇴근 추천 (Mock: 저녁 약속 고려)
    final eveningDepart = workEnd.subtract(const Duration(minutes: 10));
    eveningDepartureTime.value = _formatTime(eveningDepart);
    eveningNote.value = '7시 강남 약속 시간 고려';
    eveningBuffer.value = 40;

    // 날씨 알림 (Mock)
    if (now.hour < 12) {
      currentWeatherAlert.value = '🌧️ 오늘 오후 비 예보';
    } else {
      currentWeatherAlert.value = '🌧️ 오늘 오후 비 예보';
    }

    print('=== 출퇴근 추천 생성 완료 ===');
    print('출근 추천: ${recommendedDepartureTime.value}');
    print('퇴근 추천: ${eveningDepartureTime.value}');
  }

  // 교통 상황 확인
  void _checkTrafficStatus() {
    // Mock 교통 상황 (실제로는 API 호출)
    final random = DateTime.now().millisecond % 3;

    // 지하철 상황
    if (random == 0) {
      subwayStatus.value = '정상 운행';
      subwayStatusColor.value = Colors.green;
    } else if (random == 1) {
      subwayStatus.value = '약간 지연';
      subwayStatusColor.value = Colors.orange;
    } else {
      subwayStatus.value = '운행 중단';
      subwayStatusColor.value = Colors.red;
    }

    // 버스 상황
    final busRandom = (DateTime.now().millisecond + 100) % 3;
    if (busRandom == 0) {
      busStatus.value = '정상 운행';
      busStatusColor.value = Colors.green;
    } else if (busRandom == 1) {
      busStatus.value = '약간 지연';
      busStatusColor.value = Colors.orange;
    } else {
      busStatus.value = '심각한 지연';
      busStatusColor.value = Colors.red;
    }

    print('=== 교통 상황 확인 ===');
    print('지하철: ${subwayStatus.value}');
    print('버스: ${busStatus.value}');
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 1));

    _updateCurrentTime();
    _generateRecommendations();
    _checkTrafficStatus();

    Get.snackbar(
      '새로고침 완료',
      '최신 교통 정보를 가져왔습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );

    isLoading.value = false;
  }

  // 경로 상세 보기
  void showRouteDetails() {
    Get.snackbar(
      '경로 상세',
      '상세 경로 화면을 준비 중입니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.route, color: Colors.white),
    );
  }

  // 시간 파싱 유틸리티
  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // 시간 포맷팅 유틸리티
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 현재 출퇴근 상태 확인
  String get currentCommuteStatus {
    final now = currentTime.value; // 반응형 변수 사용
    final workStart = _parseTime(workStartTime.value);
    final workEnd = _parseTime(workEndTime.value);
    final departureTime = _parseTime(recommendedDepartureTime.value);

    if (now.isBefore(departureTime)) {
      return '출근 준비';
    } else if (now.isAfter(departureTime) && now.isBefore(workStart)) {
      return '출근 중';
    } else if (now.isAfter(workStart) && now.isBefore(workEnd)) {
      return '근무 중';
    } else if (now.isAfter(workEnd)) {
      return '퇴근 시간';
    } else {
      return '휴식 시간';
    }
  }

  // 오늘의 날짜 포맷
  String get todayDate {
    final now = currentTime.value; // 반응형 변수 사용
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];

    return '${now.month}월 ${now.day}일 ${weekday}요일';
  }
}