import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWorkTime extends GetView<OnboardingController> {
  const StepWorkTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 🆕 시계 아이콘
          _buildTimeIcon(),

          // 제목과 설명을 하나로 묶어서 간격 절약
          Column(
            children: [
              Text(
                '근무 시간 설정하기 ⏰',
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '출퇴근 시간에 맞는 최적의\n알림과 경로를 제공해드려요',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          // 🆕 간소화된 시간 선택
          _buildTimeSelector(),

          // 🆕 빠른 설정 (더 컴팩트)
          _buildQuickPresets(),

          // 🆕 현재 설정 요약 또는 도움말
          Obx(() => _buildTimeStatus()),

          // 🆕 혜택 안내
          _buildBenefitMessage(),
        ],
      ),
    );
  }

  // 시계 아이콘
  Widget _buildTimeIcon() {
    return Container(
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.access_time,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  // 🆕 간소화된 시간 선택
  Widget _buildTimeSelector() {
    return Row(
      children: [
        // 출근 시간
        Expanded(
          child: _buildCompactTimeCard(
            title: '출근',
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            time: controller.workStartTime.value,
            onTap: () => _selectTime(true),
          ),
        ),
        const SizedBox(width: 12),
        // 퇴근 시간
        Expanded(
          child: _buildCompactTimeCard(
            title: '퇴근',
            icon: Icons.nights_stay,
            iconColor: Colors.blue,
            time: controller.workEndTime.value,
            onTap: () => _selectTime(false),
          ),
        ),
      ],
    );
  }

  // 🆕 컴팩트한 시간 카드
  Widget _buildCompactTimeCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: time != null ? iconColor.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: time != null ? iconColor.withValues(alpha: 0.3) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: time != null ? iconColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Get.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: time != null ? iconColor : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time != null ? time.format(Get.context!) : '--:--',
              style: Get.textTheme.bodySmall?.copyWith(
                color: time != null ? iconColor : Colors.grey[500],
                fontWeight: time != null ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 컴팩트한 빠른 설정
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
          style: Get.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: presets.map((preset) {
            return ActionChip(
              label: Text(
                preset['label'] as String,
                style: TextStyle(
                  color: Colors.purple[600],
                  fontSize: 11,
                ),
              ),
              backgroundColor: Colors.purple[50],
              side: BorderSide(
                color: Colors.purple[200]!,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  // 🆕 시간 설정 상태 표시
  Widget _buildTimeStatus() {
    if (controller.workStartTime.value != null && controller.workEndTime.value != null) {
      return _buildTimeSet();
    } else {
      return _buildTimeHelp();
    }
  }

  // 시간 설정 완료 상태
  Widget _buildTimeSet() {
    final startTime = controller.workStartTime.value!;
    final endTime = controller.workEndTime.value!;
    final duration = _calculateWorkDuration(startTime, endTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.purple[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.purple[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${startTime.format(Get.context!)} ~ ${endTime.format(Get.context!)} (${duration}시간)',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.purple[700],
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간 설정 도움말
  Widget _buildTimeHelp() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '출근 시간과 퇴근 시간을 설정해주세요',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.blue[700],
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 혜택 안내 메시지
  Widget _buildBenefitMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            size: 16,
            color: Colors.purple[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🔔 설정한 시간에 맞춰 출발 알림과 교통상황을 알려드려요',
              style: Get.textTheme.bodySmall?.copyWith(
                color: Colors.purple[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 시간 선택 다이얼로그
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
              primary: Colors.purple[600],
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

  // 근무 시간 계산
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