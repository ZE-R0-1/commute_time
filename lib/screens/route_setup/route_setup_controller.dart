import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RouteSetupController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 경로 타입 (집→회사 또는 회사→집)
  final RxBool isHomeToWork = true.obs;
  
  // 경로 설정 데이터
  final RxString selectedDeparture = ''.obs;
  final RxString selectedArrival = ''.obs;
  final RxList<String> selectedTransfers = <String>[].obs;
  final RxBool routeSetupCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get.arguments로 전달받은 경로 타입 설정
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      isHomeToWork.value = arguments['isHomeToWork'] ?? true;
    }

    _loadExistingRoute();
  }

  // 기존 경로 설정 로드
  void _loadExistingRoute() {
    String routeKey = isHomeToWork.value ? 'home_to_work_route' : 'work_to_home_route';
    String existingRoute = _storage.read(routeKey) ?? '';
    
    if (existingRoute.isNotEmpty && existingRoute != '미설정') {
      // 기존 경로가 있다면 파싱해서 로드
      List<String> parts = existingRoute.split(' → ');
      if (parts.length >= 2) {
        selectedDeparture.value = parts[0];
        selectedArrival.value = parts[parts.length - 1];
        
        // 환승지가 있다면
        if (parts.length > 2) {
          selectedTransfers.value = parts.sublist(1, parts.length - 1);
        }
        
        routeSetupCompleted.value = true;
      }
    }
  }

  // 현재 단계 제목
  String get currentStepTitle {
    return isHomeToWork.value 
      ? '집 → 회사 경로를\n설정해주세요 🚌'
      : '회사 → 집 경로를\n설정해주세요 🏠';
  }

  // 현재 단계 설명
  String get currentStepDescription {
    return isHomeToWork.value
      ? '출근 시 사용할 최적의 경로를 설정하세요.\n출발지와 도착지는 필수입니다.'
      : '퇴근 시 사용할 최적의 경로를 설정하세요.\n출발지와 도착지는 필수입니다.';
  }

  // 경로 설정 완료 및 저장
  void completeRouteSetup() {
    if (!routeSetupCompleted.value) {
      Get.snackbar(
        '경로 설정 미완료',
        '출발지와 도착지를 모두 설정해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 경로 문자열 생성
    List<String> routeParts = [selectedDeparture.value];
    routeParts.addAll(selectedTransfers);
    routeParts.add(selectedArrival.value);
    String routeString = routeParts.join(' → ');

    // 저장
    String routeKey = isHomeToWork.value ? 'home_to_work_route' : 'work_to_home_route';
    _storage.write(routeKey, routeString);

    print('${isHomeToWork.value ? "집→회사" : "회사→집"} 경로 저장: $routeString');

    // 성공 메시지
    Get.snackbar(
      '경로 설정 완료',
      '${isHomeToWork.value ? "집 → 회사" : "회사 → 집"} 경로가 저장되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isHomeToWork.value ? Icons.home_work : Icons.work_history,
        color: Colors.white,
      ),
    );

    // 설정 화면으로 돌아가기
    Get.back(result: routeString);
  }

  // 취소하고 돌아가기
  void cancelRouteSetup() {
    Get.back();
  }

  // 경로 완료 상태 체크
  void checkRouteCompletion() {
    final hasDepature = selectedDeparture.value.isNotEmpty;
    final hasArrival = selectedArrival.value.isNotEmpty;
    
    routeSetupCompleted.value = hasDepature && hasArrival;
    
    if (routeSetupCompleted.value) {
      Get.snackbar(
        '필수 경로 설정 완료',
        '출발지와 도착지가 설정되었습니다!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[700],
      );
    }
  }
}