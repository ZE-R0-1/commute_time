import 'package:get/get.dart';
import 'route_arrival_controller.dart';

class RouteArrivalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteArrivalController>(
      () => RouteArrivalController(),
    );
  }
}