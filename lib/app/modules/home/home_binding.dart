import 'package:get/get.dart';

import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // HomeController를 지연 로딩으로 주입
    Get.lazyPut<HomeController>(() => HomeController());
  }
}