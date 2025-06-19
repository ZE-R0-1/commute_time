import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/home_controller.dart';
import '../../home/widgets/greeting_section.dart';
import '../../home/widgets/weather_alert_card.dart';
import '../../home/widgets/commute_card.dart';
import '../../home/widgets/traffic_status_grid.dart';

class HomeTabView extends GetView<HomeController> {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: Get.theme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인사말 섹션
                const GreetingSection(),

                const SizedBox(height: 20),

                // 날씨 알림 카드
                Obx(() => controller.currentWeatherAlert.value.isNotEmpty
                    ? const WeatherAlertCard()
                    : const SizedBox.shrink()
                ),

                if (controller.currentWeatherAlert.value.isNotEmpty)
                  const SizedBox(height: 15),

                // 출근 카드
                const CommuteCard(
                  type: CommuteType.morning,
                ),

                const SizedBox(height: 15),

                // 퇴근 카드
                const CommuteCard(
                  type: CommuteType.evening,
                ),

                const SizedBox(height: 20),

                // 교통 상황
                const TrafficStatusGrid(),

                // 하단 여백 (BottomNavigationBar를 위한 공간)
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}