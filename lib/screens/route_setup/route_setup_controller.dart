import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RouteSetupController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 온보딩에서 저장한 경로 정보
  final RxString departure = ''.obs;
  final RxString arrival = ''.obs;
  final RxList<String> transfers = <String>[].obs;

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
    
    // TODO: 경로 수정 화면으로 이동하거나 다이얼로그 표시
    // 지금은 임시로 스낵바 표시
    Get.snackbar(
      '경로 수정',
      '기존 출퇴근 경로를 수정하는 기능입니다.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.edit, color: Colors.white),
    );
  }
}