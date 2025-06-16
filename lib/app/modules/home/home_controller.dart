import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final storage = GetStorage();

  // 반응형 상태 변수들
  final RxInt selectedTabIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString currentTime = ''.obs;
  final RxString currentDate = ''.obs;

  // 더미 데이터 (나중에 실제 API로 교체)
  final RxList<Map<String, dynamic>> recentRoutes = <Map<String, dynamic>>[
    {
      'from': '강남역',
      'to': '홍대입구역',
      'time': '32분',
      'method': '지하철',
      'line': '2호선',
      'isFavorite': true,
    },
    {
      'from': '신촌역',
      'to': '여의도역',
      'time': '18분',
      'method': '지하철',
      'line': '5호선',
      'isFavorite': false,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _startTimeUpdate();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// 초기 데이터 설정
  void _initializeData() {
    _updateDateTime();

    // 환영 메시지
    Get.snackbar(
      '🚇 출퇴근타임',
      '홈 화면에 오신 것을 환영합니다!',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
    );
  }

  /// 실시간 시간 업데이트
  void _startTimeUpdate() {
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      _updateDateTime();
    });
  }

  /// 날짜/시간 업데이트
  void _updateDateTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    currentDate.value = '${now.month}월 ${now.day}일 ($weekday)';
  }

  /// 탭 변경
  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  /// 경로 검색 (임시)
  void searchRoute() {
    Get.snackbar(
      '경로 검색',
      '경로 검색 기능은 다음 단계에서 구현됩니다',
      backgroundColor: Get.theme.colorScheme.secondary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.secondary,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// 즐겨찾기 토글
  void toggleFavorite(int index) {
    if (index < recentRoutes.length) {
      recentRoutes[index]['isFavorite'] = !recentRoutes[index]['isFavorite'];
      recentRoutes.refresh();

      Get.snackbar(
        recentRoutes[index]['isFavorite'] ? '즐겨찾기 추가' : '즐겨찾기 해제',
        '${recentRoutes[index]['from']} → ${recentRoutes[index]['to']}',
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 설정 화면으로 이동 (임시)
  void goToSettings() {
    Get.snackbar(
      '설정',
      '설정 화면은 다음 단계에서 구현됩니다',
      backgroundColor: Get.theme.colorScheme.surface,
      colorText: Get.theme.colorScheme.onSurface,
      snackPosition: SnackPosition.TOP,
    );
  }

  /// 알림 확인 (임시)
  void checkNotifications() {
    Get.snackbar(
      '알림',
      '새로운 알림이 없습니다',
      backgroundColor: Get.theme.colorScheme.surface,
      colorText: Get.theme.colorScheme.onSurface,
      snackPosition: SnackPosition.TOP,
    );
  }
}