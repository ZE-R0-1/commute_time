import 'dart:convert';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../../../../core/api/services/api_provider.dart';
import '../models/subway_station_response.dart';
import '../models/subway_arrival_response.dart';

/// 지하철 원격 데이터소스 (API 호출)
abstract class SubwayRemoteDataSource {
  /// 근처 지하철역 검색
  Future<List<SubwayStationResponse>> searchNearbyStations(LatLng center);

  /// 지하철 도착정보 조회
  Future<List<SubwayArrivalResponse>> getArrivalInfo(String stationName);
}

class SubwayRemoteDataSourceImpl implements SubwayRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  SubwayRemoteDataSourceImpl();

  @override
  Future<List<SubwayStationResponse>> searchNearbyStations(LatLng center) async {
    try {
      print('🚇 지하철역 검색 시작: (${center.latitude}, ${center.longitude})');

      final responseData = await apiProvider.kakaoClient.searchSubwayStations(
        x: center.longitude,
        y: center.latitude,
      );

      print('📋 지하철역 API 전체 응답: $responseData');
      final documents = responseData['documents'] as List?;

      if (documents == null || documents.isEmpty) {
        print('📭 검색 결과가 없습니다');
        print('📋 응답 키들: ${responseData.keys.toList()}');
        return [];
      }

      print('✅ 지하철역 검색 완료: ${documents.length}개');

      final stations = <SubwayStationResponse>[];
      for (int i = 0; i < documents.length; i++) {
        try {
          final station = documents[i];
          print('📍 지하철역 $i: $station');

          // station이 Map<String, dynamic>인지 확인
          final stationMap = station as Map<String, dynamic>;
          final response = SubwayStationResponse.fromJson(stationMap);
          stations.add(response);
        } catch (e) {
          print('❌ 지하철역 $i 파싱 오류: $e');
        }
      }

      return stations;
    } catch (e) {
      print('❌ 지하철역 검색 오류: $e');
      return [];
    }
  }

  @override
  Future<List<SubwayArrivalResponse>> getArrivalInfo(String stationName) async {
    try {
      print('🚄 지하철 도착정보 조회: $stationName');

      final responseData = await apiProvider.subwayClient.getStationArrival(
        stationName: stationName,
      );

      // 에러 체크
      if (responseData['errorMessage'] != null) {
        final resultCode = responseData['errorMessage']['code'];
        final resultMessage = responseData['errorMessage']['message'];

        if (resultCode != 'INFO-000') {
          print('❌ API 오류: $resultMessage');
          return [];
        }
      }

      // 데이터 파싱
      final rows = responseData['realtimeArrivalList'] as List? ?? [];

      print('✅ 도착정보 조회 완료: ${rows.length}개');

      return rows
          .map((row) => SubwayArrivalResponse.fromJson(row))
          .toList();
    } catch (e) {
      print('❌ 지하철 도착정보 조회 오류: $e');
      return [];
    }
  }
}