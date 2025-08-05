import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RouteSetupController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 온보딩에서 저장한 경로 정보
  final RxString departure = ''.obs;
  final RxString arrival = ''.obs;
  final RxList<String> transfers = <String>[].obs;
  
  // 수정 모드 상태
  final RxBool isEditMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('=== 경로 설정 화면 초기화 ===');
    _loadOnboardingRouteData();
  }

  @override
  void onReady() {
    super.onReady();
    print('경로 설정 화면 준비 완료');
  }

  @override
  void onClose() {
    print('경로 설정 화면 종료');
    super.onClose();
  }

  // 온보딩에서 저장한 경로 데이터 로드 (영구 저장소에서)
  void _loadOnboardingRouteData() {
    print('=== 온보딩 경로 데이터 로딩 ===');

    // 출발지 로드 (영구 저장소에서)
    final savedDeparture = _storage.read<String>('saved_departure');
    if (savedDeparture != null) {
      departure.value = savedDeparture;
      print('출발지: $savedDeparture');
    }

    // 도착지 로드 (영구 저장소에서)
    final savedArrival = _storage.read<String>('saved_arrival');
    if (savedArrival != null) {
      arrival.value = savedArrival;
      print('도착지: $savedArrival');
    }

    // 환승지들 로드 (영구 저장소에서)
    final savedTransfers = _storage.read<List>('saved_transfers');
    if (savedTransfers != null) {
      transfers.clear();
      for (final transfer in savedTransfers) {
        if (transfer is Map && transfer['name'] != null) {
          transfers.add(transfer['name']);
        }
      }
      print('환승지: ${transfers.length}개 - ${transfers.join(', ')}');
    }

    if (departure.value.isEmpty && arrival.value.isEmpty && transfers.isEmpty) {
      print('저장된 경로 정보가 없습니다.');
    } else {
      print('경로 정보 로딩 완료');
    }
  }

  // 새 경로 추가 버튼 클릭 시
  void addNewRoute() {
    print('새 경로 추가 버튼 클릭');
    
    // TODO: 새 경로 추가 화면으로 이동하거나 다이얼로그 표시
    // 지금은 임시로 스낵바 표시
    Get.snackbar(
      '새 경로 추가',
      '새로운 출퇴근 경로를 추가하는 기능입니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2196F3),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  // 경로 수정 버튼 클릭 시
  void editRoute() {
    print('경로 수정 버튼 클릭');
    isEditMode.value = !isEditMode.value;
    print(isEditMode.value ? '수정 모드 활성화' : '수정 모드 비활성화');
  }

  // 출발지 수정
  void editDeparture() async {
    print('출발지 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'departure',
      'title': '출발지 수정'
    });
    
    if (result != null && result['name'] != null) {
      departure.value = result['name'];
      await _storage.write('saved_departure', result['name']);
      
      Get.snackbar(
        '출발지 수정 완료',
        '${result['name']}로 변경되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.location_on, color: Colors.white),
      );
      
      print('출발지 수정 완료: ${result['name']}');
    }
  }

  // 도착지 수정
  void editArrival() async {
    print('도착지 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'arrival',
      'title': '도착지 수정'
    });
    
    if (result != null && result['name'] != null) {
      arrival.value = result['name'];
      await _storage.write('saved_arrival', result['name']);
      
      Get.snackbar(
        '도착지 수정 완료',
        '${result['name']}로 변경되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.flag, color: Colors.white),
      );
      
      print('도착지 수정 완료: ${result['name']}');
    }
  }

  // 환승지 수정
  void editTransfer(int index) async {
    print('환승지 $index 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 ${index + 1} 수정'
    });
    
    if (result != null && result['name'] != null) {
      transfers[index] = result['name'];
      
      // 환승지 데이터를 맵 형태로 저장
      final transfersData = transfers.map((name) => {'name': name}).toList();
      await _storage.write('saved_transfers', transfersData);
      
      Get.snackbar(
        '환승지 수정 완료',
        '환승지 ${index + 1}이 ${result['name']}로 변경되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF97316),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.transfer_within_a_station, color: Colors.white),
      );
      
      print('환승지 $index 수정 완료: ${result['name']}');
    }
  }

  // 환승지 삭제
  void deleteTransfer(int index) async {
    print('환승지 $index 삭제');
    
    final transferName = transfers[index];
    transfers.removeAt(index);
    
    // 환승지 데이터를 맵 형태로 저장
    final transfersData = transfers.map((name) => {'name': name}).toList();
    await _storage.write('saved_transfers', transfersData);
    
    Get.snackbar(
      '환승지 삭제 완료',
      '$transferName이 삭제되었습니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // 환승지 추가
  void addTransfer() async {
    print('환승지 추가 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 추가'
    });
    
    if (result != null && result['name'] != null) {
      transfers.add(result['name']);
      
      // 환승지 데이터를 맵 형태로 저장
      final transfersData = transfers.map((name) => {'name': name}).toList();
      await _storage.write('saved_transfers', transfersData);
      
      Get.snackbar(
        '환승지 추가 완료',
        '${result['name']}이 추가되었습니다.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF97316),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.add_location, color: Colors.white),
      );
      
      print('환승지 추가 완료: ${result['name']}');
    }
  }
}