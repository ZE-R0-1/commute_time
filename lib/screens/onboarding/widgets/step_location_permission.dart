import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepLocationPermission extends GetView<OnboardingController> {
  const StepLocationPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 최소 높이 확보로 중앙 정렬 효과
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),

          // 위치 아이콘 애니메이션
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.blue.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 48),

          // 제목
          Text(
            controller.currentStepTitle,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // 설명
          Text(
            controller.currentStepDescription,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // 권한 필요 이유 설명
          _buildPermissionReasons(),

          const SizedBox(height: 32),

          // 권한 상태 표시
          Obx(() => _buildPermissionStatus()),

          // 하단 여백
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPermissionReasons() {
    final reasons = [
      {
        'icon': Icons.route,
        'text': '현재 위치에서 최적 경로 계산',
      },
      {
        'icon': Icons.traffic,
        'text': '실시간 교통 상황 확인',
      },
      {
        'icon': Icons.timer,
        'text': '정확한 도착 시간 예측',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Get.theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '위치 서비스 사용 목적',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Get.theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reasons.map((reason) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      reason['icon'] as IconData,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reason['text'] as String,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildPermissionStatus() {
    if (controller.locationPermissionGranted.value) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '위치 권한이 허용되었습니다!',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_disabled,
            color: Colors.orange[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '위치 권한을 허용하면 더 정확한 서비스를 이용할 수 있습니다.',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}