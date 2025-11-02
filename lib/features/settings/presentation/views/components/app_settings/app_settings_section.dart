import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../common/settings_section.dart';
import '../common/toggle_item.dart';
import '../common/divider.dart';
import 'premium_item.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return SettingsSection(
      title: '앱 설정',
      children: [
        // 다크 모드
        Obx(() => ToggleItem(
          icon: Icons.dark_mode,
          iconColor: Colors.grey[700]!,
          title: '다크 모드',
          subtitle: '어두운 테마를 사용합니다',
          value: controller.darkMode.value,
          onChanged: controller.toggleDarkMode,
        )),

        const SettingsDivider(),

        // 프리미엄 업그레이드
        const PremiumItem(),
      ],
    );
  }
}