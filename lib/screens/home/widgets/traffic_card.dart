import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class TrafficCard extends GetView<HomeController> {
  const TrafficCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.traffic,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '교통',
                style: Get.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Obx(() => controller.isLoadingTraffic.value
              ? const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 예상 시간
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${controller.estimatedTime.value}',
                    style: Get.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getTrafficColor(),
                    ),
                  ),
                  Text(
                    '분',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: _getTrafficColor(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                controller.recommendedRoute.value,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 12),

              // 교통 상황
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTrafficColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getTrafficIcon(),
                      color: _getTrafficColor(),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${controller.trafficCondition.value} 상황',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: _getTrafficColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
          ),
        ],
      ),
    );
  }

  Color _getTrafficColor() {
    switch (controller.trafficCondition.value) {
      case '원활':
        return Colors.green;
      case '지체':
        return Colors.orange;
      case '정체':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTrafficIcon() {
    switch (controller.trafficCondition.value) {
      case '원활':
        return Icons.check_circle;
      case '지체':
        return Icons.warning;
      case '정체':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}