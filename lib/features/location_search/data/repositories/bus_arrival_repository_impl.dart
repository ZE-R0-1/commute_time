import '../../domain/entities/bus_arrival_info_entity.dart';
import '../../domain/repositories/bus_arrival_repository.dart';
import '../datasources/bus_arrival_remote_datasource.dart';

class BusArrivalRepositoryImpl implements BusArrivalRepository {
  final BusArrivalRemoteDataSource remoteDataSource;

  BusArrivalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BusArrivalInfoEntity>> getBusArrivalInfo(String stationId) async {
    try {
      final responses = await remoteDataSource.getBusArrivalInfo(stationId);
      return responses.map((response) => response.toEntity()).toList();
    } catch (e) {
      print('❌ 버스 도착정보 조회 오류: $e');
      return [];
    }
  }

  @override
  Future<BusArrivalInfoEntity?> getBusArrivalItemv2(String stationId, String routeId, int staOrder) async {
    try {
      final response = await remoteDataSource.getBusArrivalItemv2(stationId, routeId, staOrder);
      return response?.toEntity();
    } catch (e) {
      print('❌ 버스 도착정보 v2 조회 오류: $e');
      return null;
    }
  }
}