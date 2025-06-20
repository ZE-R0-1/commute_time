import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/routes/app_pages.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 현재 단계 (0부터 시작)
  final RxInt currentStep = 0.obs;

  // 총 단계 수
  final int totalSteps = 5;

  // 각 단계별 완료 상태
  final RxList<bool> stepCompleted = <bool>[].obs;

  // 사용자 입력 데이터
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final Rx<TimeOfDay?> workStartTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> workEndTime = Rx<TimeOfDay?>(null);
  final RxBool locationPermissionGranted = false.obs;

  // 로딩 상태
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSteps();
  }

  void _initializeSteps() {
    // 모든 단계를 미완료로 초기화
    stepCompleted.value = List.generate(totalSteps, (index) => false);

    print('=== 온보딩 시작 ===');
    print('총 ${totalSteps}단계');
  }

  // 다음 단계로 이동
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      // 현재 단계 완료 표시
      stepCompleted[currentStep.value] = true;

      // 다음 단계로 이동
      currentStep.value++;

      print('단계 이동: ${currentStep.value + 1}/$totalSteps');
    } else {
      // 마지막 단계 완료
      _completeOnboarding();
    }
  }

  // 이전 단계로 이동
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      print('이전 단계: ${currentStep.value + 1}/$totalSteps');
    }
  }

  // 현재 단계가 완료 가능한지 확인
  bool get canProceed {
    switch (currentStep.value) {
      case 0: // 환영 화면
        return true;
      case 1: // 위치 권한
        return locationPermissionGranted.value;
      case 2: // 집 주소
        return homeAddress.value.isNotEmpty;
      case 3: // 회사 주소
        return workAddress.value.isNotEmpty;
      case 4: // 근무 시간
        return workStartTime.value != null && workEndTime.value != null;
      default:
        return false;
    }
  }

  // 위치 권한 요청
  Future<void> requestLocationPermission() async {
    try {
      isLoading.value = true;

      // Mock: 권한 요청 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));

      final status = await Permission.location.request();

      if (status.isGranted) {
        locationPermissionGranted.value = true;
        Get.snackbar(
          '권한 허용',
          '위치 서비스를 사용할 수 있습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        // Mock: 거부되어도 일단 진행 가능하게
        locationPermissionGranted.value = true;
        Get.snackbar(
          '권한 설정',
          '위치 권한은 나중에 설정할 수 있습니다.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
      }
    } catch (e) {
      // Mock: 에러 발생시에도 진행 가능
      locationPermissionGranted.value = true;
      print('위치 권한 요청 오류: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 주소 검색 (Mock)
  Future<List<String>> searchAddress(String query) async {
    if (query.isEmpty) return [];

    // Mock: 주소 검색 결과
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      '서울특별시 강남구 테헤란로 123',
      '서울특별시 강남구 테헤란로 456',
      '서울특별시 서초구 서초대로 789',
      '서울특별시 마포구 월드컵북로 456',
      '서울특별시 용산구 한강대로 789',
    ].where((address) =>
        address.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // 집 주소 설정
  void setHomeAddress(String address) {
    homeAddress.value = address;
    print('집 주소 설정: $address');
  }

  // 회사 주소 설정
  void setWorkAddress(String address) {
    workAddress.value = address;
    print('회사 주소 설정: $address');
  }

  // 근무 시간 설정
  void setWorkTime({TimeOfDay? startTime, TimeOfDay? endTime}) {
    if (startTime != null) {
      workStartTime.value = startTime;
      print('출근 시간: ${startTime.format(Get.context!)}');
    }
    if (endTime != null) {
      workEndTime.value = endTime;
      print('퇴근 시간: ${endTime.format(Get.context!)}');
    }
  }

  // 온보딩 완료 후 메인 화면으로 이동
  Future<void> _completeOnboarding() async {
    try {
      isLoading.value = true;

      // 온보딩 데이터 저장
      await _storage.write('onboarding_completed', true);
      await _storage.write('home_address', homeAddress.value);
      await _storage.write('work_address', workAddress.value);
      await _storage.write('work_start_time', _timeToString(workStartTime.value));
      await _storage.write('work_end_time', _timeToString(workEndTime.value));
      await _storage.write('location_permission', locationPermissionGranted.value);
      await _storage.write('onboarding_completed_at', DateTime.now().toIso8601String());

      print('=== 온보딩 완료 ===');
      print('집 주소: ${homeAddress.value}');
      print('회사 주소: ${workAddress.value}');
      print('근무시간: ${_timeToString(workStartTime.value)} ~ ${_timeToString(workEndTime.value)}');

      // 완료 메시지
      Get.snackbar(
        '설정 완료! 🎉',
        '출퇴근 알리미 서비스를 시작합니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.celebration, color: Colors.white),
      );

      // 2초 후 메인 화면(탭바 포함)으로 이동
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.main);

    } catch (e) {
      print('온보딩 완료 오류: $e');
      Get.snackbar(
        '오류 발생',
        '설정 저장 중 문제가 발생했습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // TimeOfDay를 문자열로 변환
  String? _timeToString(TimeOfDay? time) {
    if (time == null) return null;
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 진행률 계산
  double get progress {
    return (currentStep.value + 1) / totalSteps;
  }

  // 단계별 제목
  String get currentStepTitle {
    switch (currentStep.value) {
      case 0:
        return '출퇴근 알리미에\n오신 것을 환영합니다! 👋';
      case 1:
        return '위치 서비스\n권한을 허용해주세요 📍';
      case 2:
        return '집 주소를\n설정해주세요 🏠';
      case 3:
        return '회사 주소를\n설정해주세요 🏢';
      case 4:
        return '근무 시간을\n설정해주세요 ⏰';
      default:
        return '';
    }
  }

  // 단계별 설명
  String get currentStepDescription {
    switch (currentStep.value) {
      case 0:
        return '스마트한 출퇴근 관리로\n더 편리한 일상을 만들어보세요.';
      case 1:
        return '출퇴근 경로와 실시간 교통상황을\n제공하기 위해 위치 권한이 필요합니다.';
      case 2:
        return '출근 시 최적의 경로를 안내하기 위해\n집 주소를 입력해주세요.';
      case 3:
        return '퇴근 시 교통상황을 확인하기 위해\n회사 주소를 입력해주세요.';
      case 4:
        return '출퇴근 알림과 교통상황 안내를 위해\n근무 시간을 설정해주세요.';
      default:
        return '';
    }
  }
}