import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/splash/splash_binding.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/auth_binding.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/onboarding/onboarding_binding.dart';
import '../../screens/main_tab/main_tab_screen.dart';
import '../../screens/main_tab/main_tab_binding.dart';
import '../../screens/route_detail/route_detail_screen.dart';
import '../../screens/route_detail/route_detail_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),

    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainTabScreen(),
      binding: MainTabBinding(),
    ),

    GetPage(
      name: Routes.routeDetail,
      page: () => const RouteDetailScreen(),
      binding: RouteDetailBinding(),
    ),
    GetPage(
      name: Routes.map,
      page: () => const _PlaceholderScreen(title: '지도 화면'),
    ),
    GetPage(
      name: Routes.analysis,
      page: () => const _PlaceholderScreen(title: '분석 화면'),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const _PlaceholderScreen(title: '설정 화면'),
    ),
  ];
}

// 임시 플레이스홀더 화면
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title\n(구현 예정)',
              style: Get.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.login),
              child: const Text('로그인 화면으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}