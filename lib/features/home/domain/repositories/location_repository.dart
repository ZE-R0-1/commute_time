import '../entities/user_location_entity.dart';
import '../entities/location_permission_entity.dart';

/// 위치 관련 Repository 인터페이스
abstract class LocationRepository {
  /// 위치 권한 확인
  Future<LocationPermissionEntity> checkLocationPermission();

  /// 현재 위치 조회
  Future<UserLocationEntity?> getCurrentLocation();

  /// 마지막 알려진 위치 조회
  Future<UserLocationEntity?> getLastKnownLocation();

  /// 두 지점 사이의 거리 계산 (미터)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2);

  /// 사용자 위치 vs 설정된 집 위치 비교 (500m 이내면 집 근처)
  bool isNearHome(UserLocationEntity currentLocation, double homeLat, double homeLon);
}