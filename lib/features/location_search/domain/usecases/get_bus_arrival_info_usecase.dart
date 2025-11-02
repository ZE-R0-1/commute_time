import '../entities/bus_arrival_info_entity.dart';
import '../repositories/bus_arrival_repository.dart';

/// 버스 도착정보 조회 UseCase
class GetBusArrivalInfoUseCase {
  final BusArrivalRepository repository;

  GetBusArrivalInfoUseCase({required this.repository});

  Future<List<BusArrivalInfoEntity>> call(String stationId) {
    return repository.getBusArrivalInfo(stationId);
  }
}