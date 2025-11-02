import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

/// 현재 위치 조회 UseCase
class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase({
    required LocationRepository repository,
  }) : _repository = repository;

  Future<UserLocationEntity?> call() {
    return _repository.getCurrentLocation();
  }
}