import '../entities/seoul_bus_arrival_entity.dart';
import '../repositories/seoul_bus_arrival_repository.dart';

/// 서울 버스 도착정보 조회 UseCase
class GetSeoulBusArrivalUseCase {
  final SeoulBusArrivalRepository repository;

  GetSeoulBusArrivalUseCase({required this.repository});

  Future<List<SeoulBusArrivalEntity>> call(String cityCode, String nodeId) {
    return repository.getBusArrivalInfoWithCityCode(cityCode, nodeId);
  }
}