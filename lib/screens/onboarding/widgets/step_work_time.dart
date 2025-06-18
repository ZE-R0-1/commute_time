import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWorkTime extends GetView<OnboardingController> {
  const StepWorkTime({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 시계 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple,
                  Colors.purple.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.access_time,
              size: 40,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // 제목
          Text(
            controller.currentStepTitle,
            style: Get.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // 설명
          Text(
            controller.currentStepDescription,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // 근무 시간 설정
          _buildTimeSelector(),

          const SizedBox(height: 32),

          _buildTimePreview(),

          const SizedBox(height: 40),

          _buildQuickPresets(),

          // 하단 여백
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      children: [
        // 출근 시간
        _buildTimeCard(
          title: '출근 시간',
          icon: Icons.wb_sunny,
          iconColor: Colors.orange,
          time: controller.workStartTime.value,
          onTap: () => _selectTime(true),
        ),

        const SizedBox(height: 16),

        // 퇴근 시간
        _buildTimeCard(
          title: '퇴근 시간',
          icon: Icons.nights_stay,
          iconColor: Colors.blue,
          time: controller.workEndTime.value,
          onTap: () => _selectTime(false),
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: time != null ? iconColor.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: time != null ? iconColor.withValues(alpha: 0.3) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: time != null ? iconColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: time != null ? iconColor : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time != null ? time.format(Get.context!) : '시간을 선택하세요',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: time != null ? iconColor : Colors.grey[500],
                      fontWeight: time != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: time != null ? iconColor : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePreview() {
    return Obx(() {
      if (controller.workStartTime.value == null || controller.workEndTime.value == null) {
        return const SizedBox.shrink();
      }

      final startTime = controller.workStartTime.value!;
      final endTime = controller.workEndTime.value!;
      final duration = _calculateWorkDuration(startTime, endTime);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Get.theme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Get.theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '근무 시간 요약',
                  style: Get.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${startTime.format(Get.context!)} ~ ${endTime.format(Get.context!)}',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$duration시간',
                  style: Get.textTheme.bodyLarge?.copyWith(
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickPresets() {
    final presets = [
      {'label': '9 to 6', 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 18, minute: 0)},
      {'label': '10 to 7', 'start': const TimeOfDay(hour: 10, minute: 0), 'end': const TimeOfDay(hour: 19, minute: 0)},
      {'label': '8 to 5', 'start': const TimeOfDay(hour: 8, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 설정',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: presets.map((preset) {
            return ActionChip(
              label: Text(
                preset['label'] as String,
                style: TextStyle(
                  color: Get.theme.primaryColor,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.1),
              side: BorderSide(
                color: Get.theme.primaryColor.withValues(alpha: 0.3),
              ),
              onPressed: () {
                controller.setWorkTime(
                  startTime: preset['start'] as TimeOfDay,
                  endTime: preset['end'] as TimeOfDay,
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: Get.context!,
      initialTime: isStartTime
          ? (controller.workStartTime.value ?? const TimeOfDay(hour: 9, minute: 0))
          : (controller.workEndTime.value ?? const TimeOfDay(hour: 18, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Get.theme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      if (isStartTime) {
        controller.setWorkTime(startTime: selectedTime);
      } else {
        controller.setWorkTime(endTime: selectedTime);
      }
    }
  }

  int _calculateWorkDuration(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;

    int duration;
    if (endMinutes >= startMinutes) {
      duration = endMinutes - startMinutes;
    } else {
      // 다음날로 넘어가는 경우 (예: 22:00 ~ 06:00)
      duration = (24 * 60) - startMinutes + endMinutes;
    }

    return (duration / 60).round();
  }
}