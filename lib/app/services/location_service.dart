// lib/app/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LocationService {

  // 현재 위치 권한 확인 및 요청
  static Future<LocationPermissionResult> checkLocationPermission() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult(
          success: false,
          message: '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 켜주세요.',
          errorType: LocationErrorType.serviceDisabled,
        );
      }

      // 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // 권한 요청
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult(
            success: false,
            message: '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.',
            errorType: LocationErrorType.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult(
          success: false,
          message: '위치 권한이 영구적으로 거부되었습니다.\n설정에서 직접 권한을 허용해주세요.',
          errorType: LocationErrorType.permissionDeniedForever,
        );
      }

      return LocationPermissionResult(
        success: true,
        message: '위치 권한이 허용되었습니다.',
        errorType: null,
      );

    } catch (e) {
      print('위치 권한 확인 오류: $e');
      return LocationPermissionResult(
        success: false,
        message: '위치 권한 확인 중 오류가 발생했습니다.',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  // 현재 위치 좌표 가져오기
  static Future<UserLocation?> getCurrentLocation() async {
    try {
      print('현재 위치 조회 시작...');

      // 권한 확인
      final permissionResult = await checkLocationPermission();
      if (!permissionResult.success) {
        print('위치 권한 없음: ${permissionResult.message}');

        // 사용자에게 알림
        _showLocationPermissionDialog(permissionResult);
        return null;
      }

      // 현재 위치 조회 (정확도 높음, 타임아웃 10초)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('GPS 위치 조회 성공: ${position.latitude}, ${position.longitude}');

      // 주소 변환 (선택사항)
      String? address;
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
          localeIdentifier: 'ko_KR', // 한국어
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          
          // 주소 구성 요소 확인
          final admin = place.administrativeArea ?? ''; // 서울특별시
          final locality = place.locality ?? '';        // 마포구, 서울특별시 등
          final subLocality = place.subLocality ?? '';  // 상암동
          final thoroughfare = place.thoroughfare ?? ''; // 도로명
          
          print('주소 구성 요소: admin=$admin, locality=$locality, subLocality=$subLocality, thoroughfare=$thoroughfare');
          
          // 중복 제거하고 의미있는 부분만 조합
          List<String> addressParts = [];
          
          // 1. 시/도 (서울특별시, 경기도 등)
          if (admin.isNotEmpty) {
            addressParts.add(admin);
          }
          
          // 2. 구/군 (locality가 admin과 다르고 의미있는 경우만)
          if (locality.isNotEmpty && locality != admin && !locality.contains('특별시') && !locality.contains('광역시')) {
            addressParts.add(locality);
          }
          
          // 3. 동/읍/면 (subLocality가 있으면 우선, 없으면 thoroughfare)
          if (subLocality.isNotEmpty) {
            addressParts.add(subLocality);
          } else if (thoroughfare.isNotEmpty) {
            addressParts.add(thoroughfare);
          }
          
          address = addressParts.join(' ');
          print('주소 변환 성공: $address');
        }
      } catch (e) {
        print('1주소 변환 실패: $e');
        address = '위치 확인됨';
      }

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address ?? '현재 위치',
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );

    } catch (e) {
      print('현재 위치 조회 오류: $e');

      // 타임아웃 또는 일반 오류 시 마지막 위치 시도
      if (e.toString().contains('TimeoutException')) {
        print('GPS 타임아웃 발생, 마지막 위치 사용 시도...');
        final lastLocation = await getLastKnownLocation();
        if (lastLocation != null) {
          print('마지막 위치로 대체 성공');
          return lastLocation;
        }
      }

      if (e is LocationServiceDisabledException) {
        _showLocationServiceDialog();
      } else if (e is PermissionDeniedException) {
        _showLocationPermissionDialog(LocationPermissionResult(
          success: false,
          message: '위치 권한이 필요합니다.',
          errorType: LocationErrorType.permissionDenied,
        ));
      } else {
        // 타임아웃이나 기타 오류 시 다이얼로그 표시하지 않음
        print('위치 조회 실패, 저장된 위치 사용');
      }

      return null;
    }
  }

  // 마지막으로 알려진 위치 가져오기 (빠른 조회)
  static Future<UserLocation?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        print('마지막 위치 사용: ${position.latitude}, ${position.longitude}');
        return UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: '현재 위치',
          accuracy: position.accuracy,
          timestamp: position.timestamp ?? DateTime.now(),
        );
      }
    } catch (e) {
      print('마지막 위치 조회 오류: $e');
    }

    return null;
  }

  // 두 지점 사이의 거리 계산 (미터)
  static double calculateDistance(
      double lat1, double lon1,
      double lat2, double lon2
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // 사용자 위치 vs 설정된 집 위치 비교
  static bool isNearHome(UserLocation currentLocation, double homeLat, double homeLon) {
    final distance = calculateDistance(
        currentLocation.latitude, currentLocation.longitude,
        homeLat, homeLon
    );

    // 500m 이내면 집 근처로 판단
    return distance <= 500;
  }

  // 권한 다이얼로그 표시
  static void _showLocationPermissionDialog(LocationPermissionResult result) {
    Get.dialog(
      AlertDialog(
        title: const Text('위치 권한 필요'),
        content: Text(result.message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              if (result.errorType == LocationErrorType.permissionDeniedForever) {
                Geolocator.openAppSettings();
              } else {
                // 권한 재요청
                getCurrentLocation();
              }
            },
            child: const Text('설정하기'),
          ),
        ],
      ),
    );
  }

  // 위치 서비스 다이얼로그
  static void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('위치 서비스 필요'),
        content: const Text('위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 켜주세요.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('나중에'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
  }

  // 일반 오류 다이얼로그
  static void _showLocationErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('위치 조회 실패'),
        content: const Text('현재 위치를 조회할 수 없습니다.\n잠시 후 다시 시도해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 사용자 위치 모델
class UserLocation {
  final double latitude;
  final double longitude;
  final String address;
  final double accuracy; // GPS 정확도 (미터)
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.accuracy,
    required this.timestamp,
  });

  // 위치 정확도 상태
  LocationAccuracyStatus get accuracyStatus {
    if (accuracy <= 10) return LocationAccuracyStatus.excellent;
    if (accuracy <= 50) return LocationAccuracyStatus.good;
    if (accuracy <= 100) return LocationAccuracyStatus.fair;
    return LocationAccuracyStatus.poor;
  }

  // 위치 정확도 텍스트
  String get accuracyText {
    switch (accuracyStatus) {
      case LocationAccuracyStatus.excellent:
        return '매우 정확 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.good:
        return '정확 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.fair:
        return '보통 (±${accuracy.round()}m)';
      case LocationAccuracyStatus.poor:
        return '부정확 (±${accuracy.round()}m)';
    }
  }

  @override
  String toString() {
    return 'UserLocation(lat: $latitude, lon: $longitude, addr: $address)';
  }
}

// 위치 권한 결과
class LocationPermissionResult {
  final bool success;
  final String message;
  final LocationErrorType? errorType;

  LocationPermissionResult({
    required this.success,
    required this.message,
    this.errorType,
  });
}

// 오류 타입
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

// 위치 정확도 상태
enum LocationAccuracyStatus {
  excellent, // 10m 이하
  good,      // 50m 이하
  fair,      // 100m 이하
  poor,      // 100m 초과
}