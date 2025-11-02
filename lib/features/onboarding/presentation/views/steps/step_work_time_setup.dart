import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/onboarding_controller.dart';
import '../components/work_time/work_time_header.dart';
import '../components/work_time/work_time_progress.dart';
import '../components/work_time/time_card.dart';
import '../components/work_time/preparation_time_card.dart';
import '../components/work_time/work_time_bottom_button.dart';

class StepWorkTimeSetup extends GetView<OnboardingController> {
  const StepWorkTimeSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxString workStartTime = '09:00'.obs;
    final RxString workEndTime = '18:00'.obs;
    final RxInt preparationTime = 30.obs; // 분 단위
    final RxString editingMode = ''.obs; // 'start', 'end', 'preparation'

    // 저장된 데이터 복원
    _loadSavedWorkTimeData(workStartTime, workEndTime, preparationTime);

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
                WorkTimeHeader(
                  onBackPressed: () => controller.previousStep(),
                ),

                // 진행률 표시
                const WorkTimeProgress(),

                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // 출근 시간 설정
                        Obx(() => TimeCard(
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
                        Obx(() => TimeCard(
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
                        Obx(() => PreparationTimeCard(
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
                WorkTimeBottomButton(
                  onPressed: () {
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

                    // 준비시간도 저장
                    controller.setPreparationTime(preparationTime.value);

                    // 다음 단계로 이동
                    controller.nextStep();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 저장된 근무시간 데이터 복원
  void _loadSavedWorkTimeData(
    RxString workStartTime,
    RxString workEndTime,
    RxInt preparationTime,
  ) {
    final storage = GetStorage();

    // 출근시간 복원
    final savedWorkStartTime = storage.read<String>('onboarding_work_start_time');
    if (savedWorkStartTime != null) {
      workStartTime.value = savedWorkStartTime;
      print('🔄 출근시간 복원: $savedWorkStartTime');
    }

    // 퇴근시간 복원
    final savedWorkEndTime = storage.read<String>('onboarding_work_end_time');
    if (savedWorkEndTime != null) {
      workEndTime.value = savedWorkEndTime;
      print('🔄 퇴근시간 복원: $savedWorkEndTime');
    }

    // 준비시간 복원
    final savedPreparationTime = storage.read<int>('onboarding_preparation_time');
    if (savedPreparationTime != null) {
      preparationTime.value = savedPreparationTime;
      print('🔄 준비시간 복원: ${savedPreparationTime}분');
    }

    // 데이터 변경 감지 및 자동 저장 설정
    workStartTime.listen((value) => _saveWorkTimeData(workStartTime, workEndTime, preparationTime));
    workEndTime.listen((value) => _saveWorkTimeData(workStartTime, workEndTime, preparationTime));
    preparationTime.listen((value) => _saveWorkTimeData(workStartTime, workEndTime, preparationTime));
  }

  // 근무시간 데이터 저장
  void _saveWorkTimeData(
    RxString workStartTime,
    RxString workEndTime,
    RxInt preparationTime,
  ) {
    final storage = GetStorage();

    // 출근시간 저장
    storage.write('onboarding_work_start_time', workStartTime.value);

    // 퇴근시간 저장
    storage.write('onboarding_work_end_time', workEndTime.value);

    // 준비시간 저장
    storage.write('onboarding_preparation_time', preparationTime.value);

    print('💾 근무시간 데이터 저장 완료');
    print('   출근시간: ${workStartTime.value}');
    print('   퇴근시간: ${workEndTime.value}');
    print('   준비시간: ${preparationTime.value}분');
  }
}