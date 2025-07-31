import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.showAppInfo,
            icon: const Icon(Icons.info_outline),
            tooltip: '앱 정보',
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 설정 섹션
            _buildNotificationSection(),

            const SizedBox(height: 24),

            // 개인화 설정 섹션
            _buildPersonalizationSection(),

            const SizedBox(height: 24),

            // 경로 설정 섹션
            _buildRouteSection(),

            const SizedBox(height: 24),

            // 앱 설정 섹션
            _buildAppSettingsSection(),

            const SizedBox(height: 32),

            // 설정 초기화 버튼
            _buildResetButton(),

            // 하단 여백
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }


  // 알림 설정 섹션
  Widget _buildNotificationSection() {
    return _buildSection(
      title: '알림 설정',
      children: [
        // 출발 시간 알림
        Obx(() => _buildToggleItem(
          icon: Icons.notifications,
          iconColor: Colors.blue,
          title: '출발 시간 알림',
          subtitle: '출발 시간 30분 전에 알려드려요',
          value: controller.departureTimeNotification.value,
          onChanged: controller.toggleDepartureNotification,
        )),

        _buildDivider(),

        // 날씨 알림
        Obx(() => _buildToggleItem(
          icon: Icons.wb_cloudy,
          iconColor: Colors.orange,
          title: '날씨 알림',
          subtitle: '출근 전 날씨 정보를 알려드려요',
          value: controller.weatherNotification.value,
          onChanged: controller.toggleWeatherNotification,
        )),

        _buildDivider(),

        // 교통 장애 알림
        Obx(() => _buildToggleItem(
          icon: Icons.warning,
          iconColor: Colors.red,
          title: '교통 장애 알림',
          subtitle: '실시간 교통 상황을 알려드려요',
          value: controller.trafficNotification.value,
          onChanged: controller.toggleTrafficNotification,
        )),
      ],
    );
  }

  // 개인화 설정 섹션 (온보딩에서 설정한 내용들)
  Widget _buildPersonalizationSection() {
    return _buildSection(
      title: '개인화 설정',
      children: [
        // 집 주소 설정
        Obx(() => _buildNavigationItem(
          icon: Icons.home,
          iconColor: Colors.blue,
          title: '집 주소',
          subtitle: '거주지 주소를 설정하세요',
          value: controller.homeAddress.value.isEmpty ? '미설정' : controller.homeAddress.value,
          onTap: controller.changeHomeAddress,
        )),

        _buildDivider(),

        // 회사 주소 설정  
        Obx(() => _buildNavigationItem(
          icon: Icons.business,
          iconColor: Colors.orange,
          title: '회사 주소',
          subtitle: '직장 주소를 설정하세요',
          value: controller.workAddress.value.isEmpty ? '미설정' : controller.workAddress.value,
          onTap: controller.changeWorkAddress,
        )),

        _buildDivider(),

        // 근무 시간 설정
        Obx(() => _buildNavigationItem(
          icon: Icons.access_time,
          iconColor: Colors.green,
          title: '근무 시간',
          subtitle: '출퇴근 시간을 설정하세요',
          value: controller.workingHours.value,
          onTap: controller.changeWorkingHours,
        )),

        _buildDivider(),

        // 준비 시간
        Obx(() => _buildNavigationItem(
          icon: Icons.timer,
          iconColor: Colors.teal,
          title: '준비 시간',
          subtitle: '출발 전 필요한 준비 시간을 설정하세요',
          value: controller.preparationTime.value,
          onTap: controller.changePreparationTime,
        )),
      ],
    );
  }

  // 앱 설정 섹션
  Widget _buildAppSettingsSection() {
    return _buildSection(
      title: '앱 설정',
      children: [
        // 다크 모드
        Obx(() => _buildToggleItem(
          icon: Icons.dark_mode,
          iconColor: Colors.grey[700]!,
          title: '다크 모드',
          subtitle: '어두운 테마를 사용합니다',
          value: controller.darkMode.value,
          onChanged: controller.toggleDarkMode,
        )),

        _buildDivider(),

        // 프리미엄 업그레이드
        Obx(() => _buildPremiumItem()),
      ],
    );
  }

  // 경로 설정 섹션
  Widget _buildRouteSection() {
    return _buildSection(
      title: '경로 설정',
      children: [
        // 집 → 회사 경로
        Obx(() => _buildNavigationItem(
          icon: Icons.home_work,
          iconColor: Colors.blue,
          title: '집 → 회사 경로',
          subtitle: '출근 시 사용할 경로를 설정하세요',
          value: controller.homeToWorkRoute.value,
          onTap: (){},
        )),

        _buildDivider(),

        // 회사 → 집 경로
        Obx(() => _buildNavigationItem(
          icon: Icons.work_history,
          iconColor: Colors.orange,
          title: '회사 → 집 경로',
          subtitle: '퇴근 시 사용할 경로를 설정하세요',
          value: controller.workToHomeRoute.value,
          onTap: (){},
        )),
      ],
    );
  }

  // 섹션 빌더
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // 섹션 카드
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  // 토글 아이템
  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // 제목과 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // iOS 스타일 토글 스위치
          _buildIOSToggle(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // 네비게이션 아이템
  Widget _buildNavigationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // 제목과 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 현재 값과 화살표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 프리미엄 아이템
  Widget _buildPremiumItem() {
    return InkWell(
      onTap: controller.upgradeToPremium,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: controller.isPremium.value
            ? BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.1),
              Colors.orange.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 1,
          ),
        )
            : null,
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.amber,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            // 제목과 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '프리미엄 업그레이드',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (controller.isPremium.value) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '활성화',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    controller.isPremium.value
                        ? '프리미엄 기능을 이용 중입니다'
                        : '더 많은 기능을 사용해보세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // 가격 또는 상태
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  controller.isPremium.value ? '구독 중' : controller.premiumPrice.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.isPremium.value ? Colors.amber : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  controller.isPremium.value ? Icons.check_circle : Icons.chevron_right,
                  color: controller.isPremium.value ? Colors.amber : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // iOS 스타일 토글
  Widget _buildIOSToggle({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? Get.theme.primaryColor : Colors.grey[300],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 구분선
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  // 설정 초기화 버튼
  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: controller.resetSettings,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restart_alt, size: 20),
            SizedBox(width: 8),
            Text(
              '설정 초기화',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}