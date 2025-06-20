import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MapController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 위치 정보
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString currentLocation = '현재 위치 확인 중...'.obs;

  // 지도 상태
  final RxBool isLoadingLocation = false.obs;
  final RxBool isSearchingRoute = false.obs;

  // 즐겨찾는 경로
  final RxList<FavoriteRoute> favoriteRoutes = <FavoriteRoute>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
    _getCurrentLocation();
    _loadFavoriteRoutes();
  }

  // 주소 정보 로드
  void _loadAddresses() {
    homeAddress.value = _storage.read('home_address') ?? '주소를 설정해주세요';
    workAddress.value = _storage.read('work_address') ?? '주소를 설정해주세요';

    print('=== 지도 화면 주소 로드 ===');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
  }

  // 현재 위치 가져오기 (Mock)
  Future<void> _getCurrentLocation() async {
    isLoadingLocation.value = true;

    try {
      // Mock: 위치 서비스 호출 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // Mock 현재 위치 설정
      currentLocation.value = '서울특별시 강남구 역삼동';

      print('현재 위치: ${currentLocation.value}');
    } catch (e) {
      currentLocation.value = '위치를 가져올 수 없습니다';
      print('위치 정보 오류: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // 즐겨찾는 경로 로드
  void _loadFavoriteRoutes() {
    // Mock 즐겨찾는 경로 데이터
    favoriteRoutes.value = [
      FavoriteRoute(
        id: '1',
        name: '평일 출근길',
        description: '지하철 2호선 → 9호선',
        estimatedTime: '52분',
        isFavorite: true,
      ),
      FavoriteRoute(
        id: '2',
        name: '버스 경로',
        description: '145번 → 472번',
        estimatedTime: '48분',
        isFavorite: false,
      ),
    ];
  }

  // 집 주소 수정
  void editHomeAddress() {
    Get.snackbar(
      '주소 수정',
      '집 주소 설정 화면으로 이동합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.home, color: Colors.white),
    );

    // TODO: 주소 설정 화면으로 이동
    print('집 주소 수정 요청');
  }

  // 회사 주소 수정
  void editWorkAddress() {
    Get.snackbar(
      '주소 수정',
      '회사 주소 설정 화면으로 이동합니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.business, color: Colors.white),
    );

    // TODO: 주소 설정 화면으로 이동
    print('회사 주소 수정 요청');
  }

  // 경로 검색
  Future<void> searchRoute() async {
    if (homeAddress.value == '주소를 설정해주세요' ||
        workAddress.value == '주소를 설정해주세요') {
      Get.snackbar(
        '주소 설정 필요',
        '집과 회사 주소를 먼저 설정해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    isSearchingRoute.value = true;

    try {
      // Mock: 경로 검색 API 호출
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        '경로 검색 완료 🗺️',
        '최적 경로를 찾았습니다. 예상 소요시간: 52분',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.primaryColor,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.route, color: Colors.white),
      );

      print('경로 검색 완료');
    } catch (e) {
      Get.snackbar(
        '경로 검색 실패',
        '경로를 찾을 수 없습니다. 다시 시도해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isSearchingRoute.value = false;
    }
  }

  // 즐겨찾는 경로 추가
  void addFavoriteRoute() {
    if (homeAddress.value == '주소를 설정해주세요' ||
        workAddress.value == '주소를 설정해주세요') {
      Get.snackbar(
        '주소 설정 필요',
        '집과 회사 주소를 먼저 설정해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Mock: 즐겨찾는 경로 추가
    final newRoute = FavoriteRoute(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '내 경로 ${favoriteRoutes.length + 1}',
      description: '사용자 정의 경로',
      estimatedTime: '예상 시간 계산 중',
      isFavorite: true,
    );

    favoriteRoutes.add(newRoute);

    Get.snackbar(
      '즐겨찾기 추가 ⭐',
      '경로가 즐겨찾기에 추가되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.star, color: Colors.white),
    );

    print('즐겨찾는 경로 추가: ${newRoute.name}');
  }

  // 현재 위치 새로고침
  Future<void> refreshCurrentLocation() async {
    currentLocation.value = '위치 확인 중...';
    await _getCurrentLocation();
  }

  // 지도 새로고침
  Future<void> refreshMap() async {
    print('지도 새로고침');
    await Future.wait([
      _getCurrentLocation(),
      Future.delayed(const Duration(milliseconds: 500)), // 지도 리로드 시뮬레이션
    ]);

    Get.snackbar(
      '지도 새로고침',
      '최신 정보로 업데이트되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }
}

// 즐겨찾는 경로 모델
class FavoriteRoute {
  final String id;
  final String name;
  final String description;
  final String estimatedTime;
  final bool isFavorite;

  FavoriteRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedTime,
    required this.isFavorite,
  });
}