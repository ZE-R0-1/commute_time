import 'package:get/get.dart';
import 'realtime_controller.dart';

class RealtimeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RealtimeController>(() => RealtimeController());
  }
}