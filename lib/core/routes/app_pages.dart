import 'package:get/get.dart';

import '../../features/splash/presentation/views/splash_screen.dart';
import '../../features/splash/splash_binding.dart';
import '../../features/onboarding/presentation/views/onboarding_screen.dart';
import '../../features/onboarding/onboarding_binding.dart';
import '../../features/main/presentation/views/main_screen.dart';
import '../../features/main/main_binding.dart';
import '../../features/location_search/presentation/views/location_search_screen.dart';
import '../../features/location_search/location_search_binding.dart';
import '../../features/settings/presentation/views/settings_screen.dart';
import '../../features/settings/settings_binding.dart';

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

    // 온보딩
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),

    // 메인 화면 (탭바 포함)
    GetPage(
      name: Routes.main,
      page: () => const MainScreen(),
      binding: MainBinding(),
    ),

    // 위치 검색 화면
    GetPage(
      name: Routes.locationSearch,
      page: () => const LocationSearchScreen(),
      binding: LocationSearchBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // 설정 화면
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}