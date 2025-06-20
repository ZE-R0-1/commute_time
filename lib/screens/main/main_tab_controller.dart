import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/home_controller.dart';

class MainTabController extends GetxController {
  // 현재 선택된 탭 인덱스
  final RxInt currentIndex = 0.obs;

  // 탭 정보
  final List<MainTabItem> tabs = [
    MainTabItem(
      label: '홈',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    MainTabItem(
      label: '지도',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
    ),
    MainTabItem(
      label: '분석',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
    ),
    MainTabItem(
      label: '설정',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    print('=== 메인 탭 화면 초기화 ===');
    print('기본 탭: ${tabs[currentIndex.value].label}');
  }

  // 탭 변경 (중복 탭 클릭 방지 로직 추가)
  void changeTab(int index) {
    if (index >= 0 && index < tabs.length && index != currentIndex.value) {
      final previousTab = currentIndex.value;
      currentIndex.value = index;

      print('탭 변경: ${tabs[previousTab].label} → ${tabs[index].label}');

      // 탭 변경 시 추가 로직 (필요시)
      _onTabChanged(index);
    }
  }

  // 탭 변경 시 실행되는 로직
  void _onTabChanged(int newIndex) {
    switch (newIndex) {
      case 0: // 홈
        _refreshHomeData();
        break;
      case 1: // 지도
        _initializeMapData();
        break;
      case 2: // 분석
        _loadAnalysisData();
        break;
      case 3: // 설정
        _loadSettingsData();
        break;
    }
  }

  // 각 탭별 데이터 로딩 메서드들
  void _refreshHomeData() {
    print('홈 화면 데이터 새로고침');
    // HomeController가 있다면 새로고침 트리거
    try {
      final homeController = Get.find<HomeController>();
      homeController.refresh();
    } catch (e) {
      // HomeController가 없으면 무시
    }
  }

  void _initializeMapData() {
    print('지도 데이터 초기화');
    // 지도 관련 데이터 로딩
  }

  void _loadAnalysisData() {
    print('분석 데이터 로딩');
    // 분석 데이터 로딩
  }

  void _loadSettingsData() {
    print('설정 데이터 로딩');
    // 설정 데이터 로딩
  }

  // 현재 탭 정보
  MainTabItem get currentTab => tabs[currentIndex.value];

  // 각 탭별 앱바 제목
  String get appBarTitle {
    switch (currentIndex.value) {
      case 0:
        return '출퇴근 알리미';
      case 1:
        return '경로 지도';
      case 2:
        return '출퇴근 분석';
      case 3:
        return '설정';
      default:
        return '출퇴근 알리미';
    }
  }

  // 앱바가 필요한지 여부 (홈 화면은 커스텀 상단 영역)
  bool get showAppBar {
    return currentIndex.value != 0; // 홈 화면 제외하고 앱바 표시
  }

  // 뒤로가기 처리 (안드로이드)
  Future<bool> onWillPop() async {
    if (currentIndex.value != 0) {
      // 홈 탭이 아니면 홈 탭으로 이동
      changeTab(0);
      return false;
    }
    // 홈 탭이면 앱 종료 확인
    return await _showExitDialog();
  }

  Future<bool> _showExitDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('출퇴근 알리미를 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('종료'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// 탭 아이템 모델 (route 제거)
class MainTabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  MainTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}