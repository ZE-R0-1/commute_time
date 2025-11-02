import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

/// 마지막 알려진 위치 조회 UseCase
class GetLastKnownLocationUseCase {
  final LocationRepository _repository;

  GetLastKnownLocationUseCase({
    required LocationRepository repository,
  }) : _repository = repository;

  Future<UserLocationEntity?> call() {
    return _repository.getLastKnownLocation();
  }
}