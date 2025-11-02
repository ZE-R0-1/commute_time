import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/settings_controller.dart';
import '../common/settings_section.dart';
import '../common/toggle_item.dart';

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return SettingsSection(
      title: '알림 설정',
      children: [
        // 날씨 알림
        Obx(() => ToggleItem(
          icon: Icons.wb_cloudy,
          iconColor: Colors.orange,
          title: '날씨 알림',
          subtitle: '출근 전 날씨 정보를 알려드려요',
          value: controller.weatherNotification.value,
          onChanged: controller.toggleWeatherNotification,
        )),
      ],
    );
  }
}