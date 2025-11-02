import '../entities/user_location_entity.dart';
import '../repositories/location_repository.dart';

/// 홈 위치 근처 여부 판단 UseCase
class IsNearHomeUseCase {
  final LocationRepository _repository;

  IsNearHomeUseCase({
    required LocationRepository repository,
  }) : _repository = repository;

  bool call(UserLocationEntity currentLocation, double homeLat, double homeLon) {
    return _repository.isNearHome(currentLocation, homeLat, homeLon);
  }
}