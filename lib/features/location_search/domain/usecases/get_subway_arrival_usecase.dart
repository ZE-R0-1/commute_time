import '../entities/subway_arrival_entity.dart';
import '../repositories/subway_repository.dart';

/// 지하철 도착정보 조회 Usecase
class GetSubwayArrivalUseCase {
  final SubwayRepository repository;

  GetSubwayArrivalUseCase({required this.repository});

  Future<List<SubwayArrivalEntity>> call(String stationName) async {
    return await repository.getArrivalInfo(stationName);
  }
}