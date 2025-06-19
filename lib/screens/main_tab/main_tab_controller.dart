import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late PageController pageController;
  late TabController tabController;

  // 현재 선택된 탭 인덱스
  final RxInt currentIndex = 0.obs;

  // 탭 정보 리스트
  final List<TabInfo> tabs = [
    TabInfo(
      index: 0,
      label: '홈',
      icon: Icons.home,
      activeIcon: Icons.home,
    ),
    TabInfo(
      index: 1,
      label: '지도',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
    ),
    TabInfo(
      index: 2,
      label: '분석',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
    ),
    TabInfo(
      index: 3,
      label: '설정',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  void onInit() {
    super.onInit();

    // PageController 초기화
    pageController = PageController(
      initialPage: currentIndex.value,
      keepPage: true, // 페이지 상태 유지
    );

    // TabController 초기화 (애니메이션용)
    tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: currentIndex.value,
    );

    print('=== 메인 탭 컨트롤러 초기화 ===');
    print('탭 개수: ${tabs.length}');
    print('초기 인덱스: ${currentIndex.value}');
  }

  @override
  void onClose() {
    pageController.dispose();
    tabController.dispose();
    super.onClose();
  }

  // 탭 변경 (BottomNavigationBar에서 호출)
  void changeTab(int index) {
    if (index == currentIndex.value) return;

    currentIndex.value = index;

    // PageView 페이지 변경 (애니메이션 포함)
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // TabController 동기화
    tabController.animateTo(index);

    print('=== 탭 변경 ===');
    print('인덱스: $index (${tabs[index].label})');
  }

  // 페이지 변경 (PageView에서 스와이프 시 호출)
  void onPageChanged(int index) {
    currentIndex.value = index;

    // TabController 동기화
    tabController.animateTo(index);

    print('=== 페이지 스와이프 ===');
    print('인덱스: $index (${tabs[index].label})');
  }

  // 특정 탭으로 즉시 이동 (애니메이션 없음)
  void jumpToTab(int index) {
    if (index == currentIndex.value) return;

    currentIndex.value = index;

    // PageView 페이지 변경 (애니메이션 없음)
    pageController.jumpToPage(index);

    // TabController 동기화
    tabController.index = index;
  }

  // 현재 탭 정보 가져오기
  TabInfo get currentTab => tabs[currentIndex.value];

  // 탭 활성화 여부 확인
  bool isActiveTab(int index) => currentIndex.value == index;

  // 특정 기능별 탭으로 이동하는 헬퍼 메서드들
  void goToHome() => changeTab(0);
  void goToMap() => changeTab(1);
  void goToAnalysis() => changeTab(2);
  void goToSettings() => changeTab(3);
}

// 탭 정보를 담는 클래스
class TabInfo {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const TabInfo({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}