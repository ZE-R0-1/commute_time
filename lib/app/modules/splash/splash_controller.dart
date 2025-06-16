import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final storage = GetStorage();

  // 반응형 상태 변수들
  final RxBool isLoading = true.obs;
  final RxString loadingText = '앱을 준비하고 있어요...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 로딩 텍스트 업데이트
      loadingText.value = '설정을 불러오는 중...';
      await Future.delayed(const Duration(milliseconds: 800));

      loadingText.value = '사용자 정보 확인 중...';
      await Future.delayed(const Duration(milliseconds: 800));

      loadingText.value = '거의 완료되었어요...';
      await Future.delayed(const Duration(milliseconds: 600));

      // 로그인 상태 확인
      bool isLoggedIn = storage.read('is_logged_in') ?? false;
      bool isFirstTime = storage.read('is_first_time') ?? true;

      // 로딩 완료
      isLoading.value = false;

      if (isFirstTime) {
        // 첫 실행이면 온보딩으로 이동
        // Get.offAllNamed(AppRoutes.ONBOARDING);
        // 임시로 로그인 화면으로 이동
        _navigateToLogin();
      } else if (isLoggedIn) {
        // 로그인되어 있으면 홈으로 이동
        // Get.offAllNamed(AppRoutes.HOME);
        // 임시로 로그인 화면으로 이동
        _navigateToLogin();
      } else {
        // 로그아웃 상태면 로그인으로 이동
        _navigateToLogin();
      }
    } catch (e) {
      // 에러 처리
      Get.snackbar(
        '오류',
        '앱 초기화 중 문제가 발생했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _navigateToLogin() {
    // TODO: 로그인 화면이 구현되면 활성화
    // Get.offAllNamed(AppRoutes.LOGIN);

    // 임시: 스낵바로 성공 메시지 표시
    Get.snackbar(
      '🚇 출퇴근타임',
      '앱이 성공적으로 초기화되었습니다!\n다음 단계: 로그인 화면 구현',
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
    );
  }
}