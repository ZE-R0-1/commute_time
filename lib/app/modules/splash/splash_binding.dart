import 'package:get/get.dart';

import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // SplashController를 지연 로딩으로 주입
    // 스플래시 화면이 실제로 열릴 때만 인스턴스가 생성됩니다
    Get.lazyPut<SplashController>(() => SplashController());
  }
}