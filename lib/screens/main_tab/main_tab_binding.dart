import 'package:get/get.dart';

import 'main_tab_controller.dart';
import '../home/home_controller.dart';

class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    // 메인 탭 컨트롤러
    Get.put<MainTabController>(
      MainTabController(),
    );

    // 홈 컨트롤러 (홈 탭에서 사용)
    Get.put<HomeController>(
      HomeController(),
    );

    // TODO: 나중에 다른 탭 컨트롤러들도 추가
    // Get.lazyPut<MapController>(() => MapController());
    // Get.lazyPut<AnalysisController>(() => AnalysisController());
    // Get.lazyPut<SettingsController>(() => SettingsController());
  }
}