import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../onboarding_controller.dart';

class StepWorkTime extends GetView<OnboardingController> {
  const StepWorkTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 시계 아이콘 (기존 유지)
          _buildTimeIcon(),

          // 🆕 미니멀한 제목과 설명
          _buildMinimalTitle(),

          // 🆕 미니멀한 시간 선택
          Obx(() => _buildMinimalTimeSelector()),

          // 🆕 미니멀한 빠른 설정
          _buildMinimalQuickPresets(),

          // 🆕 미니멀한 상태 표시
          Obx(() => _buildMinimalStatus()),
        ],
      ),
    );
  }

  // 시계 아이콘 (기존 유지)
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

  // 🆕 미니멀한 제목과 설명
  Widget _buildMinimalTitle() {
    return Column(
      children: [
        Text(
          '근무 시간',
          style: Get.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            color: Colors.grey[800],
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '출퇴근 알림을 위해 설정해주세요',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🆕 미니멀한 시간 선택
  Widget _buildMinimalTimeSelector() {
    return Row(
      children: [
        // 출근 시간
        Expanded(
          child: _buildMinimalTimeCard(
            title: '출근',
            time: controller.workStartTime.value,
            color: Colors.purple,
            onTap: () => _showCupertinoTimePicker(true),
          ),
        ),
        const SizedBox(width: 16),
        // 퇴근 시간
        Expanded(
          child: _buildMinimalTimeCard(
            title: '퇴근',
            time: controller.workEndTime.value,
            color: Colors.purple,
            onTap: () => _showCupertinoTimePicker(false),
          ),
        ),
      ],
    );
  }

  // 🆕 미니멀한 시간 카드
  Widget _buildMinimalTimeCard({
    required String title,
    required TimeOfDay? time,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool hasTime = time != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: hasTime ? color.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasTime ? color.withValues(alpha: 0.3) : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasTime ? color : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasTime ? time.format(Get.context!) : '--:--',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: hasTime ? color : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🆕 미니멀한 빠른 설정
  Widget _buildMinimalQuickPresets() {
    final presets = [
      {'label': '9 to 6', 'start': const TimeOfDay(hour: 9, minute: 0), 'end': const TimeOfDay(hour: 18, minute: 0)},
      {'label': '10 to 7', 'start': const TimeOfDay(hour: 10, minute: 0), 'end': const TimeOfDay(hour: 19, minute: 0)},
      {'label': '8 to 5', 'start': const TimeOfDay(hour: 8, minute: 0), 'end': const TimeOfDay(hour: 17, minute: 0)},
    ];

    return Column(
      children: [
        Text(
          '빠른 설정',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: presets.map((preset) {
            return InkWell(
              onTap: () {
                controller.setWorkTime(
                  startTime: preset['start'] as TimeOfDay,
                  endTime: preset['end'] as TimeOfDay,
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.purple[200]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  preset['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🆕 미니멀한 상태 표시
  Widget _buildMinimalStatus() {
    final startTime = controller.workStartTime.value;
    final endTime = controller.workEndTime.value;

    if (startTime != null && endTime != null) {
      // 설정 완료 상태
      final duration = _calculateWorkDuration(startTime, endTime);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.purple[100]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.purple[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${startTime.format(Get.context!)} - ${endTime.format(Get.context!)} (${duration}시간)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // 설정 필요 상태
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '출근 시간과 퇴근 시간을 설정해주세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // 🆕 Cupertino 스타일 시간 선택기 (더 예쁜 휠 방식)
  void _showCupertinoTimePicker(bool isStartTime) {
    final currentTime = isStartTime
        ? (controller.workStartTime.value ?? const TimeOfDay(hour: 9, minute: 0))
        : (controller.workEndTime.value ?? const TimeOfDay(hour: 18, minute: 0));

    DateTime initialDateTime = DateTime(2024, 1, 1, currentTime.hour, currentTime.minute);

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime selectedDateTime = initialDateTime;

        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '취소',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Text(
                    '${isStartTime ? '출근' : '퇴근'} 시간',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final timeOfDay = TimeOfDay(
                        hour: selectedDateTime.hour,
                        minute: selectedDateTime.minute,
                      );

                      if (isStartTime) {
                        controller.setWorkTime(startTime: timeOfDay);
                      } else {
                        controller.setWorkTime(endTime: timeOfDay);
                      }

                      Navigator.pop(context);
                    },
                    child: Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Cupertino 시간 선택기
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  use24hFormat: false,
                  minuteInterval: 15, // 15분 단위
                  onDateTimeChanged: (DateTime dateTime) {
                    selectedDateTime = dateTime;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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