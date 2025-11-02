import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../features/route_setup/presentation/controllers/route_setup_controller.dart';
import 'route_card.dart';

class RouteList extends StatelessWidget {
  final RouteSetupController controller;

  const RouteList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.routesList.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: controller.routesList.map((route) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RouteCard(
              route: route,
              controller: controller,
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '저장된 경로 없음',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '우측 하단의 + 버튼을 눌러\n새 경로를 추가해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}