import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/onboarding_controller.dart';
import '../components/notification/notification_header.dart';
import '../components/notification/notification_progress.dart';
import '../components/notification/notification_card.dart';
import '../components/notification/notification_permission_card.dart';
import '../components/notification/notification_bottom_button.dart';

class StepNotificationSetup extends GetView<OnboardingController> {
  const StepNotificationSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxBool departureNotification = true.obs;
    final RxBool weatherNotification = true.obs;

    // 저장된 데이터 복원
    _loadSavedNotificationData(departureNotification, weatherNotification);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // 연한 파란색
              Color(0xFFE8EAF6), // 연한 인디고색
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 커스텀 헤더
                NotificationHeader(
                  onBackPressed: () => controller.previousStep(),
                ),

                // 진행률 표시
                const NotificationProgress(),

                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 출발 시간 알림
                        Obx(() => NotificationCard(
                          title: '출발 시간 알림',
                          subtitle: '출발할 시간을 미리 알려드려요',
                          icon: Icons.access_time,
                          color: const Color(0xFF3B82F6), // 파란색
                          isEnabled: departureNotification.value,
                          onToggle: (value) => departureNotification.value = value,
                        )),

                        const SizedBox(height: 16),

                        // 날씨 알림
                        Obx(() => NotificationCard(
                          title: '날씨 알림',
                          subtitle: '우산이 필요한 날 미리 알림',
                          icon: Icons.wb_sunny,
                          color: const Color(0xFF10B981), // 초록색
                          isEnabled: weatherNotification.value,
                          onToggle: (value) => weatherNotification.value = value,
                        )),

                        const SizedBox(height: 24),

                        // 권한 안내 카드
                        const NotificationPermissionCard(),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                // 커스텀 하단 버튼
                NotificationBottomButton(
                  onPressed: () {
                    // 알림 설정을 컨트롤러에 저장
                    controller.setNotificationSettings(
                      departureNotification: departureNotification.value,
                      weatherNotification: weatherNotification.value,
                    );

                    // TODO: 알림 권한 요청 로직 추가

                    // 온보딩 완료
                    controller.nextStep();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 저장된 알림 설정 데이터 복원
  void _loadSavedNotificationData(
    RxBool departureNotification,
    RxBool weatherNotification,
  ) {
    final storage = GetStorage();

    // 출발시간 알림 복원
    final savedDepartureNotification = storage.read<bool>('onboarding_departure_notification');
    if (savedDepartureNotification != null) {
      departureNotification.value = savedDepartureNotification;
      print('🔄 출발시간 알림 복원: $savedDepartureNotification');
    }

    // 날씨 알림 복원
    final savedWeatherNotification = storage.read<bool>('onboarding_weather_notification');
    if (savedWeatherNotification != null) {
      weatherNotification.value = savedWeatherNotification;
      print('🔄 날씨 알림 복원: $savedWeatherNotification');
    }

    // 데이터 변경 감지 및 자동 저장 설정
    departureNotification.listen((value) => _saveNotificationData(departureNotification, weatherNotification));
    weatherNotification.listen((value) => _saveNotificationData(departureNotification, weatherNotification));
  }

  // 알림 설정 데이터 저장
  void _saveNotificationData(
    RxBool departureNotification,
    RxBool weatherNotification,
  ) {
    final storage = GetStorage();

    // 출발시간 알림 저장
    storage.write('onboarding_departure_notification', departureNotification.value);

    // 날씨 알림 저장
    storage.write('onboarding_weather_notification', weatherNotification.value);

    print('💾 알림 설정 데이터 저장 완료');
    print('   출발시간 알림: ${departureNotification.value}');
    print('   날씨 알림: ${weatherNotification.value}');
  }
}