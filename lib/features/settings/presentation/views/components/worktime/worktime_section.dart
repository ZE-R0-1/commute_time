import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../common/settings_section.dart';
import '../common/navigation_item.dart';
import '../common/divider.dart';

class WorktimeSection extends StatelessWidget {
  const WorktimeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return SettingsSection(
      title: '근무시간 설정',
      children: [
        // 출근 시간
        Obx(() => NavigationItem(
          icon: Icons.login,
          iconColor: Colors.blue,
          title: '출근 시간',
          subtitle: '출근 시간을 설정하세요',
          value: controller.workStartTime.value,
          onTap: controller.changeWorkStartTime,
        )),

        const SettingsDivider(),

        // 퇴근 시간
        Obx(() => NavigationItem(
          icon: Icons.logout,
          iconColor: Colors.red,
          title: '퇴근 시간',
          subtitle: '퇴근 시간을 설정하세요',
          value: controller.workEndTime.value,
          onTap: controller.changeWorkEndTime,
        )),

        const SettingsDivider(),

        // 준비 시간
        Obx(() => NavigationItem(
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
}