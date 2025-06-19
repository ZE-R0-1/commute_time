import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../route_detail_controller.dart';
import '../models/route_detail.dart';

class RouteHeader extends GetView<RouteDetailController> {
  const RouteHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final route = controller.currentRoute.value;
      if (route == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Get.theme.primaryColor,
              Get.theme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Get.theme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단: 경로 타입과 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 경로 타입
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        route.routeType == 'morning'
                            ? Icons.wb_sunny
                            : Icons.nights_stay,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        route.routeType == 'morning' ? '출근' : '퇴근',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // 경로 상태
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: route.hasDelays
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: route.hasDelays ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    route.getRouteStatus(),
                    style: TextStyle(
                      color: route.hasDelays ? Colors.orange[100] : Colors.green[100],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 출발지 → 도착지
            Row(
              children: [
                Expanded(
                  child: _buildLocationInfo(
                    icon: Icons.radio_button_checked,
                    location: route.origin,
                    time: route.formattedDepartureTime,
                    isOrigin: true,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                Expanded(
                  child: _buildLocationInfo(
                    icon: Icons.location_on,
                    location: route.destination,
                    time: route.formattedArrivalTime,
                    isOrigin: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 요약 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  icon: Icons.schedule,
                  label: '소요시간',
                  value: route.formattedTotalDuration,
                ),
                _buildSummaryDivider(),
                _buildSummaryItem(
                  icon: Icons.account_balance_wallet,
                  label: '예상요금',
                  value: route.formattedTotalCost,
                ),
                _buildSummaryDivider(),
                _buildSummaryItem(
                  icon: Icons.swap_horiz,
                  label: '환승',
                  value: '${route.transferCount}회',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String location,
    required String time,
    required bool isOrigin,
  }) {
    return Column(
      crossAxisAlignment: isOrigin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isOrigin) ...[
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            if (isOrigin) ...[
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          location,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.3,
          ),
          textAlign: isOrigin ? TextAlign.start : TextAlign.end,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.3),
    );
  }
}