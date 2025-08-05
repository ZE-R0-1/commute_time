import 'package:get/get.dart';

import 'route_setup_controller.dart';

class RouteSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteSetupController>(() => RouteSetupController());
  }
}