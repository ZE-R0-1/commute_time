import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_controller.dart';

class GreetingSection extends GetView<HomeController> {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 상태바 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 날짜 및 상태
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.todayDate,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  )),
                  const SizedBox(height: 2),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.currentCommuteStatus,
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),
                ],
              ),
            ),

            // 새로고침 버튼
            Obx(() => IconButton(
              onPressed: controller.isLoading.value ? null : controller.refreshData,
              icon: controller.isLoading.value
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Get.theme.primaryColor,
                ),
              )
                  : Icon(
                Icons.refresh,
                color: Colors.grey[600],
                size: 22,
              ),
            )),
          ],
        ),

        const SizedBox(height: 16),

        // 메인 인사말
        Obx(() {
          final greeting = controller.currentGreeting.value;
          final hasUserName = controller.userName.value.isNotEmpty;

          return Text(
            hasUserName ? '$greeting\n${controller.userName.value}님!' : greeting,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
              height: 1.2,
            ),
          );
        }),

        const SizedBox(height: 6),

        // 부가 메시지
        Text(
          '오늘도 안전한 출퇴근 되세요',
          style: Get.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}