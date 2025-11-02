import '../../domain/entities/seoul_bus_arrival_entity.dart';
import '../../domain/repositories/seoul_bus_arrival_repository.dart';
import '../datasources/seoul_bus_arrival_remote_datasource.dart';

class SeoulBusArrivalRepositoryImpl implements SeoulBusArrivalRepository {
  final SeoulBusArrivalRemoteDataSource remoteDataSource;

  SeoulBusArrivalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SeoulBusArrivalEntity>> getBusArrivalInfo(String stationId) async {
    try {
      final responses = await remoteDataSource.getBusArrivalInfo(stationId);
      return responses.map((response) => response.toEntity()).toList();
    } catch (e) {
      print('❌ 서울 버스 도착정보 조회 오류: $e');
      return [];
    }
  }

  /// 도시코드와 정류소ID로 버스 도착정보 조회
  Future<List<SeoulBusArrivalEntity>> getBusArrivalInfoWithCityCode(
    String cityCode,
    String nodeId,
  ) async {
    try {
      final responses = await remoteDataSource.getBusArrivalInfoWithCityCode(
        cityCode,
        nodeId,
      );
      return responses.map((response) => response.toEntity()).toList();
    } catch (e) {
      print('❌ 서울 버스 도착정보 조회 오류: $e');
      return [];
    }
  }
}