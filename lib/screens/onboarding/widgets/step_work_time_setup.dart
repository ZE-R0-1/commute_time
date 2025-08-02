import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding_controller.dart';

class StepWorkTimeSetup extends GetView<OnboardingController> {
  const StepWorkTimeSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxString workStartTime = '09:00'.obs;
    final RxString workEndTime = '18:00'.obs;
    final RxInt preparationTime = 30.obs; // 분 단위
    final RxString editingMode = ''.obs; // 'start', 'end', 'preparation'

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // 연한 파란색
              Color(0xFFE8EAF6), // 연한 인디고색
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 커스텀 헤더
                _buildHeader(),

                // 진행률 표시
                _buildProgressIndicator(),

                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 출근 시간 설정
                        Obx(() => _buildTimeCard(
                              title: '출근 시간',
                              subtitle: '매일 출근하는 시간을 설정하세요',
                              time: workStartTime.value,
                              color: const Color(0xFFF97316), // 주황색
                              icon: Icons.wb_sunny,
                              isEditing: editingMode.value == 'start',
                              onEdit: () => editingMode.value = 'start',
                              onCancel: () => editingMode.value = '',
                              onConfirm: (newTime) {
                                workStartTime.value = newTime;
                                editingMode.value = '';
                              },
                            )),

                        const SizedBox(height: 16),

                        // 퇴근 시간 설정
                        Obx(() => _buildTimeCard(
                              title: '퇴근 시간',
                              subtitle: '매일 퇴근하는 시간을 설정하세요',
                              time: workEndTime.value,
                              color: const Color(0xFF8B5CF6), // 보라색
                              icon: Icons.nights_stay,
                              isEditing: editingMode.value == 'end',
                              onEdit: () => editingMode.value = 'end',
                              onCancel: () => editingMode.value = '',
                              onConfirm: (newTime) {
                                workEndTime.value = newTime;
                                editingMode.value = '';
                              },
                            )),

                        const SizedBox(height: 16),

                        // 준비 시간 설정
                        Obx(() => _buildPreparationTimeCard(
                              preparationTime: preparationTime.value,
                              isEditing: editingMode.value == 'preparation',
                              onEdit: () => editingMode.value = 'preparation',
                              onCancel: () => editingMode.value = '',
                              onConfirm: (newTime) {
                                preparationTime.value = newTime;
                                editingMode.value = '';
                              },
                            )),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                // 커스텀 하단 버튼
                _buildCustomBottomBar(
                    workStartTime, workEndTime, preparationTime),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.previousStep(),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '근무시간 설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '출퇴근 시간을 설정해주세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '3단계 중 2단계 완료',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '67%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(),
          const SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gapWidth = 8.0;
        final totalGaps = gapWidth * 2; // 3단계이므로 간격은 2개
        final segmentWidth = (totalWidth - totalGaps) / 3; // 3개의 세그먼트

        return Row(
          children: [
            // 1-2단계 (완료)
            ...List.generate(
                2,
                (index) => [
                      Container(
                        width: segmentWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: gapWidth),
                    ]).expand((x) => x),
            // 3단계 (미완료)
            Container(
              width: segmentWidth,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required IconData icon,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required Function(String) onConfirm,
  }) {
    if (isEditing) {
      return _buildEditingTimeCard(
        title: title,
        time: time,
        color: color,
        icon: icon,
        onCancel: onCancel,
        onConfirm: onConfirm,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: color,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingTimeCard({
    required String title,
    required String time,
    required Color color,
    required IconData icon,
    required VoidCallback onCancel,
    required Function(String) onConfirm,
  }) {
    final timeController = TextEditingController(text: time);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 시간 입력 필드
          GestureDetector(
            onTap: () => _showTimePicker(timeController.text, onConfirm),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 확인/취소 버튼
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onConfirm(timeController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationTimeCard({
    required int preparationTime,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required Function(int) onConfirm,
  }) {
    const color = Color(0xFF10B981); // 초록색

    if (isEditing) {
      return _buildEditingPreparationCard(
        preparationTime: preparationTime,
        color: color,
        onCancel: onCancel,
        onConfirm: onConfirm,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '준비 시간',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '출근 전 준비하는 시간을 설정하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${preparationTime}분',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: color,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingPreparationCard({
    required int preparationTime,
    required Color color,
    required VoidCallback onCancel,
    required Function(int) onConfirm,
  }) {
    final List<int> timeOptions = [15, 30, 45, 60]; // 분 단위

    final RxInt selectedTime = preparationTime.obs;

    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.coffee,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '준비 시간',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 시간 선택 옵션
              Column(
                children: timeOptions
                    .map((time) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => selectedTime.value = time,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedTime.value == time
                                    ? color.withValues(alpha: 0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedTime.value == time
                                      ? color
                                      : Colors.grey[200]!,
                                  width: selectedTime.value == time ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    selectedTime.value == time
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: selectedTime.value == time
                                        ? color
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$time분',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: selectedTime.value == time
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: selectedTime.value == time
                                          ? color
                                          : Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (time == 60)
                                    Text(
                                      '1시간',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // 확인/취소 버튼
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onConfirm(selectedTime.value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  void _showTimePicker(String currentTime, Function(String) onConfirm) {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        final formattedTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        onConfirm(formattedTime);
      }
    });
  }

  Widget _buildCustomBottomBar(
      RxString workStartTime, RxString workEndTime, RxInt preparationTime) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // 시간 데이터를 컨트롤러에 저장
          final startTimeParts = workStartTime.value.split(':');
          final endTimeParts = workEndTime.value.split(':');

          controller.setWorkTime(
            startTime: TimeOfDay(
              hour: int.parse(startTimeParts[0]),
              minute: int.parse(startTimeParts[1]),
            ),
            endTime: TimeOfDay(
              hour: int.parse(endTimeParts[0]),
              minute: int.parse(endTimeParts[1]),
            ),
          );

          // 다음 단계로 이동
          controller.nextStep();
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF3B82F6), // 파란색
                Color(0xFF6366F1), // 인디고색
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(59, 130, 246, 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '다음 단계',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
