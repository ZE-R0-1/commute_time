import 'package:get/get.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/splash/splash_binding.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/auth_binding.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/onboarding_binding.dart';
import '../../screens/main/main_tab_screen.dart';
import '../../screens/main/main_tab_binding.dart';
import '../../screens/route_detail/route_detail_screen.dart';
import '../../screens/route_detail/route_detail_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    // 스플래시
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    // 로그인
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),

    // 온보딩
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),

    // 메인 화면 (탭바 포함)
    GetPage(
      name: Routes.main,
      page: () => const MainTabScreen(),
      binding: MainTabBinding(),
    ),

    // 경로 상세 화면
    GetPage(
      name: Routes.routeDetail,
      page: () => const RouteDetailScreen(),
      binding: RouteDetailBinding(),
      transition: Transition.native,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}