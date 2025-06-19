import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main_tab_controller.dart';
import 'views/home_tab_view.dart';
import 'views/map_tab_view.dart';
import 'views/analysis_tab_view.dart';
import 'views/settings_tab_view.dart';

class MainTabScreen extends GetView<MainTabController> {
  const MainTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: const [
          // 0: 홈
          HomeTabView(),

          // 1: 지도
          MapTabView(),

          // 2: 분석
          AnalysisTabView(),

          // 3: 설정
          SettingsTabView(),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Get.theme.primaryColor,
        unselectedItemColor: const Color(0xFF6B7280),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: controller.tabs.map((tab) {
          final isActive = controller.isActiveTab(tab.index);

          return BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                key: ValueKey('${tab.index}_$isActive'),
                size: 24,
              ),
            ),
            label: tab.label,
          );
        }).toList(),
      )),
    );
  }
}