import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/entities/location_permission_entity.dart';
import '../models/user_location_model.dart';
import '../models/location_permission_model.dart';

/// 위치 원격 데이터 소스 인터페이스
abstract class LocationRemoteDataSource {
  Future<LocationPermissionModel> checkLocationPermission();
  Future<UserLocationModel?> getCurrentLocation();
  Future<UserLocationModel?> getLastKnownLocation();
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);
}

/// 위치 원격 데이터 소스 구현
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<LocationPermissionModel> checkLocationPermission() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionModel(
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
          return LocationPermissionModel(
            success: false,
            message: '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.',
            errorType: LocationErrorType.permissionDenied,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionModel(
          success: false,
          message: '위치 권한이 영구적으로 거부되었습니다.\n설정에서 직접 권한을 허용해주세요.',
          errorType: LocationErrorType.permissionDeniedForever,
        );
      }

      return LocationPermissionModel(
        success: true,
        message: '위치 권한이 허용되었습니다.',
        errorType: null,
      );
    } catch (e) {
      print('위치 권한 확인 오류: $e');
      return LocationPermissionModel(
        success: false,
        message: '위치 권한 확인 중 오류가 발생했습니다.',
        errorType: LocationErrorType.unknown,
      );
    }
  }

  @override
  Future<UserLocationModel?> getCurrentLocation() async {
    try {
      print('현재 위치 조회 시작...');

      // 권한 확인
      final permissionResult = await checkLocationPermission();
      if (!permissionResult.success) {
        print('위치 권한 없음: ${permissionResult.message}');
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
          localeIdentifier: 'ko_KR',
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          final admin = place.administrativeArea ?? '';
          final locality = place.locality ?? '';
          final subLocality = place.subLocality ?? '';
          final thoroughfare = place.thoroughfare ?? '';

          List<String> addressParts = [];
          if (admin.isNotEmpty) {
            addressParts.add(admin);
          }
          if (locality.isNotEmpty && locality != admin && !locality.contains('특별시') && !locality.contains('광역시')) {
            addressParts.add(locality);
          }
          if (subLocality.isNotEmpty) {
            addressParts.add(subLocality);
          } else if (thoroughfare.isNotEmpty) {
            addressParts.add(thoroughfare);
          }

          address = addressParts.join(' ');
          print('주소 변환 성공: $address');
        }
      } catch (e) {
        print('주소 변환 실패: $e');
        address = '위치 확인됨';
      }

      return UserLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address ?? '현재 위치',
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );
    } catch (e) {
      print('현재 위치 조회 오류: $e');

      if (e.toString().contains('TimeoutException')) {
        print('GPS 타임아웃 발생, 마지막 위치 사용 시도...');
        final lastLocation = await getLastKnownLocation();
        if (lastLocation != null) {
          print('마지막 위치로 대체 성공');
          return lastLocation;
        }
      }

      return null;
    }
  }

  @override
  Future<UserLocationModel?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        print('마지막 위치 사용: ${position.latitude}, ${position.longitude}');
        return UserLocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          address: '현재 위치',
          accuracy: position.accuracy,
          timestamp: position.timestamp,
        );
      }
    } catch (e) {
      print('마지막 위치 조회 오류: $e');
    }

    return null;
  }

  @override
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}