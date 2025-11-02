import '../../domain/entities/user_location_entity.dart';
import '../../domain/entities/location_permission_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';

/// 위치 Repository 구현체
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remoteDataSource;

  LocationRepositoryImpl({
    required LocationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LocationPermissionEntity> checkLocationPermission() async {
    final result = await _remoteDataSource.checkLocationPermission();
    return result.toEntity();
  }

  @override
  Future<UserLocationEntity?> getCurrentLocation() async {
    final result = await _remoteDataSource.getCurrentLocation();
    return result?.toEntity();
  }

  @override
  Future<UserLocationEntity?> getLastKnownLocation() async {
    final result = await _remoteDataSource.getLastKnownLocation();
    return result?.toEntity();
  }

  @override
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return _remoteDataSource.calculateDistance(lat1, lon1, lat2, lon2);
  }

  @override
  bool isNearHome(UserLocationEntity currentLocation, double homeLat, double homeLon) {
    final distance = calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      homeLat,
      homeLon,
    );
    // 500m 이내면 집 근처
    return distance <= 500;
  }
}