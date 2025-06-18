import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class StatusCard extends GetView<HomeController> {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            controller.statusColor,
            controller.statusColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: controller.statusColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.statusIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.statusMessage,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 액션 버튼
          _buildActionButton(),
        ],
      ),
    ));
  }

  String _getStatusTitle() {
    switch (controller.currentStatus.value) {
      case CommuteStatus.beforeWork:
        return '출근 준비';
      case CommuteStatus.goingToWork:
        return '출근 중';
      case CommuteStatus.atWork:
        return '업무 중';
      case CommuteStatus.goingHome:
        return '퇴근 중';
      case CommuteStatus.atHome:
        return '휴식 중';
    }
  }

  Widget _buildActionButton() {
    // 출근 전이나 퇴근 전에만 경로 안내 버튼 표시
    if (controller.currentStatus.value == CommuteStatus.beforeWork ||
        controller.currentStatus.value == CommuteStatus.goingToWork ||
        controller.currentStatus.value == CommuteStatus.goingHome) {

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: controller.startNavigation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: controller.statusColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.navigation, size: 20),
          label: Text(
            _getButtonText(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // 회사나 집에 있을 때는 현재 위치 정보 표시
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.white.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getCurrentLocationText(),
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (controller.currentStatus.value) {
      case CommuteStatus.beforeWork:
      case CommuteStatus.goingToWork:
        return '회사로 경로 안내';
      case CommuteStatus.goingHome:
        return '집으로 경로 안내';
      default:
        return '경로 안내';
    }
  }

  String _getCurrentLocationText() {
    switch (controller.currentStatus.value) {
      case CommuteStatus.atWork:
        return '현재 위치: ${controller.workAddress.value}';
      case CommuteStatus.atHome:
        return '현재 위치: ${controller.homeAddress.value}';
      default:
        return '현재 위치: ${controller.currentLocation.value}';
    }
  }
}