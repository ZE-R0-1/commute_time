import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../route_detail_controller.dart';
import '../models/route_detail.dart';
import '../models/transport_mode.dart';

class AlternativeRoutes extends GetView<RouteDetailController> {
  const AlternativeRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final alternatives = controller.alternativeRoutes;
      if (alternatives.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                Text(
                  '🔄 다른 경로',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${alternatives.length}개',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              '상황에 맞는 다른 경로를 선택해보세요',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 16),

            // 대안 경로 목록
            ...alternatives.map((route) => _buildAlternativeCard(route)),
          ],
        ),
      );
    });
  }

  Widget _buildAlternativeCard(RouteDetail route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.selectAlternativeRoute(route.routeId),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 상단: 경로명과 주요 정보
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                route.routeName,
                                style: Get.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildRouteTypeChip(route),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            route.description,
                            style: Get.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 선택 버튼
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Get.theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '선택',
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 하단: 요약 정보와 교통수단
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildSummaryInfo(
                            icon: Icons.schedule,
                            value: route.formattedTotalDuration,
                            label: '시간',
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryInfo(
                            icon: Icons.account_balance_wallet,
                            value: route.formattedTotalCost,
                            label: '요금',
                          ),
                          const SizedBox(width: 16),
                          _buildSummaryInfo(
                            icon: Icons.swap_horiz,
                            value: '${route.transferCount}회',
                            label: '환승',
                          ),
                        ],
                      ),
                    ),

                    // 교통수단 아이콘들
                    _buildTransportModes(route),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTypeChip(RouteDetail route) {
    Color chipColor;
    String chipText;

    switch (route.routeName) {
      case '최저요금':
        chipColor = Colors.green;
        chipText = '💰 저렴';
        break;
      case '편안한 경로':
        chipColor = Colors.purple;
        chipText = '😌 편안';
        break;
      default:
        chipColor = Colors.blue;
        chipText = '⚡ 빠름';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          color: chipColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportModes(RouteDetail route) {
    // 경로에서 사용되는 교통수단들 추출
    final usedModes = route.steps
        .where((step) => step.mode != TransportMode.walk && step.mode != TransportMode.transfer)
        .map((step) => step.mode)
        .toSet()
        .toList();

    if (usedModes.isEmpty) return const SizedBox.shrink();

    return Row(
      children: usedModes.take(3).map((mode) {
        return Container(
          margin: const EdgeInsets.only(left: 4),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: mode.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: mode.color, width: 1),
          ),
          child: Icon(
            mode.icon,
            color: mode.color,
            size: 16,
          ),
        );
      }).toList(),
    );
  }
}