import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../route_detail_controller.dart';
import '../models/route_detail.dart';
import 'route_step_card.dart';

class RouteTimeline extends GetView<RouteDetailController> {
  const RouteTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final route = controller.currentRoute.value;
      if (route == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            _buildSectionHeader(route),

            const SizedBox(height: 16),

            // 경로 단계들
            ...route.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == route.steps.length - 1;

              return RouteStepCard(
                step: step,
                isLast: isLast,
              );
            }),

            const SizedBox(height: 16),

            // 액션 버튼들
            _buildActionButtons(),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(RouteDetail route) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '🚇 상세 경로',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (route.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '추천',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                route.description.isNotEmpty
                    ? route.description
                    : '${route.routeName} • ${route.formattedTotalDuration}',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // 실시간 업데이트 버튼
        Container(
          decoration: BoxDecoration(
            color: route.hasRealTimeInfo
                ? Colors.green[50]
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: route.hasRealTimeInfo
                  ? Colors.green[200]!
                  : Colors.grey[300]!,
            ),
          ),
          child: IconButton(
            onPressed: controller.refreshRealTimeInfo,
            icon: Icon(
              Icons.refresh,
              color: route.hasRealTimeInfo
                  ? Colors.green[600]
                  : Colors.grey[600],
              size: 20,
            ),
            tooltip: '실시간 정보 업데이트',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // 길찾기 시작 버튼
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.startNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.navigation, size: 20),
                const SizedBox(width: 8),
                Text(
                  '길찾기 시작',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 서브 액션 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.addToFavorites,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  side: BorderSide(color: Get.theme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_border, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      '즐겨찾기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: 공유 기능 구현
                  Get.snackbar(
                    '공유',
                    '경로 정보를 공유합니다.',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Get.theme.primaryColor,
                    colorText: Colors.white,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      '공유하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}