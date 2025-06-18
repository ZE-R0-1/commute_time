import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class TransportSelector extends GetView<HomeController> {
  const TransportSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 교통수단 버튼들
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildTransportButton(
                mode: TransportMode.subway,
                icon: Icons.train,
                label: '지하철',
                status: controller.subwayStatus.value,
                isSelected: controller.selectedTransport.value == TransportMode.subway,
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => _buildTransportButton(
                mode: TransportMode.bus,
                icon: Icons.directions_bus,
                label: '버스',
                status: controller.busStatus.value,
                isSelected: controller.selectedTransport.value == TransportMode.bus,
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportButton({
    required TransportMode mode,
    required IconData icon,
    required String label,
    required String status,
    required bool isSelected,
  }) {
    final statusColor = controller.getTransportStatusColor(mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.changeTransportMode(mode),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Get.theme.primaryColor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Get.theme.primaryColor : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 아이콘과 상태
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Get.theme.primaryColor.withValues(alpha: 0.2)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Get.theme.primaryColor : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 라벨
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Get.theme.primaryColor : Colors.grey[700],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 상태
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  status,
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}