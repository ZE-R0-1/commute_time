import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class StatsCard extends GetView<HomeController> {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                Icons.analytics,
                color: Get.theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '이번 주 통계',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.goToAnalysis,
                style: TextButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text(
                  '자세히',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(() => controller.weeklyStats.isEmpty
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : Column(
            children: [
              // 주요 지표들 (2x2 그리드)
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '평균 출퇴근',
                      '${controller.weeklyStats['average_commute_time']}분',
                      Icons.access_time,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      '총 이동 거리',
                      '${controller.weeklyStats['total_distance']}km',
                      Icons.route,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '정시 출근율',
                      '${controller.weeklyStats['on_time_percentage']}%',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      '일찍 퇴근',
                      '${controller.weeklyStats['early_departure_count']}회',
                      Icons.logout,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 추가 정보
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      '최적 경로',
                      controller.weeklyStats['best_route'] as String,
                      Icons.star,
                      Colors.amber,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      '최고의 날',
                      controller.weeklyStats['best_day'] as String,
                      Icons.sentiment_very_satisfied,
                      Colors.green,
                    ),
                    if (controller.weeklyStats['late_arrival_count'] > 0) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '개선 필요',
                        '${controller.weeklyStats['late_arrival_count']}회 지각',
                        Icons.warning,
                        Colors.orange,
                      ),
                    ],
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Get.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}