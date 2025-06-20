import 'package:get/get.dart';

import 'route_detail_controller.dart';

class RouteDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteDetailController>(
          () => RouteDetailController(),
    );
  }
}