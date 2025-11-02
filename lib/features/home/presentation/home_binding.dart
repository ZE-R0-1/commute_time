import 'package:get/get.dart';

import 'controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // 통합 HomeController 등록 (다른 Controllers는 MainBinding에서 등록됨)
    Get.put<HomeController>(
      HomeController(),
    );
  }
}