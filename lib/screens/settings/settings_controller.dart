import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 알림 설정
  final RxBool departureTimeNotification = true.obs;
  final RxBool weatherNotification = true.obs;
  final RxBool trafficNotification = true.obs;

  // 개인화 설정
  final RxString workingHours = '9:00 - 18:00'.obs;
  final RxString preferredTransport = '지하철 + 버스'.obs;
  final RxString preparationTime = '30분'.obs;

  // 앱 설정
  final RxBool darkMode = false.obs;
  final RxBool isPremium = false.obs;
  final RxString premiumPrice = '월 4,900원'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // 설정 로드
  void _loadSettings() {
    print('=== 설정 데이터 로딩 ===');

    // 알림 설정 로드
    departureTimeNotification.value = _storage.read('departure_notification') ?? true;
    weatherNotification.value = _storage.read('weather_notification') ?? true;
    trafficNotification.value = _storage.read('traffic_notification') ?? true;

    // 개인화 설정 로드
    workingHours.value = _storage.read('working_hours') ?? '9:00 - 18:00';
    preferredTransport.value = _storage.read('preferred_transport') ?? '지하철 + 버스';
    preparationTime.value = _storage.read('preparation_time') ?? '30분';

    // 앱 설정 로드
    darkMode.value = _storage.read('dark_mode') ?? false;
    isPremium.value = _storage.read('is_premium') ?? false;

    print('출발 알림: ${departureTimeNotification.value}');
    print('날씨 알림: ${weatherNotification.value}');
    print('교통 알림: ${trafficNotification.value}');
    print('다크모드: ${darkMode.value}');
  }

  // 알림 설정 토글
  void toggleDepartureNotification(bool value) {
    departureTimeNotification.value = value;
    _storage.write('departure_notification', value);

    _showNotificationChangedSnackbar(
      '출발 시간 알림',
      value ? '활성화' : '비활성화',
      value,
    );

    print('출발 시간 알림 ${value ? '활성화' : '비활성화'}');
  }

  void toggleWeatherNotification(bool value) {
    weatherNotification.value = value;
    _storage.write('weather_notification', value);

    _showNotificationChangedSnackbar(
      '날씨 알림',
      value ? '활성화' : '비활성화',
      value,
    );

    print('날씨 알림 ${value ? '활성화' : '비활성화'}');
  }

  void toggleTrafficNotification(bool value) {
    trafficNotification.value = value;
    _storage.write('traffic_notification', value);

    _showNotificationChangedSnackbar(
      '교통 장애 알림',
      value ? '활성화' : '비활성화',
      value,
    );

    print('교통 장애 알림 ${value ? '활성화' : '비활성화'}');
  }

  // 다크모드 토글
  void toggleDarkMode(bool value) {
    darkMode.value = value;
    _storage.write('dark_mode', value);

    // TODO: 실제 다크모드 테마 적용
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

    Get.snackbar(
      '다크 모드',
      value ? '다크 모드가 활성화되었습니다' : '라이트 모드가 활성화되었습니다',
      snackPosition: SnackPosition.TOP,
      backgroundColor: value ? Colors.grey[800] : Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: Icon(
        value ? Icons.dark_mode : Icons.light_mode,
        color: Colors.white,
      ),
    );

    print('다크모드 ${value ? '활성화' : '비활성화'}');
  }

  // 근무 시간 설정
  void changeWorkingHours() {
    Get.snackbar(
      '근무 시간 설정',
      '근무 시간을 설정할 수 있는 화면으로 이동합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.access_time, color: Colors.white),
    );

    // TODO: 근무 시간 설정 화면으로 이동
    print('근무 시간 설정 화면 이동');
  }

  // 선호 교통수단 설정
  void changePreferredTransport() {
    Get.snackbar(
      '교통수단 설정',
      '선호하는 교통수단을 설정할 수 있습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.directions_transit, color: Colors.white),
    );

    // TODO: 교통수단 설정 화면으로 이동
    print('교통수단 설정 화면 이동');
  }

  // 준비 시간 설정
  void changePreparationTime() {
    Get.snackbar(
      '준비 시간 설정',
      '출발 전 준비 시간을 설정할 수 있습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.timer, color: Colors.white),
    );

    // TODO: 준비 시간 설정 화면으로 이동
    print('준비 시간 설정 화면 이동');
  }

  // 프리미엄 업그레이드
  void upgradeToPremium() {
    if (isPremium.value) {
      Get.snackbar(
        '프리미엄 회원',
        '이미 프리미엄 회원이시네요! 감사합니다. 👑',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.workspace_premium, color: Colors.white),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('프리미엄 업그레이드'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프리미엄 기능을 사용하시겠습니까?'),
            SizedBox(height: 12),
            Text('✨ 고급 분석 기능'),
            Text('🔔 맞춤형 알림'),
            Text('🗺️ 실시간 경로 최적화'),
            Text('☁️ 클라우드 백업'),
            SizedBox(height: 12),
            Text(
              '월 4,900원',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processPremiumUpgrade();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: const Text('업그레이드'),
          ),
        ],
      ),
    );

    print('프리미엄 업그레이드 다이얼로그 표시');
  }

  // 프리미엄 업그레이드 처리
  void _processPremiumUpgrade() {
    // Mock: 결제 처리
    Get.snackbar(
      '업그레이드 완료! 👑',
      '프리미엄 회원이 되신 것을 축하합니다!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.celebration, color: Colors.white),
    );

    isPremium.value = true;
    _storage.write('is_premium', true);

    print('프리미엄 업그레이드 완료');
  }

  // 알림 변경 스낵바
  void _showNotificationChangedSnackbar(String type, String status, bool isEnabled) {
    Get.snackbar(
      '$type $status',
      isEnabled
          ? '$type을 받으실 수 있습니다.'
          : '$type을 받지 않습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: isEnabled ? Colors.green : Colors.grey[600],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
      icon: Icon(
        isEnabled ? Icons.notifications_active : Icons.notifications_off,
        color: Colors.white,
      ),
    );
  }

  // 설정 초기화
  void resetSettings() {
    Get.dialog(
      AlertDialog(
        title: const Text('설정 초기화'),
        content: const Text('모든 설정을 기본값으로 되돌리시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _performReset();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    // 모든 설정을 기본값으로 리셋
    departureTimeNotification.value = true;
    weatherNotification.value = true;
    trafficNotification.value = true;
    workingHours.value = '9:00 - 18:00';
    preferredTransport.value = '지하철 + 버스';
    preparationTime.value = '30분';
    darkMode.value = false;
    isPremium.value = false;

    // 저장소에서 삭제
    _storage.remove('departure_notification');
    _storage.remove('weather_notification');
    _storage.remove('traffic_notification');
    _storage.remove('working_hours');
    _storage.remove('preferred_transport');
    _storage.remove('preparation_time');
    _storage.remove('dark_mode');
    _storage.remove('is_premium');

    Get.snackbar(
      '설정 초기화 완료',
      '모든 설정이 기본값으로 되돌아갔습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.restart_alt, color: Colors.white),
    );

    print('설정 초기화 완료');
  }

  // 앱 정보
  void showAppInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('앱 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('출퇴근 알리미'),
            SizedBox(height: 8),
            Text('버전: 1.0.0'),
            Text('개발자: Flutter Team'),
            SizedBox(height: 12),
            Text('스마트한 출퇴근을 위한\n최고의 도우미 앱'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}