import 'package:get/get.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('=== 홈 화면 초기화 ===');
  }

  @override
  void onReady() {
    super.onReady();
    print('홈 화면 준비 완료');
  }

  @override
  void onClose() {
    print('홈 화면 종료');
    super.onClose();
  }
}