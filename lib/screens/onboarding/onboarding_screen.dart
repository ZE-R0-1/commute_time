import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'onboarding_controller.dart';
import 'widgets/step_welcome.dart';
import 'widgets/step_location_permission.dart';
import 'widgets/step_home_address.dart';
import 'widgets/step_work_address.dart';
import 'widgets/step_work_time.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true, // 키보드 올라올 때 화면 조정
      body: SafeArea(
        child: Obx(() =>
            Column(
              children: [
                // 상단 진행률 표시
                _buildProgressHeader(),

                // 메인 콘텐츠 영역
                Expanded(
                  child: _buildStepContent(),
                ),

                // 하단 네비게이션 버튼
                _buildNavigationButtons(),
              ],
            )),
      ),
    );
  }

  // 진행률 헤더
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 진행률 바
          Row(
            children: [
              Text(
                '${controller.currentStep.value + 1}',
                style: Get.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
              Text(
                ' / ${controller.totalSteps}',
                style: Get.textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
              const Spacer(),
              if (controller.currentStep.value > 0)
                TextButton(
                  onPressed: controller.previousStep,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '이전',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 진행률 인디케이터
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Get.theme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // 단계별 콘텐츠
  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      child: _getCurrentStepWidget(),
    );
  }

  // 현재 단계의 위젯 반환
  Widget _getCurrentStepWidget() {
    switch (controller.currentStep.value) {
      case 0:
        return const StepWelcome(key: ValueKey('welcome'));
      case 1:
        return const StepLocationPermission(key: ValueKey('location'));
      case 2:
        return const StepHomeAddress(key: ValueKey('home'));
      case 3:
        return const StepWorkAddress(key: ValueKey('work'));
      case 4:
        return const StepWorkTime(key: ValueKey('time'));
      default:
        return const StepWelcome(key: ValueKey('default'));
    }
  }

  // 네비게이션 버튼
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 메인 버튼 (다음 or 완료)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: controller.canProceed ? () async {
                if (controller.currentStep.value == controller.totalSteps - 1) {
                  // 마지막 단계 - 완료
                  controller.nextStep();
                } else {
                  // 🆕 각 단계별 특별 처리 로직 추가
                  await _handleStepAction();
                }
              } : () async {
                // 🆕 canProceed가 false인 경우에도 위치 권한 단계에서는 권한 요청 실행
                if (controller.currentStep.value == 1) {
                  await controller.requestLocationPermission();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Obx(() => controller.isLoading.value
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '설정 저장 중...',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
                  : Text(
                _getButtonText(),
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              )
              ),
            ),
          ),

          // 건너뛰기 버튼 (위치 권한 단계에서만)
          if (controller.currentStep.value == 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton(
                onPressed: () {
                  controller.locationPermissionGranted.value = true;
                  controller.nextStep();
                },
                child: Text(
                  '나중에 설정하기',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// 🆕 각 단계별 액션 처리 메서드 추가
  Future<void> _handleStepAction() async {
    switch (controller.currentStep.value) {
      case 1: // 위치 권한 단계
        if (!controller.locationPermissionGranted.value) {
          // 위치 권한이 아직 허용되지 않았으면 권한 요청
          await controller.requestLocationPermission();
        } else {
          // 이미 권한이 허용되었으면 다음 단계로
          controller.nextStep();
        }
        break;

      default:
      // 다른 단계들은 기본적으로 다음 단계로 이동
        controller.nextStep();
        break;
    }
  }

// 🆕 버튼 텍스트 결정 (실제 GPS 상태 반영)
  String _getButtonText() {
    if (controller.currentStep.value == controller.totalSteps - 1) {
      return '설정 완료 🎉';
    }

    switch (controller.currentStep.value) {
      case 0:
        return '시작하기';
      case 1:
        if (controller.isLocationLoading.value) {
          return '위치 확인 중...';
        } else if (controller.locationPermissionGranted.value) {
          return '다음 단계 →';
        } else {
          return '📍 위치 권한 허용';
        }
      default:
        return '다음 단계';
    }
  }
}