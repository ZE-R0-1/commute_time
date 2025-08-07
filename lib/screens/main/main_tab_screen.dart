import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_tab_controller.dart';
import '../home/home_screen.dart';
import '../route_setup/route_setup_screen.dart';
import '../settings/settings_screen.dart';

class MainTabScreen extends GetView<MainTabController> {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          // 홈 화면
          HomeScreen(),

          // 경로 설정 화면
          RouteSetupScreen(),

          // 설정 화면
          SettingsScreen(),
        ],
      )),

      // 하단 탭바
      bottomNavigationBar: Obx(() => Container(
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
      )),
    );
  }
}