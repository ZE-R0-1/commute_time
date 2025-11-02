import '../repositories/location_repository.dart';

/// 두 지점 사이의 거리 계산 UseCase
class CalculateLocationDistanceUseCase {
  final LocationRepository _repository;

  CalculateLocationDistanceUseCase({
    required LocationRepository repository,
  }) : _repository = repository;

  double call(double lat1, double lon1, double lat2, double lon2) {
    return _repository.calculateDistance(lat1, lon1, lat2, lon2);
  }
}