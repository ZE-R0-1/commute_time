import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/services/location_service.dart';
import '../onboarding/onboarding_controller.dart';

class MapSelectionController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  
  final RxList<String> searchResults = <String>[].obs;
  final RxBool isSearching = false.obs;
  Timer? _debounceTimer;
  final Rx<MapLocation?> selectedLocation = Rx<MapLocation?>(null);
  final RxList<NearbyStation> nearbyStations = <NearbyStation>[].obs;
  final RxString title = '위치 선택'.obs;
  final RxString selectionType = 'departure'.obs;
  final RxBool multiSelect = false.obs;
  
  // 지도 관련 상태
  final RxDouble currentLat = 37.5665.obs;
  final RxDouble currentLng = 126.9780.obs;
  final RxDouble zoomLevel = 15.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _loadNearbyStations();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  void _initializeFromArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      title.value = args['title'] ?? '위치 선택';
      selectionType.value = args['type'] ?? 'departure';
      multiSelect.value = args['multiSelect'] ?? false;
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
      
      // 검색어가 변경되지 않았을 때만 결과 업데이트 (3개만)
      if (searchController.text.trim() == query) {
        searchResults.value = results.take(3).toList();
      }
      
    } catch (e) {
      print('역/정류장 검색 오류: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }
  
  void moveToSearchResult(String selectedAddress) async {
    try {
      // OnboardingController의 selectAddressFromSearch 메서드 사용
      final onboardingController = Get.find<OnboardingController>();
      await onboardingController.selectAddressFromSearch(
        searchController.text.trim(),
        selectedAddress,
        false, // isHome
      );
      
      // 기본 좌표로 설정 (실제로는 선택된 주소의 좌표를 받아와야 함)
      selectedLocation.value = MapLocation(
        latitude: currentLat.value,
        longitude: currentLng.value,
        address: selectedAddress,
        placeName: null,
      );
      
      searchResults.clear();
      searchController.clear();
      
      _loadNearbyStations();
    } catch (e) {
      print('위치 이동 오류: $e');
    }
  }
  
  void moveToCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        currentLat.value = location.latitude;
        currentLng.value = location.longitude;
        
        selectedLocation.value = MapLocation(
          latitude: location.latitude,
          longitude: location.longitude,
          address: location.address,
          placeName: '현재 위치',
        );
        
        _loadNearbyStations();
      }
    } catch (e) {
      Get.snackbar(
        '위치 오류',
        '현재 위치를 가져올 수 없습니다.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  void zoomIn() {
    if (zoomLevel.value < 18) {
      zoomLevel.value += 1;
    }
  }
  
  void zoomOut() {
    if (zoomLevel.value > 10) {
      zoomLevel.value -= 1;
    }
  }
  
  void selectStation(NearbyStation station) {
    selectedLocation.value = MapLocation(
      latitude: station.latitude,
      longitude: station.longitude,
      address: station.address,
      placeName: station.name,
    );
    
    Get.snackbar(
      '정류장 선택',
      '${station.name}이 선택되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }
  
  void confirmSelection() {
    if (selectedLocation.value != null) {
      Get.back(result: selectedLocation.value);
    }
  }
  
  void _loadNearbyStations() {
    // 실제 구현에서는 현재 위치 기반으로 근처 정류장을 검색
    // 여기서는 더미 데이터를 사용
    nearbyStations.value = [
      NearbyStation(
        id: '1',
        name: '강남역',
        type: 'subway',
        latitude: currentLat.value + 0.001,
        longitude: currentLng.value + 0.001,
        address: '서울특별시 강남구 강남대로 지하',
        distance: 120,
      ),
      NearbyStation(
        id: '2',
        name: '강남역.강남역사거리',
        type: 'bus',
        latitude: currentLat.value + 0.0005,
        longitude: currentLng.value + 0.0005,
        address: '서울특별시 강남구 강남대로',
        distance: 80,
      ),
      NearbyStation(
        id: '3',
        name: '신논현역',
        type: 'subway',
        latitude: currentLat.value - 0.001,
        longitude: currentLng.value - 0.001,
        address: '서울특별시 강남구 강남대로 지하',
        distance: 200,
      ),
      NearbyStation(
        id: '4',
        name: '신논현역.신논현역사거리',
        type: 'bus',
        latitude: currentLat.value - 0.0005,
        longitude: currentLng.value - 0.0005,
        address: '서울특별시 강남구 강남대로',
        distance: 150,
      ),
    ];
    
    // 거리순으로 정렬
    nearbyStations.sort((a, b) => a.distance.compareTo(b.distance));
  }
}

class MapLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeName;

  MapLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeName,
  });
}

class NearbyStation {
  final String id;
  final String name;
  final String type; // 'bus' or 'subway'
  final double latitude;
  final double longitude;
  final String address;
  final int distance; // 미터 단위

  NearbyStation({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.distance,
  });
}