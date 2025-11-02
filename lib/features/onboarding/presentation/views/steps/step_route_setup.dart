import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/onboarding_controller.dart';
import '../../../../../core/models/location_info.dart';
import '../components/route_setup/route_setup_header.dart';
import '../components/route_setup/route_setup_progress.dart';
import '../components/route_setup/route_name_input.dart';
import '../components/route_setup/route_setup_content.dart';
import '../components/route_setup/route_setup_bottom_button.dart';

class StepRouteSetup extends GetView<OnboardingController> {
  const StepRouteSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments에서 모드 확인
    final arguments = Get.arguments as Map<String, dynamic>?;
    final isAddNewMode = arguments?['mode'] == 'add_new';
    final customTitle = arguments?['title'] as String?;

    // 로컬 상태 관리 (GetStorage에서 복원)
    final RxnString selectedDeparture = RxnString();
    final Rx<LocationInfo?> selectedDepartureInfo = Rx<LocationInfo?>(null);
    final RxList<LocationInfo> transferStations = <LocationInfo>[].obs;
    final RxnString selectedArrival = RxnString();
    final Rx<LocationInfo?> selectedArrivalInfo = Rx<LocationInfo?>(null);
    // 온보딩 모드면 기본값으로 '출근경로' 설정
    final RxnString routeName = RxnString(isAddNewMode ? null : '출근경로');

    // 저장된 데이터 복원
    _loadSavedRouteData(
      selectedDeparture,
      transferStations,
      selectedArrival,
      routeName,
      isAddNewMode,
      selectedDepartureInfo,
      selectedArrivalInfo,
    );

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
                RouteSetupHeader(
                  isAddNewMode: isAddNewMode,
                  customTitle: customTitle,
                ),

                // 진행률 표시 (온보딩 모드에서만)
                if (!isAddNewMode) const RouteSetupProgress(),

                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 경로 이름 입력 필드 (모든 모드에서 표시)
                        RouteNameInput(routeName: routeName),
                        const SizedBox(height: 16),

