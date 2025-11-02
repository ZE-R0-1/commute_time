import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../../core/models/location_info.dart';
import '../../../controllers/onboarding_controller.dart';

class RouteSetupBottomButton extends StatelessWidget {
  final RxnString selectedDeparture;
  final RxnString selectedArrival;
  final RxList<LocationInfo> transferStations;
  final RxnString routeName;
  final bool isAddNewMode;
  final Rx<LocationInfo?> selectedDepartureInfo;
  final Rx<LocationInfo?> selectedArrivalInfo;

  const RouteSetupBottomButton({
    super.key,
    required this.selectedDeparture,
    required this.selectedArrival,
    required this.transferStations,
    required this.routeName,
    required this.isAddNewMode,
    required this.selectedDepartureInfo,
    required this.selectedArrivalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final bool canProceed = selectedDeparture.value != null &&
            selectedArrival.value != null &&
            routeName.value != null &&
            routeName.value!.trim().isNotEmpty;

        return GestureDetector(
          onTap: canProceed
              ? () {
                  if (isAddNewMode) {
                    _saveNewRoute();
                  } else {
                    // 온보딩 모드에서도 경로명 검증
                    if (routeName.value == null ||
                        routeName.value!.trim().isEmpty) {
                      Get.snackbar(
                        '경로명 필요',
                        '경로 이름을 입력해주세요.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                      );
                      return;
                    }
                    // OnboardingController가 등록되어 있는지 확인 후 호출
                    if (Get.isRegistered<OnboardingController>()) {
                      Get.find<OnboardingController>().nextStep();
                    } else {
                      print('⚠️ OnboardingController가 등록되지 않음 - 온보딩 모드가 아닐 수 있음');
                      Get.back();
                    }
                  }
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: canProceed
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF3B82F6), // 파란색
                        Color(0xFF6366F1), // 인디고색
                      ],
                    )
                  : null,
              color: canProceed ? null : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: canProceed
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                isAddNewMode ? '경로 저장' : '다음 단계',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // 새 경로 저장 (새 경로 추가 모드용)
  void _saveNewRoute() {
    final storage = GetStorage();

    // 현재 설정된 경로를 새 경로로 저장
    if (selectedDeparture.value != null && selectedArrival.value != null) {
      // 경로 이름이 반드시 필요함 (자동생성 로직 제거)
      if (routeName.value == null || routeName.value!.trim().isEmpty) {
        Get.snackbar(
          '경로명 필요',
          '경로 이름을 입력해주세요.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }

      final finalRouteName = routeName.value!.trim();

      // 새 경로 데이터 생성
      final newRoute = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
        'name': finalRouteName,
        'departure': selectedDepartureInfo.value != null
            ? {
                'name': selectedDepartureInfo.value!.name,
                'type': selectedDepartureInfo.value!.type,
                'lineInfo': selectedDepartureInfo.value!.lineInfo,
                'code': selectedDepartureInfo.value!.code,
              }
            : {
                'name': selectedDeparture.value,
                'type': 'unknown',
                'lineInfo': '',
                'code': '',
              },
        'arrival': selectedArrivalInfo.value != null
            ? {
                'name': selectedArrivalInfo.value!.name,
                'type': selectedArrivalInfo.value!.type,
                'lineInfo': selectedArrivalInfo.value!.lineInfo,
                'code': selectedArrivalInfo.value!.code,
              }
            : {
                'name': selectedArrival.value,
                'type': 'unknown',
                'lineInfo': '',
                'code': '',
              },
        'transfers': transferStations
            .map((transfer) => {
                  'name': transfer.name,
                  'type': transfer.type,
                  'lineInfo': transfer.lineInfo,
                  'code': transfer.code,
                })
            .toList(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 기존 경로 목록 가져오기
      final existingRoutes = storage.read<List>('saved_routes') ?? [];
      final routesList = List<Map<String, dynamic>>.from(
          existingRoutes.map((route) => Map<String, dynamic>.from(route as Map)));

      // 새 경로 추가
      routesList.add(newRoute);

      // 업데이트된 경로 목록 저장
      storage.write('saved_routes', routesList);

      // 첫 번째 경로라면 현재 경로로도 설정 (기존 로직과 호환성 유지)
      if (routesList.length == 1) {
        // 구 형식 저장 (호환성 유지)
        storage.write('saved_departure', selectedDeparture.value);
        storage.write('saved_arrival', selectedArrival.value);
        storage.write('saved_route_name', finalRouteName);

        if (transferStations.isNotEmpty) {
          final transfersData = transferStations
              .map((transfer) => {
                    'name': transfer.name,
                    'type': transfer.type,
                    'lineInfo': transfer.lineInfo,
                    'code': transfer.code,
                  })
              .toList();
          storage.write('saved_transfers', transfersData);
        } else {
          storage.remove('saved_transfers');
        }

        // 활성 경로 ID 설정
        storage.write('active_route_id', newRoute['id']);
      }

      print('🆕 새 경로 저장 완료');
      print('   경로 ID: ${newRoute['id']}');
      print('   경로 이름: $finalRouteName');
      print('   출발지: ${selectedDeparture.value}');
      print('   도착지: ${selectedArrival.value}');
      print('   환승지: ${transferStations.length}개');
      print('   총 경로 수: ${routesList.length}개');

      // 이전 화면으로 돌아가기 (성공 결과 전달)
      Get.back(result: true);
    }
  }
}