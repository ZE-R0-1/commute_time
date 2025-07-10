import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../onboarding/onboarding_controller.dart';

class RouteTransferController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;
  Timer? _debounceTimer;
  final RxList<TransferLocation> transferLocations = <TransferLocation>[].obs;
  final RxList<TransferLocation> recentTransferLocations = <TransferLocation>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadRecentTransferLocations();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  void _loadRecentTransferLocations() {
    final recentData = _storage.read('recent_transfer_locations') as List?;
    if (recentData != null) {
      recentTransferLocations.value = recentData.map((item) => TransferLocation(
        id: item['id'] ?? '',
        address: item['address'] ?? '',
        placeName: item['placeName'],
        latitude: item['latitude']?.toDouble(),
        longitude: item['longitude']?.toDouble(),
        lastUsed: DateTime.parse(item['lastUsed'] ?? DateTime.now().toIso8601String()),
      )).toList();
      
      // 최근 사용 순으로 정렬
      recentTransferLocations.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    }
  }
  
  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.length <= 1) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.length > 1) {
        await _searchAddress(query);
      }
    });
  }
  
  Future<void> _searchAddress(String query) async {
    try {
      isSearching.value = true;
      
      // OnboardingController의 searchAddress 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      final results = await onboardingController.searchAddress(query);
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트 (10개로 증가)
      if (searchController.text.trim() == query) {
        searchResults.value = results.take(10).toList();
      }
      
    } catch (e) {
      print('역/정류장 검색 오류: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }
  
  void addTransferLocation(String selectedAddress) async {
    try {
      // OnboardingController의 selectAddressFromSearch 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      await onboardingController.selectAddressFromSearch(
        searchController.text.trim(),
        selectedAddress,
        false, // isHome - 환승지는 false
      );
      
      final transferLocation = TransferLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        address: selectedAddress,
        placeName: null,
        latitude: null,
        longitude: null,
        lastUsed: DateTime.now(),
      );
      
      transferLocations.add(transferLocation);
      _addToRecentTransferLocations(transferLocation);
      
      // 검색 결과 제거
      searchResults.remove(selectedAddress);
      searchController.clear();
      
      Get.snackbar(
        '환승지 추가',
        '$selectedAddress가 추가되었습니다.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('환승지 추가 오류: $e');
    }
  }
  
  void addRecentTransferLocation(TransferLocation location) {
    final newLocation = TransferLocation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: location.address,
      placeName: location.placeName,
      latitude: location.latitude,
      longitude: location.longitude,
      lastUsed: DateTime.now(),
    );
    
    transferLocations.add(newLocation);
    _addToRecentTransferLocations(newLocation);
    
    Get.snackbar(
      '환승지 추가',
      '${location.placeName ?? location.address}가 추가되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  void removeTransferLocation(TransferLocation location) {
    transferLocations.remove(location);
    
    Get.snackbar(
      '환승지 제거',
      '${location.placeName ?? location.address}가 제거되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
  
  void reorderTransferLocations(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    
    final item = transferLocations.removeAt(oldIndex);
    transferLocations.insert(newIndex, item);
    
    Get.snackbar(
      '순서 변경',
      '환승지 순서가 변경되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }
  
  void addFromMap() {
    Get.toNamed('/map-selection', arguments: {
      'type': 'transfer',
      'title': '환승지 선택',
      'multiSelect': true,
    });
  }
  
  bool isLocationSelected(String selectedAddress) {
    return transferLocations.any((location) => location.address == selectedAddress);
  }
  
  bool isLocationSelectedByAddress(String address) {
    return transferLocations.any((location) => location.address == address);
  }
  
  void _addToRecentTransferLocations(TransferLocation location) {
    // 중복 제거
    recentTransferLocations.removeWhere((item) => item.address == location.address);
    
    // 새 위치를 맨 앞에 추가
    recentTransferLocations.insert(0, location);
    
    // 최대 10개까지만 유지
    if (recentTransferLocations.length > 10) {
      recentTransferLocations.removeRange(10, recentTransferLocations.length);
    }
    
    // 저장
    _saveRecentTransferLocations();
  }
  
  void _saveRecentTransferLocations() {
    final recentData = recentTransferLocations.map((location) => {
      'id': location.id,
      'address': location.address,
      'placeName': location.placeName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lastUsed': location.lastUsed.toIso8601String(),
    }).toList();
    
    _storage.write('recent_transfer_locations', recentData);
  }
}

class TransferLocation {
  final String id;
  final String address;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final DateTime lastUsed;

  TransferLocation({
    required this.id,
    required this.address,
    this.placeName,
    this.latitude,
    this.longitude,
    required this.lastUsed,
  });
}