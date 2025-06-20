part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // 메인 플로우 라우트들
  static const splash = '/splash';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const main = '/main'; // 탭바가 있는 메인 화면

  // 개별 상세 화면들 (MainTabScreen 외부에서 접근)
  static const mapSetup = '/map-setup';
  static const routeDetail = '/route-detail';
  static const profile = '/profile';
}