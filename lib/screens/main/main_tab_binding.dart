import 'package:get/get.dart';

import 'main_tab_controller.dart';
import '../home/home_controller.dart';
import '../map/map_controller.dart';
import '../analysis/analysis_controller.dart';
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

    // 지도 화면 컨트롤러
    Get.lazyPut<MapController>(
          () => MapController(),
    );

    // 분석 화면 컨트롤러
    Get.lazyPut<AnalysisController>(
          () => AnalysisController(),
    );

    // 설정 화면 컨트롤러
    Get.lazyPut<SettingsController>(
          () => SettingsController(),
    );
  }
}