                        // 출발지, 환승지, 도착지 선택 UI
                        RouteSetupContent(
                          selectedDeparture: selectedDeparture,
                          selectedDepartureInfo: selectedDepartureInfo,
                          transferStations: transferStations,
                          selectedArrival: selectedArrival,
                          selectedArrivalInfo: selectedArrivalInfo,
                        ),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                // 커스텀 하단 버튼
                RouteSetupBottomButton(
                  selectedDeparture: selectedDeparture,
                  selectedArrival: selectedArrival,
                  transferStations: transferStations,
                  routeName: routeName,
                  isAddNewMode: isAddNewMode,
                  selectedDepartureInfo: selectedDepartureInfo,
                  selectedArrivalInfo: selectedArrivalInfo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 저장된 경로 데이터 복원
  void _loadSavedRouteData(
    RxnString selectedDeparture,
    RxList<LocationInfo> transferStations,
    RxnString selectedArrival,
    RxnString routeName,
    bool isAddNewMode,
    Rx<LocationInfo?> selectedDepartureInfo,
    Rx<LocationInfo?> selectedArrivalInfo,
  ) {
    final storage = GetStorage();

    // 새 경로 추가 모드라면 깨끗한 상태로 시작
    if (isAddNewMode) {
      print('🆕 새 경로 추가 모드 - 깨끗한 상태로 시작');
      return;
    }

    // 온보딩 모드에서는 기존 데이터 복원
    // 출발지 복원 (Map 또는 String 지원)
    final savedDeparture = storage.read('onboarding_departure');
    if (savedDeparture != null) {
      if (savedDeparture is Map) {
        selectedDeparture.value = savedDeparture['name'];
        selectedDepartureInfo.value = LocationInfo.fromMap(
          Map<String, dynamic>.from(savedDeparture)
        );
        print('🔄 출발지 복원 (Map): ${savedDeparture['name']}');
      } else {
        selectedDeparture.value = savedDeparture.toString();
        print('🔄 출발지 복원 (String): $savedDeparture');
      }
    }

    // 도착지 복원 (Map 또는 String 지원)
    final savedArrival = storage.read('onboarding_arrival');
    if (savedArrival != null) {
      if (savedArrival is Map) {
        selectedArrival.value = savedArrival['name'];
        selectedArrivalInfo.value = LocationInfo.fromMap(
          Map<String, dynamic>.from(savedArrival)
        );
        print('🔄 도착지 복원 (Map): ${savedArrival['name']}');
      } else {
        selectedArrival.value = savedArrival.toString();
        print('🔄 도착지 복원 (String): $savedArrival');
      }
    }

    // 경로명 복원
    final savedRouteName = storage.read<String>('onboarding_route_name');
    if (savedRouteName != null) {
      routeName.value = savedRouteName;
      print('🔄 경로명 복원: $savedRouteName');
    }

    // 환승지들 복원
    final savedTransfers = storage.read<List>('onboarding_transfers');
    if (savedTransfers != null) {
      transferStations.clear();
      for (final transfer in savedTransfers) {
        if (transfer is Map) {
          transferStations.add(LocationInfo.fromMap(
            Map<String, dynamic>.from(transfer)
          ));
        }
      }
      print('🔄 환승지 복원: ${transferStations.length}개');
    }

    // 데이터 변경 감지 및 자동 저장 설정 (온보딩 모드에서만)
    selectedDeparture.listen((value) => _saveRouteData(
        selectedDeparture,
        transferStations,
        selectedArrival,
        routeName,
        selectedDepartureInfo,
        selectedArrivalInfo));
    selectedArrival.listen((value) => _saveRouteData(
        selectedDeparture,
        transferStations,
        selectedArrival,
        routeName,
        selectedDepartureInfo,
        selectedArrivalInfo));
    transferStations.listen((value) => _saveRouteData(
        selectedDeparture,
        transferStations,
        selectedArrival,
        routeName,
        selectedDepartureInfo,
        selectedArrivalInfo));
    routeName.listen((value) => _saveRouteData(
        selectedDeparture,
        transferStations,
        selectedArrival,
        routeName,
        selectedDepartureInfo,
        selectedArrivalInfo));
  }

  // 경로 데이터 저장
  void _saveRouteData(
    RxnString selectedDeparture,
    RxList<LocationInfo> transferStations,
    RxnString selectedArrival,
    RxnString routeName,
    Rx<LocationInfo?> selectedDepartureInfo,
    Rx<LocationInfo?> selectedArrivalInfo,
  ) {
    final storage = GetStorage();

    // 출발지 저장 (LocationInfo 객체로 저장)
    if (selectedDepartureInfo.value != null) {
      storage.write('onboarding_departure', selectedDepartureInfo.value!.toMap());
    } else if (selectedDeparture.value != null) {
      // fallback: name만 있는 경우 (지하철로 추정)
      storage.write('onboarding_departure', {
        'name': selectedDeparture.value,
        'type': 'subway',
        'lineInfo': '',
        'code': '',
      });
    } else {
      storage.remove('onboarding_departure');
    }

    // 도착지 저장 (LocationInfo 객체로 저장)
    if (selectedArrivalInfo.value != null) {
      storage.write('onboarding_arrival', selectedArrivalInfo.value!.toMap());
    } else if (selectedArrival.value != null) {
      // fallback: name만 있는 경우 (지하철로 추정)
      storage.write('onboarding_arrival', {
        'name': selectedArrival.value,
        'type': 'subway',
        'lineInfo': '',
        'code': '',
      });
    } else {
      storage.remove('onboarding_arrival');
    }

    // 경로명 저장
    if (routeName.value != null && routeName.value!.trim().isNotEmpty) {
      storage.write('onboarding_route_name', routeName.value!.trim());
    } else {
      storage.remove('onboarding_route_name');
    }

    // 환승지들 저장
    if (transferStations.isNotEmpty) {
      final transfersData = transferStations
          .map((transfer) => transfer.toMap())
          .toList();
      storage.write('onboarding_transfers', transfersData);
    } else {
      storage.remove('onboarding_transfers');
    }

    print('💾 경로 데이터 저장 완료');
    print('   경로명: ${routeName.value}');
    print('   출발지: ${selectedDeparture.value}');
    print('   도착지: ${selectedArrival.value}');
    print('   환승지: ${transferStations.length}개');
  }
}