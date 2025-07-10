import 'package:get/get.dart';
import 'map_selection_controller.dart';

class MapSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapSelectionController>(
      () => MapSelectionController(),
    );
  }
}