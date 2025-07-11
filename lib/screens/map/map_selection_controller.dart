import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../app/services/kakao_address_service.dart';

class MapSelectionController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  
  // 카카오맵 관련
  KakaoMapController? mapController;
  
  // 위치 정보
  double initialLatitude = 37.5665; // 서울시청
  double initialLongitude = 126.9780;
  
  // 선택된 위치 정보
  final Rx<MapLocation?> selectedLocation = Rx<MapLocation?>(null);
  final RxString selectedAddress = ''.obs;
  final RxBool hasSelectedLocation = false.obs;
  final RxBool isAddressLoading = false.obs;
  
  // 검색 관련
  final RxBool isSearching = false.obs;
  Timer? _searchDebounceTimer;
  
  // UI 상태
  final RxString title = '위치 선택'.obs;
  final RxBool canConfirm = false.obs;
  
  // 마커 관련
  final RxList<Marker> markers = <Marker>[].obs;
  
  
  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _getCurrentLocation();
  }
  
  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
  
  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      title.value = arguments['title'] ?? '위치 선택';
    }
  }
  
  void onMapCreated(KakaoMapController controller) {
    mapController = controller;
    print('🗺️ 카카오맵 초기화 완료');
    print('🔍 지도 컨트롤러 상태: 정상');
  }
  
  
  void onMapTap(LatLng position) async {
    try {
      isAddressLoading.value = true;
      
      // 지도 컨트롤러를 통해 직접 마커 조작
      if (mapController != null) {
        // 기존 마커 모두 제거
        await mapController!.clearMarker();
        
        // 고유한 마커 ID 생성 (시간 기반)
        final markerId = 'selected_location_${DateTime.now().millisecondsSinceEpoch}';
        
        // 새 마커 추가
        final marker = Marker(
          markerId: markerId,
          latLng: position,
          width: 30,
          height: 35,
          offsetX: 15,
          offsetY: 35,
        );
        
        await mapController!.addMarker(markers: [marker]);
        
        print('🗺️ 마커 업데이트 완료: $markerId');
        
        // 로컬 리스트도 업데이트
        markers.clear();
        markers.add(marker);
      }
      
      // 좌표를 주소로 변환
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      String address = '';
      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        address = '${placemark.administrativeArea ?? ''} ${placemark.locality ?? ''} ${placemark.thoroughfare ?? ''} ${placemark.subThoroughfare ?? ''}'
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      }
      
      final location = MapLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        placeName: null,
      );
      
      selectedLocation.value = location;
      selectedAddress.value = address;
      hasSelectedLocation.value = true;
      canConfirm.value = true;
      
      print('✅ 위치 선택 완료: $address');
      
    } catch (e) {
      print('❌ 위치 선택 오류: $e');
    } finally {
      isAddressLoading.value = false;
    }
  }
  
  
  
  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      final position = await Geolocator.getCurrentPosition();
      initialLatitude = position.latitude;
      initialLongitude = position.longitude;
      
      // 지도 중심을 현재 위치로 이동
      mapController?.setCenter(LatLng(initialLatitude, initialLongitude));
      
    } catch (e) {
      print('현재 위치 가져오기 실패: $e');
    }
  }
  
  void onSearchChanged(String query) {
    _searchDebounceTimer?.cancel();
    
    if (query.isEmpty) {
      return;
    }
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchAddress(query);
    });
  }
  
  Future<void> searchAddress(String query) async {
    if (query.isEmpty) return;
    
    try {
      isSearching.value = true;
      
      // 카카오 주소 검색 API 사용
      final results = await KakaoAddressService.searchAddress(query);
      
      if (results.isNotEmpty) {
        final firstResult = results[0];
        final position = LatLng(firstResult.latitude ?? 0.0, firstResult.longitude ?? 0.0);
        
        // 검색 결과 위치로 이동
        mapController?.setCenter(position);
        
        
        // 선택된 위치 정보 업데이트
        final location = MapLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: firstResult.fullAddress,
          placeName: firstResult.placeName,
        );
        
        selectedLocation.value = location;
        selectedAddress.value = firstResult.fullAddress;
        hasSelectedLocation.value = true;
        canConfirm.value = true;
      }
      
    } catch (e) {
      print('주소 검색 오류: $e');
      Get.snackbar(
        '검색 오류',
        '주소 검색 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSearching.value = false;
    }
  }
  
  void clearSearch() {
    searchController.clear();
  }
  
  void confirmSelection() {
    if (selectedLocation.value != null) {
      final location = selectedLocation.value!;
      final result = {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'address': location.address,
        'placeName': location.placeName ?? (searchController.text.isNotEmpty ? searchController.text : null),
      };
      
      Get.back(result: result);
    }
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