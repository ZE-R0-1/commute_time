import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/routes/app_pages.dart';
import '../../../home/domain/entities/user_location_entity.dart';
import '../../../home/domain/entities/location_permission_entity.dart';
import '../../../home/domain/usecases/check_location_permission_usecase.dart';
import '../../../home/domain/usecases/get_current_location_usecase.dart';
import '../../../location_search/domain/entities/address_result_entity.dart';
import '../../../location_search/domain/usecases/search_address_usecase.dart';
import '../views/dialogs/location_permission_dialog.dart';

class OnboardingController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 현재 단계 (0부터 시작)
  final RxInt currentStep = 0.obs;

  // 총 단계 수
  final int totalSteps = 4; // 환영 화면 + 경로 설정 + 근무시간 설정 + 알림 설정

  // 각 단계별 완료 상태
  final RxList<bool> stepCompleted = <bool>[].obs;

  // 사용자 입력 데이터
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final Rx<TimeOfDay?> workStartTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> workEndTime = Rx<TimeOfDay?>(null);
  final RxInt preparationTime = 30.obs; // 분 단위

  // 알림 설정
  final RxBool departureNotification = true.obs;
  final RxBool weatherNotification = true.obs;

  // 주소 검색 결과 저장 (좌표 정보 포함)
  final Rx<AddressResultEntity?> selectedHomeAddress = Rx<AddressResultEntity?>(null);
  final Rx<AddressResultEntity?> selectedWorkAddress = Rx<AddressResultEntity?>(null);

  // 경로 설정 데이터
  final RxnString selectedDeparture = RxnString();
  final RxnString selectedArrival = RxnString();

  // 실제 위치 권한 및 정보
  final RxBool locationPermissionGranted = false.obs;
  final Rx<UserLocationEntity?> currentLocation = Rx<UserLocationEntity?>(null);
  final RxBool isLocationLoading = false.obs;

  // UseCases
  late CheckLocationPermissionUseCase _checkLocationPermissionUseCase;
  late GetCurrentLocationUseCase _getCurrentLocationUseCase;
  late SearchAddressUseCase _searchAddressUseCase;

  // 로딩 상태
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    _checkLocationPermissionUseCase = Get.find<CheckLocationPermissionUseCase>();
    _getCurrentLocationUseCase = Get.find<GetCurrentLocationUseCase>();
    _searchAddressUseCase = Get.find<SearchAddressUseCase>();
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

  // 경로명 변수 추가 (step_route_setup.dart와 동기화)
  final RxnString routeName = RxnString();

  // 현재 단계가 완료 가능한지 확인
  bool get canProceed {
    switch (currentStep.value) {
      case 0: // 환영 화면
        return true;
      case 1: // 경로 설정
        return selectedDeparture.value != null && selectedDeparture.value!.isNotEmpty &&
               selectedArrival.value != null && selectedArrival.value!.isNotEmpty &&
               routeName.value != null && routeName.value!.trim().isNotEmpty;
      default:
        return false;
    }
  }

  // 위치 권한 요청 및 현재 위치 조회
  Future<void> requestLocationPermission() async {
    try {
      isLocationLoading.value = true;
      print('=== 실제 GPS 권한 요청 시작 ===');

      // 1. 위치 권한 확인 및 요청
      final permissionResult = await _checkLocationPermissionUseCase();

      if (!permissionResult.success) {
        // 권한 요청 실패
        print('위치 권한 실패: ${permissionResult.message}');

        // 사용자에게 상세한 안내
        await showLocationPermissionDialog(
          permissionResult,
          onRetry: () {
            if (permissionResult.errorType == LocationErrorType.permissionDeniedForever) {
              // 설정 페이지로 이동
              _checkLocationPermissionUseCase().then((newResult) {
                if (newResult.success) {
                  requestLocationPermission();
                }
              });
            } else {
              // 권한 재요청
              requestLocationPermission();
            }
          },
        );
        locationPermissionGranted.value = true;
        return;
      }

      // 2. 권한 성공 - 현재 위치 조회
      print('위치 권한 성공 - 현재 위치 조회 시작');
      locationPermissionGranted.value = true;

      final location = await _getCurrentLocationUseCase();

      if (location != null) {
        currentLocation.value = location;

        // 저장소에 위치 정보 저장
        await _storage.write('current_latitude', location.latitude);
        await _storage.write('current_longitude', location.longitude);
        await _storage.write('current_address', location.address);
        await _storage.write('location_permission_granted', true);
        await _storage.write('location_updated_at', DateTime.now().toIso8601String());

        print('현재 위치 저장 완료:');
        print('- 주소: ${location.address}');
        print('- 좌표: ${location.latitude}, ${location.longitude}');
        print('- 정확도: ${location.accuracyText}');

        print('위치 확인 완료: ${location.address}');

      } else {
        // 위치 조회 실패시에도 권한은 허용된 상태
        print('위치 조회 실패 - 기본 설정으로 진행');

        print('위치 권한 허용됨 - 현재 위치 조회 실패');
      }

    } catch (e) {
      print('위치 권한 요청 오류: $e');

      // 오류 발생해도 진행은 가능하게
      locationPermissionGranted.value = true;
      print('위치 권한 오류 발생 - 나중에 설정 가능');
    } finally {
      isLocationLoading.value = false;
    }
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

  // 준비 시간 설정
  void setPreparationTime(int minutes) {
    preparationTime.value = minutes;
    print('준비 시간: ${minutes}분');
  }

  // 알림 설정
  void setNotificationSettings({
    required bool departureNotification,
    required bool weatherNotification,
  }) {
    this.departureNotification.value = departureNotification;
    this.weatherNotification.value = weatherNotification;
    print('출발시간 알림: $departureNotification');
    print('날씨 알림: $weatherNotification');
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
      await _storage.write('preparation_time', preparationTime.value);
      await _storage.write('departure_notification', departureNotification.value);
      await _storage.write('weather_notification', weatherNotification.value);
      await _storage.write('location_permission', locationPermissionGranted.value);
      await _storage.write('onboarding_completed_at', DateTime.now().toIso8601String());

      // 선택된 주소의 상세 정보도 저장
      final homeAddr = selectedHomeAddress.value;
      if (homeAddr != null) {
        await _storage.write('home_place_name', homeAddr.placeName);
        await _storage.write('home_road_address', homeAddr.roadAddress);
        await _storage.write('home_jibun_address', homeAddr.jibunAddress);
      }

      final workAddr = selectedWorkAddress.value;
      if (workAddr != null) {
        await _storage.write('work_place_name', workAddr.placeName);
        await _storage.write('work_road_address', workAddr.roadAddress);
        await _storage.write('work_jibun_address', workAddr.jibunAddress);
      }

      // 현재 위치 정보가 있으면 저장
      final location = currentLocation.value;
      if (location != null) {
        await _storage.write('has_current_location', true);
        print('위치 정보 포함 온보딩 완료');
      } else {
        await _storage.write('has_current_location', false);
        print('위치 정보 없이 온보딩 완료');
      }

      // 경로 데이터를 영구 저장소로 복사 후 임시 데이터 정리
      await _saveRouteDataPermanently();
      await _clearOnboardingTempData();

      print('=== 온보딩 완료 ===');
      print('집 주소: ${homeAddress.value}');
      print('회사 주소: ${workAddress.value}');
      print('근무시간: ${_timeToString(workStartTime.value)} ~ ${_timeToString(workEndTime.value)}');
      print('준비시간: ${preparationTime.value}분');
      print('출발시간 알림: ${departureNotification.value}');
      print('날씨 알림: ${weatherNotification.value}');
      print('위치 권한: ${locationPermissionGranted.value}');
      if (location != null) {
        print('현재 위치: ${location.address}');
      }

      print('설정 완료! 출퇴근 알리미 서비스를 시작합니다.');

      // 2초 후 메인 화면(탭바 포함)으로 이동
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.main);

    } catch (e) {
      print('온보딩 완료 오류: $e');
      print('설정 저장 중 문제가 발생했습니다.');
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
      case 5:
        return '집→회사 경로를\n설정해주세요 🚌';
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
        return '현재 위치 기반 날씨 정보와\n출퇴근 경로 안내를 위해 위치 권한이 필요합니다.';
      case 2:
        return '출근 시 최적의 경로를 안내하기 위해\n집 주소를 입력해주세요.';
      case 3:
        return '퇴근 시 교통상황을 확인하기 위해\n회사 주소를 입력해주세요.';
      case 4:
        return '출퇴근 알림과 교통상황 안내를 위해\n근무 시간을 설정해주세요.';
      case 5:
        return '출발지, 환승지, 도착지를 설정하여\n최적의 출퇴근 경로를 만들어보세요.';
      default:
        return '';
    }
  }

  // 경로 데이터를 영구 저장소로 복사
  Future<void> _saveRouteDataPermanently() async {
    try {
      print('=== 경로 데이터 영구 저장 시작 ===');

      // 임시 저장소에서 경로 데이터 읽기
      final tempDeparture = _storage.read('onboarding_departure');
      final tempArrival = _storage.read('onboarding_arrival');
      final tempTransfers = _storage.read<List>('onboarding_transfers');

      print('📊 임시 저장소 데이터 확인:');
      print('   tempDeparture: $tempDeparture (type: ${tempDeparture.runtimeType})');
      print('   tempArrival: $tempArrival (type: ${tempArrival.runtimeType})');
      print('   tempTransfers: $tempTransfers');

      // 경로 데이터가 있는 경우에만 저장
      if (tempDeparture != null && tempArrival != null) {
        // 경로명도 저장된 것이 있으면 사용, 없으면 자동 생성
        final savedRouteName = _storage.read<String>('onboarding_route_name');

        // 출발지/도착지 이름 추출 (Map인 경우와 String인 경우 모두 처리)
        String departureName;
        String arrivalName;

        if (tempDeparture is Map) {
          departureName = tempDeparture['name'] ?? '출발지';
        } else {
          departureName = tempDeparture.toString();
        }

        if (tempArrival is Map) {
          arrivalName = tempArrival['name'] ?? '도착지';
        } else {
          arrivalName = tempArrival.toString();
        }

        final finalRouteName = savedRouteName ?? routeName.value ?? '$departureName → $arrivalName';

        final newRoute = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': finalRouteName,
          'departure': tempDeparture is Map ? tempDeparture : {
            'name': departureName,
            'type': _guessTransportType(departureName),
            'lineInfo': '',
            'code': '',
          },
          'arrival': tempArrival is Map ? tempArrival : {
            'name': arrivalName,
            'type': _guessTransportType(arrivalName),
            'lineInfo': '',
            'code': '',
          },
          'transfers': tempTransfers ?? [],
          'createdAt': DateTime.now().toIso8601String(),
        };

        final savedRoutes = [newRoute];
        await _storage.write('saved_routes', savedRoutes);
        print('📋 온보딩 경로 저장: $routeName');
      }

      print('✅ 경로 데이터 영구 저장 완료');

    } catch (e) {
      print('경로 데이터 영구 저장 오류: $e');
    }
  }

  // 온보딩 임시 데이터 정리
  Future<void> _clearOnboardingTempData() async {
    try {
      // 경로 설정 관련 임시 데이터 제거
      await _storage.remove('onboarding_departure');
      await _storage.remove('onboarding_arrival');
      await _storage.remove('onboarding_transfers');
      await _storage.remove('onboarding_route_name');

      // 근무시간 설정 관련 임시 데이터 제거
      await _storage.remove('onboarding_work_start_time');
      await _storage.remove('onboarding_work_end_time');
      await _storage.remove('onboarding_preparation_time');

      // 알림 설정 관련 임시 데이터 제거
      await _storage.remove('onboarding_departure_notification');
      await _storage.remove('onboarding_weather_notification');

      print('🧹 온보딩 임시 데이터 정리 완료');
    } catch (e) {
      print('온보딩 임시 데이터 정리 오류: $e');
    }
  }

  // 위치 이름으로 교통수단 타입 추정
  String _guessTransportType(String locationName) {
    final name = locationName.toLowerCase();

    // 버스 관련 키워드
    if (name.contains('버스') ||
        name.contains('정류장') ||
        name.contains('정류소') ||
        RegExp(r'\d+번').hasMatch(name)) {
      return 'bus';
    }

    // 지하철 관련 키워드
    if (name.contains('역') ||
        name.contains('지하철') ||
        name.contains('호선') ||
        name.contains('선') && (name.contains('분당') || name.contains('신분당') || name.contains('경의') || name.contains('중앙'))) {
      return 'subway';
    }

    // 기본값은 지하철
    return 'subway';
  }

}