import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/services/kakao_address_service.dart';
import '../onboarding/onboarding_controller.dart';

class RouteArrivalController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final GetStorage _storage = GetStorage();
  
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;
  Timer? _debounceTimer;
  final RxString savedWorkAddress = ''.obs;
  final RxList<LocationData> recentLocations = <LocationData>[].obs;
  final Rx<LocationData?> selectedLocation = Rx<LocationData?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    _loadRecentLocations();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  void _loadSavedData() {
    final workAddress = _storage.read('work_address') ?? '';
    savedWorkAddress.value = workAddress;
  }
  
  void _loadRecentLocations() {
    final recentData = _storage.read('recent_arrival_locations') as List?;
    if (recentData != null) {
      recentLocations.value = recentData.map((item) => LocationData(
        address: item['address'] ?? '',
        placeName: item['placeName'],
        latitude: item['latitude']?.toDouble(),
        longitude: item['longitude']?.toDouble(),
        lastUsed: DateTime.parse(item['lastUsed'] ?? DateTime.now().toIso8601String()),
      )).toList();
      
      // 최근 사용 순으로 정렬
      recentLocations.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
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
  
  void selectLocation(String selectedAddress) async {
    try {
      // OnboardingController의 selectAddressFromSearch 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      await onboardingController.selectAddressFromSearch(
        searchController.text.trim(),
        selectedAddress,
        false, // isHome - 도착지는 false
      );
      
      // 선택된 주소로 LocationData 생성
      final locationData = LocationData(
        address: selectedAddress,
        placeName: null,
        latitude: null,
        longitude: null,
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    } catch (e) {
      print('위치 선택 오류: $e');
    }
  }
  
  void useSavedWorkAddress() {
    if (savedWorkAddress.value.isNotEmpty) {
      final locationData = LocationData(
        address: savedWorkAddress.value,
        placeName: '회사',
        latitude: _storage.read('work_latitude')?.toDouble(),
        longitude: _storage.read('work_longitude')?.toDouble(),
        lastUsed: DateTime.now(),
      );
      
      _saveLocationAndReturn(locationData);
    }
  }
  
  void selectFromMap() {
    Get.toNamed('/map-selection', arguments: {
      'type': 'arrival',
      'title': '도착지 선택',
    });
  }
  
  void selectRecentLocation(LocationData location) {
    final updatedLocation = LocationData(
      address: location.address,
      placeName: location.placeName,
      latitude: location.latitude,
      longitude: location.longitude,
      lastUsed: DateTime.now(),
    );
    
    _saveLocationAndReturn(updatedLocation);
  }
  
  void _saveLocationAndReturn(LocationData location) {
    selectedLocation.value = location;
    
    // 최근 위치에 추가
    _addToRecentLocations(location);
    
    // 결과 반환
    Get.back(result: location);
  }
  
  void _addToRecentLocations(LocationData location) {
    // 중복 제거
    recentLocations.removeWhere((item) => item.address == location.address);
    
    // 새 위치를 맨 앞에 추가
    recentLocations.insert(0, location);
    
    // 최대 10개까지만 유지
    if (recentLocations.length > 10) {
      recentLocations.removeRange(10, recentLocations.length);
    }
    
    // 저장
    _saveRecentLocations();
  }
  
  void _saveRecentLocations() {
    final recentData = recentLocations.map((location) => {
      'address': location.address,
      'placeName': location.placeName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'lastUsed': location.lastUsed.toIso8601String(),
    }).toList();
    
    _storage.write('recent_arrival_locations', recentData);
  }
}

class LocationData {
  final String address;
  final String? placeName;
  final double? latitude;
  final double? longitude;
  final DateTime lastUsed;

  LocationData({
    required this.address,
    this.placeName,
    this.latitude,
    this.longitude,
    required this.lastUsed,
  });
}