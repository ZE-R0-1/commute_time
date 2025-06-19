import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class TrafficStatusGrid extends GetView<HomeController> {
  const TrafficStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Text(
          '🚇 교통 상황',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 12),

        // 교통 상황 그리드
        Row(
          children: [
            // 지하철 상태
            Expanded(
              child: _buildStatusCard(
                icon: '🚇',
                label: '지하철',
                value: controller.subwayStatus,
                color: controller.subwayStatusColor,
              ),
            ),

            const SizedBox(width: 12),

            // 버스 상태
            Expanded(
              child: _buildStatusCard(
                icon: '🚌',
                label: '버스',
                value: controller.busStatus,
                color: controller.busStatusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String icon,
    required String label,
    required RxString value,
    required Rx<Color> color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 라벨
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          // 상태값
          Obx(() => Text(
            value.value,
            style: Get.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.value,
            ),
            textAlign: TextAlign.center,
          )),
        ],
      ),
    );
  }
}