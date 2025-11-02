import 'dart:convert';
import 'package:get/get.dart';

import '../../../../core/api/services/api_provider.dart';

/// 서울 버스 원격 데이터소스
abstract class SeoulBusRemoteDataSource {
  /// 좌표 기반 주변 정류소 조회
  Future<List<SeoulBusStopResponse>> getBusStopsByLocation(
    double latitude,
    double longitude, {
    int numOfRows,
  });
}

class SeoulBusRemoteDataSourceImpl implements SeoulBusRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  SeoulBusRemoteDataSourceImpl();

  @override
  Future<List<SeoulBusStopResponse>> getBusStopsByLocation(
    double latitude,
    double longitude, {
    int numOfRows = 10,
  }) async {
    try {
      print('🏢 서울 버스정류장 API 검색 시작');
      print('📍 검색 좌표: ($latitude, $longitude)');

      final responseData = await apiProvider.busClient.searchSeoulBusStops(
        latitude: latitude,
        longitude: longitude,
        numOfRows: numOfRows,
      );

      return _parseJsonResponse(responseData);
    } catch (e, stackTrace) {
      print('❌ 서울 버스정류장 검색 중 오류 발생: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// JSON 응답 파싱
  static List<SeoulBusStopResponse> _parseJsonResponse(dynamic jsonData) {
    try {
      final data = jsonData is String ? jsonDecode(jsonData) : jsonData;

      if (data['response'] != null &&
          data['response']['body'] != null &&
          data['response']['body']['items'] != null) {
        final items = data['response']['body']['items'];

        List<dynamic> itemList = [];
        if (items is List) {
          itemList = items;
        } else if (items is Map && items['item'] != null) {
          if (items['item'] is List) {
            itemList = items['item'];
          } else {
            itemList = [items['item']];
          }
        }

        print('✅ 서울 API 파싱 완료! 총 ${itemList.length}개의 버스정류장 발견');

        List<SeoulBusStopResponse> busStops = [];
        for (int i = 0; i < itemList.length; i++) {
          final item = itemList[i];
          if (item is Map<String, dynamic>) {
            try {
              final nodeId = item['nodeid']?.toString() ?? '';
              final cityCode = item['citycode']?.toString() ?? '';
              print('📌 서울 정류소 $i: nodeid=$nodeId, nodenm=${item['nodenm']}, citycode=$cityCode');

              final busStop = SeoulBusStopResponse(
                stationId: nodeId,
                stationNm: item['nodenm']?.toString() ?? '',
                gpsX: double.tryParse(item['gpslong']?.toString() ?? '0') ?? 0.0,
                gpsY: double.tryParse(item['gpslati']?.toString() ?? '0') ?? 0.0,
                direction: item['direction']?.toString() ?? '',
                stationTp: item['stationTp']?.toString() ?? '0',
                cityCode: cityCode,
              );
              busStops.add(busStop);
            } catch (e) {
              print('❌ 서울 버스정류장 파싱 오류: $e');
            }
          }
        }

        return busStops;
      } else {
        print('❌ 서울 API 응답 구조 오류');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}

/// 서울 버스정류장 응답 모델
class SeoulBusStopResponse {
  final String stationId;
  final String stationNm;
  final double gpsX;
  final double gpsY;
  final String direction;
  final String stationTp;
  final String cityCode;

  SeoulBusStopResponse({
    required this.stationId,
    required this.stationNm,
    required this.gpsX,
    required this.gpsY,
    required this.direction,
    required this.stationTp,
    required this.cityCode,
  });
}