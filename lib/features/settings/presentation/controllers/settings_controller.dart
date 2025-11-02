import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 알림 설정
  final RxBool weatherNotification = true.obs;

  // 근무시간 설정 (온보딩에서 설정한 내용들과 연동)
  final RxString workStartTime = '09:00'.obs;
  final RxString workEndTime = '18:00'.obs;
  final RxString preparationTime = '30분'.obs;

  // 경로 설정
  final RxString homeToWorkRoute = '미설정'.obs;
  final RxString workToHomeRoute = '미설정'.obs;

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
    weatherNotification.value = _storage.read('weather_notification') ?? true;

    // 근무시간 설정 로드 (온보딩에서 설정한 내용들과 연동)
    workStartTime.value = _storage.read('work_start_time') ?? '09:00';
    workEndTime.value = _storage.read('work_end_time') ?? '18:00';

    int prepTime = _storage.read('preparation_time') ?? 30;
    preparationTime.value = '${prepTime}분';

    // 경로 설정 로드
    homeToWorkRoute.value = _storage.read('home_to_work_route') ?? '미설정';
    workToHomeRoute.value = _storage.read('work_to_home_route') ?? '미설정';

    // 앱 설정 로드
    darkMode.value = _storage.read('dark_mode') ?? false;
    isPremium.value = _storage.read('is_premium') ?? false;

    print('날씨 알림: ${weatherNotification.value}');
    print('다크모드: ${darkMode.value}');
    print('출근 시간: ${workStartTime.value}');
    print('퇴근 시간: ${workEndTime.value}');
    print('준비 시간: ${preparationTime.value}');
  }

  // 알림 설정 토글
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

  // 출근 시간 설정
  void changeWorkStartTime() async {
    // 현재 시간 파싱
    List<String> timeParts = workStartTime.value.split(':');
    TimeOfDay currentTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 9,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: currentTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String newTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      workStartTime.value = newTime;

      // 온보딩과 동일한 키로 저장
      _storage.write('work_start_time', newTime);

      print('출근 시간 변경: $newTime');
    }
  }

  // 퇴근 시간 설정
  void changeWorkEndTime() async {
    // 현재 시간 파싱
    List<String> timeParts = workEndTime.value.split(':');
    TimeOfDay currentTime = TimeOfDay(
      hour: int.tryParse(timeParts[0]) ?? 18,
      minute: int.tryParse(timeParts[1]) ?? 0,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: currentTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String newTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      workEndTime.value = newTime;

      // 온보딩과 동일한 키로 저장
      _storage.write('work_end_time', newTime);

      print('퇴근 시간 변경: $newTime');
    }
  }


  // 준비 시간 설정
  void changePreparationTime() async {
    final List<Map<String, dynamic>> timeOptions = [
      {'minutes': 10, 'label': '10분', 'description': '간단한 준비'},
      {'minutes': 15, 'label': '15분', 'description': '기본 준비'},
      {'minutes': 20, 'label': '20분', 'description': '여유있는 준비'},
      {'minutes': 30, 'label': '30분', 'description': '충분한 준비'},
      {'minutes': 45, 'label': '45분', 'description': '넉넉한 준비'},
      {'minutes': 60, 'label': '1시간', 'description': '완벽한 준비'},
    ];

    String selectedTime = preparationTime.value;

    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: const Text(
                '준비 시간 설정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.close,
                size: 20,
                color: Colors.grey,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      '출발 전 필요한 준비 시간을 선택하세요.\n이 시간을 고려하여 알림을 보내드립니다.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  ...timeOptions.map((option) {
                    final bool isSelected = selectedTime == option['label'];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.teal.withValues(alpha: 0.1) : null,
                        border: isSelected ? Border.all(color: Colors.teal, width: 2) : null,
                      ),
                      child: RadioListTile<String>(
                        value: option['label'],
                        groupValue: selectedTime,
                        onChanged: (value) {
                          setState(() {
                            selectedTime = value!;
                          });
                        },
                        title: Text(
                          option['label'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.teal : null,
                          ),
                        ),
                        subtitle: Text(
                          option['description'],
                          style: TextStyle(
                            color: isSelected ? Colors.teal[700] : Colors.grey[600],
                          ),
                        ),
                        activeColor: Colors.teal,
                        dense: true,
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              preparationTime.value = selectedTime;

              // 온보딩과 동일한 키로 저장 (숫자 값으로 저장)
              int timeValue = timeOptions.firstWhere((opt) => opt['label'] == selectedTime)['minutes'];
              _storage.write('preparation_time', timeValue);

              Get.back();

              print('준비 시간 변경: $selectedTime ($timeValue분)');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('변경'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
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
    weatherNotification.value = true;
    workStartTime.value = '09:00';
    workEndTime.value = '18:00';
    preparationTime.value = '30분';
    homeToWorkRoute.value = '미설정';
    workToHomeRoute.value = '미설정';
    darkMode.value = false;
    isPremium.value = false;

    // 저장소에서 삭제
    _storage.remove('weather_notification');
    _storage.remove('work_start_time');
    _storage.remove('work_end_time');
    _storage.remove('preparation_time');
    _storage.remove('home_to_work_route');
    _storage.remove('work_to_home_route');
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