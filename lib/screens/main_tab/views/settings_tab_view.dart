import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsTabView extends StatelessWidget {
  const SettingsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Text(
                '⚙️ 설정',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),

              const SizedBox(height: 20),

              // 알림 설정
              _buildSection(
                title: '알림 설정',
                children: [
                  _buildSettingItem(
                    icon: Icons.notifications,
                    iconColor: const Color(0xFF2563EB),
                    title: '출발 시간 알림',
                    subtitle: '권장 출발 시간 10분 전 알림',
                    trailing: _buildToggle(true),
                  ),
                  _buildSettingItem(
                    icon: Icons.cloud,
                    iconColor: const Color(0xFFF59E0B),
                    title: '날씨 알림',
                    subtitle: '비/눈 예보 시 조기 출발 알림',
                    trailing: _buildToggle(true),
                  ),
                  _buildSettingItem(
                    icon: Icons.warning,
                    iconColor: const Color(0xFFEF4444),
                    title: '교통 장애 알림',
                    subtitle: '지하철 고장, 사고 등 긴급 상황',
                    trailing: _buildToggle(true),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 개인화 설정
              _buildSection(
                title: '개인화 설정',
                children: [
                  _buildSettingItem(
                    icon: Icons.schedule,
                    iconColor: const Color(0xFF10B981),
                    title: '근무 시간 설정',
                    trailing: Text(
                      '9:00 - 18:00',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.train,
                    iconColor: const Color(0xFF8B5CF6),
                    title: '선호 교통수단',
                    trailing: Text(
                      '지하철 + 버스',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.timer,
                    iconColor: const Color(0xFF06B6D4),
                    title: '준비 시간',
                    trailing: Text(
                      '30분',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 앱 설정
              _buildSection(
                title: '앱 설정',
                children: [
                  _buildSettingItem(
                    icon: Icons.dark_mode,
                    iconColor: const Color(0xFF374151),
                    title: '다크 모드',
                    trailing: _buildToggle(false),
                  ),
                  _buildSettingItem(
                    icon: Icons.star,
                    iconColor: const Color(0xFFDC2626),
                    title: '프리미엄 업그레이드',
                    subtitle: '고급 AI 분석, 광고 제거',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '월 4,900원',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 기타 설정
              _buildSection(
                title: '기타',
                children: [
                  _buildSettingItem(
                    icon: Icons.info,
                    iconColor: const Color(0xFF6B7280),
                    title: '앱 정보',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.privacy_tip,
                    iconColor: const Color(0xFF6B7280),
                    title: '개인정보 처리방침',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  _buildSettingItem(
                    icon: Icons.logout,
                    iconColor: const Color(0xFFEF4444),
                    title: '로그아웃',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        )
            : null,
        trailing: trailing,
        onTap: () {
          // TODO: 각 설정 항목별 액션 구현
          Get.snackbar(
            '설정',
            '$title 설정을 준비 중입니다.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Get.theme.primaryColor,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
            duration: const Duration(seconds: 1),
          );
        },
      ),
    );
  }

  Widget _buildToggle(bool isOn) {
    return Container(
      width: 50,
      height: 28,
      decoration: BoxDecoration(
        color: isOn ? const Color(0xFF2563EB) : Colors.grey[300],
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}