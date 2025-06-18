import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class BottomNavigation extends GetView<HomeController> {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(
                icon: Icons.home,
                label: '홈',
                isSelected: true,
                onTap: () {},
              ),
              _buildTabItem(
                icon: Icons.map,
                label: '지도',
                isSelected: false,
                onTap: controller.goToMap,
              ),
              _buildTabItem(
                icon: Icons.bar_chart,
                label: '분석',
                isSelected: false,
                onTap: controller.goToAnalysis,
              ),
              _buildTabItem(
                icon: Icons.settings,
                label: '설정',
                isSelected: false,
                onTap: controller.goToSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Get.theme.primaryColor : Colors.grey[500],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Get.theme.primaryColor : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}