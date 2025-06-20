import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 사용자 정보
  final RxString userName = ''.obs;
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = '09:00'.obs;
  final RxString workEndTime = '18:00'.obs;

  // 날씨 정보
  final RxString weatherInfo = '🌧️ 오늘 오후 비 예보'.obs;
  final RxString weatherAdvice = '우산을 챙기시고 조기 출발을 권장드려요'.obs;

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

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeTransportStatus();
    _loadTodayData();
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

  // 오늘 데이터 로드 (실시간 정보 시뮬레이션)
  Future<void> _loadTodayData() async {
    isLoading.value = true;

    try {
      // Mock: API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      // 현재 시간에 따른 동적 메시지
      final now = DateTime.now();
      final hour = now.hour;

      if (hour < 12) {
        // 오전
        _updateMorningData();
      } else if (hour < 18) {
        // 오후
        _updateAfternoonData();
      } else {
        // 저녁
        _updateEveningData();
      }

      print('오늘 데이터 로드 완료: ${hour}시');

    } catch (e) {
      print('데이터 로드 오류: $e');
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

    // 퇴근 정보 업데이트
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

  // 서브 텍스트
  String get subGreetingMessage {
    final hour = DateTime.now().hour;

    if (hour < 6) {
      return '일찍 일어나셨네요. 충분한 휴식 취하세요';
    } else if (hour < 12) {
      return '오늘도 안전한 출퇴근 되세요';
    } else if (hour < 18) {
      return '오후도 힘내세요!';
    } else {
      return '하루 수고 많으셨어요';
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await _loadTodayData();
    Get.snackbar(
      '새로고침 완료',
      '최신 교통 정보를 불러왔습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  // ===== 경로 상세 화면 네비게이션 메서드 추가 =====

  // 출근 경로 상세 화면으로 이동
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

  // 퇴근 경로 상세 화면으로 이동
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

// 교통 상황 모델
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