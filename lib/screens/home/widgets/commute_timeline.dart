import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class CommuteTimeline extends GetView<HomeController> {
  const CommuteTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 출근 섹션
        _buildCommuteSection(
          isEvening: false,
          icon: Icons.wb_sunny,
          title: '오늘 출근',
          timeButton: Obx(() => _buildTimeButton(
            time: '${controller.recommendedDepartureTime.value} 출발 권장',
            color: Colors.blue,
            onPressed: controller.startMorningCommute,
          )),
          route: Obx(() => controller.commuteRoute.join(' → ')),
          duration: Obx(() => '예상 소요시간: ${controller.estimatedDuration.value}분'),
          cost: Obx(() => '교통비: ${controller.transportCost.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원'),
        ),

        const SizedBox(height: 24),

        // 퇴근 섹션
        _buildCommuteSection(
          isEvening: true,
          icon: Icons.nights_stay,
          title: '오늘 퇴근',
          timeButton: Obx(() => _buildTimeButton(
            time: '${controller.recommendedLeaveTime.value} 퇴근 권장',
            color: Colors.purple,
            onPressed: controller.startEveningCommute,
          )),
          route: Obx(() => controller.eveningPlan.value),
          duration: Obx(() => '여유 시간: ${controller.spareTime.value}분'),
          cost: null, // 퇴근에는 교통비 표시 안 함
        ),
      ],
    );
  }

  Widget _buildCommuteSection({
    required bool isEvening,
    required IconData icon,
    required String title,
    required Widget timeButton,
    required Widget route,
    required Widget duration,
    Widget? cost,
  }) {
    final color = isEvening ? Colors.purple : Colors.blue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 타임라인 인디케이터
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            if (!isEvening) ...[
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ],
        ),

        const SizedBox(width: 16),

        // 콘텐츠 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

              // 시간 버튼
              timeButton,
              const SizedBox(height: 12),

              // 경로/계획 정보
              _buildInfoRow(
                icon: Icons.place,
                content: route,
                color: Colors.grey[600]!,
              ),
              const SizedBox(height: 8),

              // 소요시간/여유시간
              _buildInfoRow(
                icon: Icons.access_time,
                content: duration,
                color: Colors.grey[600]!,
              ),

              // 교통비 (출근 시만)
              if (cost != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.attach_money,
                  content: cost,
                  color: Colors.grey[600]!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton({
    required String time,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Widget content,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DefaultTextStyle(
            style: Get.textTheme.bodyMedium!.copyWith(
              color: color,
            ),
            child: content,
          ),
        ),
      ],
    );
  }
}