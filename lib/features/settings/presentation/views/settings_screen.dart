import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../../../core/design_system/widgets/app_header_widget.dart';
import 'components/notification/notification_section.dart';
import 'components/worktime/worktime_section.dart';
import 'components/app_settings/app_settings_section.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            AppHeaderWidget(
              title: '설정',
              subtitle: '앱을 나의 스타일대로 꾸며보세요',
              actionIcon: Icons.info_outlined,
              onActionPressed: controller.showAppInfo,
              actionTooltip: '앱 정보',
            ),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 알림 설정 섹션
                    const NotificationSection(),

                    const SizedBox(height: 24),

                    // 근무시간 설정 섹션
                    const WorktimeSection(),

                    const SizedBox(height: 24),

                    // 앱 설정 섹션
                    const AppSettingsSection(),

                    const SizedBox(height: 32),

                    // 설정 초기화 버튼
                    _buildResetButton(),

                    // 하단 여백
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
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