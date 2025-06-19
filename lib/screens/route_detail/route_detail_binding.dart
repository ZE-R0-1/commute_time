import 'package:get/get.dart';

import 'route_detail_controller.dart';

class RouteDetailBinding extends Bindings {
  @override
  void dependencies() {
    // RouteDetail 컨트롤러 생성
    Get.lazyPut<RouteDetailController>(
          () => RouteDetailController(),
    );
  }
}