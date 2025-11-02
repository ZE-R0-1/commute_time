part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // 메인 플로우 라우트들
  static const splash = '/splash';
  static const login = '/login';
  static const onboarding = '/onboarding';
  static const main = '/main'; // 탭바가 있는 메인 화면

  // 개별 상세 화면들
  static const mapSetup = '/map-setup';
  static const routeDetail = '/route-detail';
  static const profile = '/profile';
  static const settings = '/settings';

  // 경로 설정 화면들
  static const routeSetup = '/route-setup';
  static const routeDeparture = '/route-departure';
  static const routeTransfer = '/route-transfer';
  static const routeArrival = '/route-arrival';
  static const mapSelection = '/map-selection';
  static const locationSearch = '/location-search';
}