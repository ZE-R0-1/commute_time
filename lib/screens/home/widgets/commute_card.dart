import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

enum CommuteType { morning, evening }

class CommuteCard extends GetView<HomeController> {
  final CommuteType type;

  const CommuteCard({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isMorning = type == CommuteType.morning;

    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // 연한 회색 배경
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: isMorning ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 제목
          Row(
            children: [
              Text(
                isMorning ? '🌅' : '🌆',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                isMorning ? '오늘 출근' : '오늘 퇴근',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              // 상세 보기 버튼
              GestureDetector(
                onTap: controller.showRouteDetails,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isMorning ? const Color(0xFF2563EB) : const Color(0xFF7C3AED))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '상세',
                        style: TextStyle(
                          color: isMorning ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: isMorning ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 시간 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isMorning ? const Color(0xFF2563EB) : const Color(0xFF7C3AED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isMorning
                  ? '${controller.recommendedDepartureTime.value} 출발 권장'
                  : '${controller.eveningDepartureTime.value} 퇴근 권장',
              style: Get.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 상세 정보
          if (isMorning) ...[
            _buildInfoRow(
              icon: Icons.location_on,
              text: controller.morningRoute.value,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.access_time,
              text: '예상 소요시간: ${controller.morningDuration.value}분',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.account_balance_wallet,
              text: '교통비: ${controller.morningCost.value}원',
            ),
          ] else ...[
            _buildInfoRow(
              icon: Icons.event_note,
              text: controller.eveningNote.value,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.schedule,
              text: '여유 시간: ${controller.eveningBuffer.value}분',
            ),
          ],
        ],
      ),
    ));
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}