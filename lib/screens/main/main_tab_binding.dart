import 'package:get/get.dart';

import 'main_tab_controller.dart';
import '../home/home_controller.dart';
import '../route_setup/route_setup_controller.dart';
import '../settings/settings_controller.dart';

class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    // 메인 탭 컨트롤러
    Get.put<MainTabController>(
      MainTabController(),
      permanent: true, // 앱 생명주기 동안 유지
    );

    // 홈 화면 컨트롤러
    Get.put<HomeController>(
      HomeController(),
      permanent: true,
    );

    // 경로 설정 화면 컨트롤러
    Get.lazyPut<RouteSetupController>(
          () => RouteSetupController(),
    );


    // 설정 화면 컨트롤러
    Get.lazyPut<SettingsController>(
          () => SettingsController(),
    );
  }
}