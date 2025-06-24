import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWelcome extends GetView<OnboardingController> {
  const StepWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 🆕 상단 여백 없이 바로 아이콘
          _buildWelcomeIcon(),

          // 제목과 설명을 하나로 묶어서 간격 절약
          Column(
            children: [
              Text(
                '스마트 출퇴근\n관리의 시작! 🚗',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '매일 반복되는 출퇴근,\n이제 더 스마트하게 관리해보세요',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          // 🆕 핵심 기능 3개만 아이콘으로 간단히
          _buildCoreFeatures(),

          // 🆕 하단 동기부여 메시지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '🚀 실시간 교통정보로 스트레스 없는 출퇴근',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Get.theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 더 큰 임팩트의 아이콘
  Widget _buildWelcomeIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * value),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Get.theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // 🆕 간결한 핵심 기능 표시
  Widget _buildCoreFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(
          icon: Icons.navigation,
          label: '스마트\n경로',
          color: Colors.blue,
        ),
        _buildFeatureIcon(
          icon: Icons.schedule,
          label: '출퇴근\n알림',
          color: Colors.orange,
        ),
        _buildFeatureIcon(
          icon: Icons.analytics,
          label: '시간\n분석',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildFeatureIcon({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            height: 1.1,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}