import 'package:get/get.dart';

import 'home_controller.dart';
import '../../services/subway_api_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // SubwayApiService를 먼저 주입
    Get.lazyPut<SubwayApiService>(() => SubwayApiService());

    // HomeController를 지연 로딩으로 주입
    Get.lazyPut<HomeController>(() => HomeController());
  }
}