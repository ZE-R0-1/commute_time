import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/api/services/api_provider.dart';
import '../models/bus_arrival_info_response.dart';

/// 버스 도착정보 원격 데이터 소스 인터페이스
abstract class BusArrivalRemoteDataSource {
  /// 정류소별 버스 도착정보 조회
  Future<List<BusArrivalInfoResponse>> getBusArrivalInfo(String stationId);

  /// 특정 노선의 정류소별 버스 도착정보 조회 (routeId, staOrder 사용)
  Future<BusArrivalInfoResponse?> getBusArrivalItemv2(String stationId, String routeId, int staOrder);
}

/// 버스 도착정보 원격 데이터 소스 구현
class BusArrivalRemoteDataSourceImpl implements BusArrivalRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  BusArrivalRemoteDataSourceImpl();

  @override
  Future<List<BusArrivalInfoResponse>> getBusArrivalInfo(String stationId) async {
    try {
      print('🚌 버스 도착정보 API 요청: $stationId');

      final responseData = await apiProvider.busClient.getGyeonggiBusArrival(
        stationId: stationId,
      );

      return _parseArrivalResponse(responseData);
    } catch (e, stackTrace) {
      print('❌ 버스 도착정보 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  @override
  Future<BusArrivalInfoResponse?> getBusArrivalItemv2(String stationId, String routeId, int staOrder) async {
    try {
      print('🚌 버스 도착정보 API v2 요청: $stationId');

      final responseData = await apiProvider.busClient.getGyeonggiBusArrivalDetail(
        stationId: stationId,
        routeId: routeId,
        staOrder: staOrder,
      );

      return _parseArrivalItemResponse(responseData);
    } catch (e, stackTrace) {
      print('❌ 버스 도착정보 v2 검색 중 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return null;
    }
  }

  /// JSON 응답 파싱
  List<BusArrivalInfoResponse> _parseArrivalResponse(dynamic jsonData) {
    try {
      print('📊 원본 응답 데이터: $jsonData');

      final response = jsonData['response'];
      if (response == null) {
        print('⚠️ response가 null입니다.');
        return [];
      }

      final msgBody = response['msgBody'];
      if (msgBody == null) {
        print('⚠️ msgBody가 null입니다.');
        return [];
      }

      final busArrivalData = msgBody['busArrivalList'];

      List<BusArrivalInfoResponse> arrivalInfos = [];

      // busArrivalList는 단일 객체 또는 배열일 수 있음
      if (busArrivalData != null) {
        List<dynamic> busArrivalList = [];

        if (busArrivalData is List) {
          // 배열인 경우
          busArrivalList = busArrivalData;
        } else if (busArrivalData is Map<String, dynamic>) {
          // 단일 객체인 경우
          busArrivalList = [busArrivalData];
        }

        print('📄 버스도착정보 원본 데이터: $busArrivalData');
        print('✅ 경기도 버스 도착정보 파싱 시작! 총 ${busArrivalList.length}개 항목');

        for (int i = 0; i < busArrivalList.length; i++) {
          final item = busArrivalList[i];
          try {
            final routeTypeCd = item['routeTypeCd']?.toString() ?? '';
            final arrivalInfo = BusArrivalInfoResponse.fromJson(item, routeTypeCd);

            arrivalInfos.add(arrivalInfo);

            print('경기도 버스 도착정보 ${i + 1}. ${arrivalInfo.routeName}번 (${arrivalInfo.routeTypeName})');
            print('   - 첫번째 버스: ${arrivalInfo.predictTime1}분 후, ${arrivalInfo.locationNo1}정류장 전');
            print('   - 두번째 버스: ${arrivalInfo.predictTime2}분 후, ${arrivalInfo.locationNo2}정류장 전');
            print('   - 저상버스: 1번(${arrivalInfo.lowPlate1}), 2번(${arrivalInfo.lowPlate2})');
            print('');
          } catch (e) {
            print('❌ 버스 도착정보 파싱 오류 ($i번째): $e');
            print('   - 원본 데이터: $item');
            continue;
          }
        }
      }

      print('✅ 버스 도착정보 파싱 완료! 총 ${arrivalInfos.length}개');
      return arrivalInfos;
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// JSON 응답 파싱 (v2 API용 - 단일 busArrivalItem)
  BusArrivalInfoResponse? _parseArrivalItemResponse(dynamic jsonData) {
    try {
      print('📊 v2 원본 응답 데이터: $jsonData');

      final response = jsonData['response'];
      if (response == null) {
        print('⚠️ v2 response가 null입니다.');
        return null;
      }

      final msgBody = response['msgBody'];
      if (msgBody == null) {
        print('⚠️ v2 msgBody가 null입니다.');
        return null;
      }

      final busArrivalItem = msgBody['busArrivalItem'];

      print('📄 버스도착정보v2 원본 데이터: $busArrivalItem');

      if (busArrivalItem != null) {
        final routeTypeCd = busArrivalItem['routeTypeCd']?.toString() ?? '';
        final arrivalInfo = BusArrivalInfoResponse.fromJson(busArrivalItem, routeTypeCd);

        print('✅ 경기도 버스 도착정보 v2 파싱 완료: ${arrivalInfo.routeName}번 (${arrivalInfo.routeTypeName})');
        print('   - 첫번째 버스: ${arrivalInfo.predictTime1}분 후, ${arrivalInfo.locationNo1}정류장 전');
        print('   - 두번째 버스: ${arrivalInfo.predictTime2}분 후, ${arrivalInfo.locationNo2}정류장 전');

        return arrivalInfo;
      }

      print('⚠️ busArrivalItem이 null입니다.');
      return null;
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류 (v2): $e');
      print('📍 스택 트레이스: $stackTrace');
      return null;
    }
  }
}