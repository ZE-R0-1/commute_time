import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../app/routes/app_pages.dart';

enum LoginType { kakao, google, email }

class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 로딩 상태 관리
  final RxBool isLoading = false.obs;
  final RxString loadingMessage = ''.obs;

  // Mock 사용자 데이터
  final Map<LoginType, Map<String, dynamic>> _mockUsers = {
    LoginType.kakao: {
      'id': 'kakao_123456',
      'name': '김직장',
      'email': 'kimjikjang@kakao.com',
      'profileImage': 'https://example.com/profile.jpg',
      'provider': 'kakao',
    },
    LoginType.google: {
      'id': 'google_789012',
      'name': '이출근',
      'email': 'lee.commute@gmail.com',
      'profileImage': 'https://example.com/profile2.jpg',
      'provider': 'google',
    },
    LoginType.email: {
      'id': 'email_345678',
      'name': '박퇴근',
      'email': 'park@example.com',
      'profileImage': null,
      'provider': 'email',
    },
  };

  // 카카오 로그인
  Future<void> signInWithKakao() async {
    await _performLogin(LoginType.kakao, '카카오 계정으로 로그인 중...');
  }

  // 구글 로그인
  Future<void> signInWithGoogle() async {
    await _performLogin(LoginType.google, '구글 계정으로 로그인 중...');
  }

  // 이메일 로그인 (추후 구현)
  Future<void> signInWithEmail(String email, String password) async {
    await _performLogin(LoginType.email, '이메일로 로그인 중...');
  }

  // 공통 로그인 로직
  Future<void> _performLogin(LoginType type, String message) async {
    try {
      isLoading.value = true;
      loadingMessage.value = message;

      // Mock: 로그인 API 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // Mock: 사용자 정보 저장
      final userData = _mockUsers[type]!;
      await _saveUserData(userData);

      // 성공 메시지
      Get.snackbar(
        '로그인 성공',
        '${userData['name']}님, 환영합니다!',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 온보딩 여부 확인 후 네비게이션
      _navigateAfterLogin();

    } catch (e) {
      // 에러 처리
      Get.snackbar(
        '로그인 실패',
        '로그인 중 오류가 발생했습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  // 사용자 데이터 저장
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    await _storage.write('is_logged_in', true);
    await _storage.write('user_data', userData);
    await _storage.write('login_timestamp', DateTime.now().toIso8601String());
  }

  // 로그인 후 네비게이션
  void _navigateAfterLogin() {
    final bool isOnboardingCompleted = _storage.read('onboarding_completed') ?? false;

    if (!isOnboardingCompleted) {
      // 온보딩이 완료되지 않았으면 온보딩으로
      Get.offNamed(Routes.onboarding);
    } else {
      // 온보딩이 완료되었으면 홈으로
      Get.offNamed(Routes.home);
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // Mock: 로그아웃 처리
      await _storage.remove('is_logged_in');
      await _storage.remove('user_data');
      await _storage.remove('login_timestamp');

      Get.offAllNamed(Routes.login);

      Get.snackbar(
        '로그아웃',
        '로그아웃되었습니다.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        '오류',
        '로그아웃 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // 현재 사용자 정보 가져오기
  Map<String, dynamic>? get currentUser => _storage.read('user_data');

  // 로그인 상태 확인
  bool get isLoggedIn => _storage.read('is_logged_in') ?? false;
}