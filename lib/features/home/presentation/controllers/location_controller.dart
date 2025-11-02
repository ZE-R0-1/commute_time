import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/usecases/check_location_permission_usecase.dart';
import '../../domain/usecases/get_current_location_usecase.dart';

/// 위치 관련 Controller
class LocationController extends GetxController {
  final GetStorage _storage = GetStorage();
  late CheckLocationPermissionUseCase _checkLocationPermissionUseCase;
  late GetCurrentLocationUseCase _getCurrentLocationUseCase;

  // 위치 정보
  final RxString currentAddress = '위치 정보 없음'.obs;
  final RxString loadingMessage = '위치 정보를 불러오는 중...'.obs;

  @override
  void onInit() {
    _checkLocationPermissionUseCase = Get.find<CheckLocationPermissionUseCase>();
    _getCurrentLocationUseCase = Get.find<GetCurrentLocationUseCase>();
    super.onInit();
    _loadSavedLocation();
  }

  // 저장된 위치 정보 로드
  void _loadSavedLocation() {
    final address = _storage.read('current_address') ??
        _storage.read('home_address') ??
        '위치 정보 없음';
    currentAddress.value = address;

    print('현재 주소: ${currentAddress.value}');
  }

  // 현재 위치 요청 및 처리
  Future<bool> requestCurrentLocation() async {
    try {
      loadingMessage.value = '위치 권한 확인 중...';

      // 위치 권한 확인 및 요청
      final permissionResult = await _checkLocationPermissionUseCase();

      if (!permissionResult.success) {
        print('위치 권한 실패: ${permissionResult.message}');
        return false;
      }

      print('위치 권한 허용됨. 현재 위치 가져오는 중...');
      loadingMessage.value = '현재 위치 가져오는 중...';

      // 현재 위치 가져오기
      final location = await _getCurrentLocationUseCase();

      if (location == null) {
        print('현재 위치 조회 실패');
        return false;
      }

      print('현재 위치: ${location.latitude}, ${location.longitude}');

      // 현재 위치 저장
      _storage.write('current_latitude', location.latitude);
      _storage.write('current_longitude', location.longitude);
      _storage.write('current_address', location.address);

      currentAddress.value = location.address;

      return true;
    } catch (e) {
      print('현재 위치 요청 오류: $e');
      return false;
    }
  }

  // 앱 설정 페이지 열기
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // 저장된 좌표 가져오기
  Map<String, double>? getSavedCoordinates() {
    final latitude = _storage.read<double>('current_latitude') ??
        _storage.read<double>('home_latitude');
    final longitude = _storage.read<double>('current_longitude') ??
        _storage.read<double>('home_longitude');

    if (latitude == null || longitude == null) {
      return null;
    }

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}