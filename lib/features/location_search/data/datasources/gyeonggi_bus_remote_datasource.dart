import 'dart:convert';
import 'package:get/get.dart';

import '../../../../core/api/services/api_provider.dart';

/// 경기도 버스 원격 데이터소스
abstract class GyeonggiBusRemoteDataSource {
  /// 좌표 기반 주변 정류소 조회
  Future<List<GyeonggiBusStopResponse>> getBusStopsByLocation(
    double latitude,
    double longitude, {
    int radius,
  });
}

class GyeonggiBusRemoteDataSourceImpl implements GyeonggiBusRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  GyeonggiBusRemoteDataSourceImpl();

  @override
  Future<List<GyeonggiBusStopResponse>> getBusStopsByLocation(
    double latitude,
    double longitude, {
    int radius = 500,
  }) async {
    try {
      print('🚌 경기도 버스정류장 API 요청 시작');

      final responseData = await apiProvider.busClient.searchGyeonggiBusStops(
        x: longitude,
        y: latitude,
      );

      return _parseJsonResponse(responseData);
    } catch (e, stackTrace) {
      print('❌ 경기도 버스정류장 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// JSON 응답 파싱
  static List<GyeonggiBusStopResponse> _parseJsonResponse(dynamic jsonData) {
    try {
      final data = jsonData is String ? jsonDecode(jsonData) : jsonData;
      final response = data['response'];
      final msgBody = response['msgBody'];
      final busStationList = msgBody['busStationAroundList'];

      List<GyeonggiBusStopResponse> busStops = [];

      if (busStationList != null && busStationList is List) {
        for (final item in busStationList) {
          try {
            final busStop = GyeonggiBusStopResponse(
              stationId: item['stationId']?.toString() ?? '',
              stationName: item['stationName']?.toString() ?? '',
              x: double.tryParse(item['x']?.toString() ?? '0') ?? 0.0,
              y: double.tryParse(item['y']?.toString() ?? '0') ?? 0.0,
              regionName: item['regionName']?.toString() ?? '',
              districtCd: item['districtCd']?.toString() ?? '',
              centerYn: item['centerYn']?.toString() ?? 'N',
              mgmtId: item['mgmtId']?.toString() ?? '',
              mobileNo: item['mobileNo']?.toString() ?? '',
            );

            if (busStop.x != 0.0 && busStop.y != 0.0) {
              busStops.add(busStop);
            }
          } catch (e) {
            print('❌ 버스정류장 파싱 오류: $e');
            continue;
          }
        }
      }

      print('✅ 경기도 버스정류장 파싱 완료! 총 ${busStops.length}개');
      return busStops;
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}

/// 경기도 버스정류장 응답 모델
class GyeonggiBusStopResponse {
  final String stationId;
  final String stationName;
  final double x;
  final double y;
  final String regionName;
  final String districtCd;
  final String centerYn;
  final String mgmtId;
  final String mobileNo;

  GyeonggiBusStopResponse({
    required this.stationId,
    required this.stationName,
    required this.x,
    required this.y,
    required this.regionName,
    required this.districtCd,
    required this.centerYn,
    required this.mgmtId,
    required this.mobileNo,
  });
}