import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';
import 'widgets/weather_alert_card.dart';
import 'widgets/commute_timeline.dart';
import 'widgets/transport_selector.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: Get.theme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 인사말
                _buildGreetingSection(),
                const SizedBox(height: 24),

                // 날씨 알림 (있을 경우)
                Obx(() => controller.hasWeatherAlert.value
                    ? Column(
                  children: [
                    const WeatherAlertCard(),
                    const SizedBox(height: 24),
                  ],
                )
                    : const SizedBox.shrink()
                ),

                // 출퇴근 타임라인
                const CommuteTimeline(),
                const SizedBox(height: 32),

                // 교통수단 선택
                const TransportSelector(),
                const SizedBox(height: 100), // 하단 탭바 공간 확보
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
          controller.greetingMessage.value,
          style: Get.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        )),
        const SizedBox(height: 8),
        Text(
          '오늘도 안전한 출퇴근 되세요',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: Icons.home,
                label: '홈',
                isSelected: true,
                onTap: () {},
              ),
              _buildTabItem(
                icon: Icons.map,
                label: '지도',
                isSelected: false,
                onTap: controller.goToMap,
              ),
              _buildTabItem(
                icon: Icons.bar_chart,
                label: '분석',
                isSelected: false,
                onTap: controller.goToAnalysis,
              ),
              _buildTabItem(
                icon: Icons.settings,
                label: '설정',
                isSelected: false,
                onTap: controller.goToSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Get.theme.primaryColor : Colors.grey[500],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Get.theme.primaryColor : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}