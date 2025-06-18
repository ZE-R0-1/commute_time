import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/routes/app_pages.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 스플래시 화면 최소 2초 표시
    await Future.delayed(const Duration(seconds: 2));

    // 앱 초기화 작업
    await _checkAppStatus();

    // 다음 화면으로 이동 결정
    _navigateToNext();
  }

  Future<void> _checkAppStatus() async {
    // Mock: 앱 상태 체크
    // - 로그인 상태 확인
    // - 온보딩 완료 여부 확인
    // - 위치 설정 완료 여부 확인

    await Future.delayed(const Duration(milliseconds: 500));

    // 디버깅용 로그
    print('=== 스플래시 상태 체크 ===');
    print('로그인 상태: ${_storage.read('is_logged_in') ?? false}');
    print('온보딩 완료: ${_storage.read('onboarding_completed') ?? false}');
  }

  void _navigateToNext() {
    // Mock 데이터를 기반으로 네비게이션 결정
    final bool isLoggedIn = _storage.read('is_logged_in') ?? false;
    final bool isOnboardingCompleted = _storage.read('onboarding_completed') ?? false;

    print('=== 네비게이션 결정 ===');
    print('로그인 상태: $isLoggedIn');
    print('온보딩 상태: $isOnboardingCompleted');

    if (!isLoggedIn) {
      // 로그인이 안 되어 있으면 로그인 화면으로
      print('→ 로그인 화면으로 이동');
      Get.offNamed(Routes.login);
    } else if (!isOnboardingCompleted) {
      // 로그인은 되어 있지만 온보딩이 안 되어 있으면 온보딩으로
      print('→ 온보딩 화면으로 이동');
      Get.offNamed(Routes.onboarding);
    } else {
      // 모든 설정이 완료되어 있으면 홈 화면으로
      print('→ 홈 화면으로 이동');
      Get.offNamed(Routes.home);
    }
  }
}