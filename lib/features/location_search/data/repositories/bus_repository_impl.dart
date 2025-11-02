import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../domain/entities/bus_search_result_entity.dart';
import '../../domain/entities/gyeonggi_bus_stop_entity.dart';
import '../../domain/entities/seoul_bus_stop_entity.dart';
import '../../domain/repositories/bus_repository.dart';
import '../datasources/gyeonggi_bus_remote_datasource.dart';
import '../datasources/seoul_bus_remote_datasource.dart';

class BusRepositoryImpl implements BusRepository {
  final GyeonggiBusRemoteDataSource gyeonggiBusRemoteDataSource;
  final SeoulBusRemoteDataSource seoulBusRemoteDataSource;

  BusRepositoryImpl({
    required this.gyeonggiBusRemoteDataSource,
    required this.seoulBusRemoteDataSource,
  });

  @override
  Future<BusSearchResultEntity> searchNearbyBusStops(LatLng center) async {
    try {
      print('🚌 버스정류장 통합 검색 시작: (${center.latitude}, ${center.longitude})');

      final results = await Future.wait([
        gyeonggiBusRemoteDataSource.getBusStopsByLocation(
          center.latitude,
          center.longitude,
          radius: 500,
        ),
        seoulBusRemoteDataSource.getBusStopsByLocation(
          center.latitude,
          center.longitude,
          numOfRows: 10,
        ),
      ]);

      final gyeonggiBusStopResponses =
          results[0] as List<GyeonggiBusStopResponse>;
      final seoulBusStopResponses =
          results[1] as List<SeoulBusStopResponse>;

      final gyeonggiBusStops = gyeonggiBusStopResponses
          .map((response) => GyeonggiBusStopEntity(
                stationId: response.stationId,
                stationName: response.stationName,
                x: response.x,
                y: response.y,
                regionName: response.regionName,
                districtCd: response.districtCd,
                centerYn: response.centerYn,
                mgmtId: response.mgmtId,
                mobileNo: response.mobileNo,
              ))
          .toList();

      final seoulBusStops = seoulBusStopResponses
          .map((response) => SeoulBusStopEntity(
                stationId: response.stationId,
                stationNm: response.stationNm,
                gpsX: response.gpsX,
                gpsY: response.gpsY,
                direction: response.direction,
                stationTp: response.stationTp,
                cityCode: response.cityCode,
              ))
          .toList();

      print(
          '✅ 버스정류장 검색 완료: 경기 ${gyeonggiBusStops.length}개, 서울 ${seoulBusStops.length}개');

      return BusSearchResultEntity(
        gyeonggiBusStops: gyeonggiBusStops,
        seoulBusStops: seoulBusStops,
      );
    } catch (e) {
      print('❌ 버스정류장 검색 오류: $e');
      return BusSearchResultEntity(
        gyeonggiBusStops: [],
        seoulBusStops: [],
      );
    }
  }
}