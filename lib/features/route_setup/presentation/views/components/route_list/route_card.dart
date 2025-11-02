import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../features/route_setup/presentation/controllers/route_setup_controller.dart';
import '../common/route_item.dart';
import '../common/add_transfer_button.dart';

class RouteCard extends StatelessWidget {
  final Map<String, dynamic> route;
  final RouteSetupController controller;

  const RouteCard({
    super.key,
    required this.route,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final routeId = route['id'] ?? '';
    final routeName = route['name'] ?? '이름 없는 경로';

    // 출발지 처리 (새 구조 vs 구 구조 호환)
    final departureData = route['departure'];
    final departure = departureData is Map ? (departureData['name'] ?? '') : (departureData?.toString() ?? '');

    // 도착지 처리 (새 구조 vs 구 구조 호환)
    final arrivalData = route['arrival'];
    final arrival = arrivalData is Map ? (arrivalData['name'] ?? '') : (arrivalData?.toString() ?? '');
    final transfers = route['transfers'] as List? ?? [];

    return Obx(() {
      final isEditMode = controller.editingRouteId.value == routeId;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Expanded(
                  child: Text(
                    routeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                // 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 적용하기/적용중 버튼 (항상 표시)
                    Obx(() {
                      final isActive = controller.isRouteActive(routeId);
                      final canApply = controller.totalRouteCount >= 2;
                      return InkWell(
                        onTap: (isActive || !canApply) ? null : () {
                          controller.applyRoute(routeId);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2196F3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            isActive ? '적용중' : '적용하기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),

                    // 삭제 버튼 (수정 모드일 때만)
                    if (isEditMode) ...[
                      InkWell(
                        onTap: () {
                          controller.deleteRoute(routeId, routeName);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 이름 변경 버튼
                      InkWell(
                        onTap: () {
                          controller.editRouteName(routeId, routeName);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            size: 20,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 수정 버튼
                    InkWell(
                      onTap: () {
                        controller.toggleEditMode(routeId);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEditMode
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditMode ? Icons.check : Icons.edit_outlined,
                          size: 20,
                          color: isEditMode
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 출발지
            if (departure.isNotEmpty) ...[
              RouteItem(
                icon: Icons.location_on,
                iconColor: const Color(0xFF3B82F6),
                label: '출발지',
                value: departure,
                isEditMode: isEditMode,
                onEdit: () => controller.editRouteLocation(routeId, 'departure'),
              ),
              const SizedBox(height: 12),
            ],

            // 환승지들
            if (transfers.isNotEmpty) ...[
              for (int i = 0; i < transfers.length; i++) ...[
                RouteItem(
                  icon: Icons.swap_horiz,
                  iconColor: const Color(0xFFF97316),
                  label: '환승지 ${i + 1}',
                  value: transfers[i]['name'] ?? '',
                  isEditMode: isEditMode,
                  onEdit: () => controller.editRouteTransfer(routeId, i),
                  onDelete: () => controller.deleteRouteTransfer(routeId, i),
                  showDelete: true,
                ),
                const SizedBox(height: 12),
              ],
            ],

            // 환승지 추가 버튼 (수정 모드일 때만)
            if (isEditMode && transfers.length < 3) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AddTransferButton(
                  onTap: () => controller.addRouteTransfer(routeId),
                ),
              ),
            ],

            // 도착지
            if (arrival.isNotEmpty) ...[
              RouteItem(
                icon: Icons.flag,
                iconColor: const Color(0xFF10B981),
                label: '도착지',
                value: arrival,
                isEditMode: isEditMode,
                onEdit: () => controller.editRouteLocation(routeId, 'arrival'),
              ),
            ],
          ],
        ),
      );
    });
  }
}