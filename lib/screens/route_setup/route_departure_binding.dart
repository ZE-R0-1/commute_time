import 'package:get/get.dart';
import 'route_departure_controller.dart';

class RouteDepartureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteDepartureController>(
      () => RouteDepartureController(),
    );
  }
}