import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route_setup/presentation/views/route_setup_screen.dart';
import '../../../home/presentation/views/home_screen.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../controllers/main_controller.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: (index) => controller.currentIndex.value = index,
        children: const [
          // 홈 화면
          HomeScreen(),

          // 경로 설정 화면
          RouteSetupScreen(),

          // 설정 화면
          SettingsScreen(),
        ],
      ),

      // 하단 탭바
      bottomNavigationBar: Obx(() => _buildBottomNavBar()),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Get.theme.primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        items: controller.tabs.map((tab) {
          final isSelected = controller.tabs.indexOf(tab) == controller.currentIndex.value;
          return BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Get.theme.primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  size: 24,
                ),
              ),
            ),
            label: tab.label,
          );
        }).toList(),
      ),
    );
  }
}