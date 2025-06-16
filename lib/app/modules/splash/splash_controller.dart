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
        _navigateToHome();
        // 임시로 로그인 화면으로 이동
        // _navigateToLogin();
      } else if (isLoggedIn) {
        // 로그인되어 있으면 홈으로 이동
        _navigateToHome();
        // 임시로 로그인 화면으로 이동
        // _navigateToLogin();
      } else {
        _navigateToHome();
        // 로그아웃 상태면 로그인으로 이동
        // _navigateToLogin();
      }
    } catch (e) {
      print(e.toString());
      // 에러 처리
      Get.snackbar(
        '오류',
        '앱 초기화 중 문제가 발생했습니다: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _navigateToHome() {
    Get.offAllNamed(AppRoutes.HOME);
  }

  void _navigateToLogin() {
    // 로그인 화면으로 이동
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}