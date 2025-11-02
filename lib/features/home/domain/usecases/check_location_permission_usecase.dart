import '../entities/location_permission_entity.dart';
import '../repositories/location_repository.dart';

/// 위치 권한 확인 UseCase
class CheckLocationPermissionUseCase {
  final LocationRepository _repository;

  CheckLocationPermissionUseCase({
    required LocationRepository repository,
  }) : _repository = repository;

  Future<LocationPermissionEntity> call() {
    return _repository.checkLocationPermission();
  }
}