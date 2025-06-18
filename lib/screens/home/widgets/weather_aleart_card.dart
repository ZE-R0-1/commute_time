import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class WeatherAlertCard extends GetView<HomeController> {
  const WeatherAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getWeatherIcon(),
              color: Colors.orange[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWeatherTitle(),
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWeatherDescription(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: Colors.orange[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  IconData _getWeatherIcon() {
    final message = controller.weatherAlertMessage.value;
    if (message.contains('비')) {
      return Icons.umbrella;
    } else if (message.contains('미세먼지')) {
      return Icons.masks;
    } else if (message.contains('눈')) {
      return Icons.ac_unit;
    } else if (message.contains('폭염')) {
      return Icons.wb_sunny;
    } else {
      return Icons.cloud;
    }
  }

  String _getWeatherTitle() {
    final message = controller.weatherAlertMessage.value;
    if (message.contains('비')) {
      return '☔ 오늘 오후 비 예보';
    } else if (message.contains('미세먼지')) {
      return '😷 오늘 미세먼지 나쁨';
    } else if (message.contains('눈')) {
      return '❄️ 오늘 눈 예보';
    } else if (message.contains('폭염')) {
      return '🌡️ 오늘 폭염주의보';
    } else {
      return '🌤️ 날씨 알림';
    }
  }

  String _getWeatherDescription() {
    final message = controller.weatherAlertMessage.value;
    final lines = message.split('\n');
    return lines.length > 1 ? lines[1] : message;
  }
}