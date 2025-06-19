import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class WeatherAlertCard extends GetView<HomeController> {
  const WeatherAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // 노란색 배경
        border: Border.all(
          color: const Color(0xFFF59E0B), // 노란색 테두리
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 날씨 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.umbrella,
              color: Color(0xFF92400E),
              size: 22,
            ),
          ),

          const SizedBox(width: 16),

          // 알림 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.currentWeatherAlert.value,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '우산을 챙기시고, 평소보다 10분 일찍 출발하세요',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // 닫기 버튼
          GestureDetector(
            onTap: () {
              controller.currentWeatherAlert.value = '';
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 18,
                color: const Color(0xFF92400E).withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}