import 'package:get/get.dart';
import 'route_transfer_controller.dart';

class RouteTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RouteTransferController>(
      () => RouteTransferController(),
    );
  }
}