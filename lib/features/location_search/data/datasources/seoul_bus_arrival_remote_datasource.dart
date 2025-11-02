import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/api/services/api_provider.dart';
import '../models/seoul_bus_arrival_response.dart';

/// 서울 버스 도착정보 원격 데이터 소스 인터페이스
abstract class SeoulBusArrivalRemoteDataSource {
  /// 정류소별 버스 도착정보 조회
  Future<List<SeoulBusArrivalResponse>> getBusArrivalInfo(String stationId);

  /// 도시코드와 정류소ID로 버스 도착정보 조회
  Future<List<SeoulBusArrivalResponse>> getBusArrivalInfoWithCityCode(
    String cityCode,
    String nodeId,
  );
}

/// 서울 버스 도착정보 원격 데이터 소스 구현
class SeoulBusArrivalRemoteDataSourceImpl implements SeoulBusArrivalRemoteDataSource {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  SeoulBusArrivalRemoteDataSourceImpl();

  @override
  Future<List<SeoulBusArrivalResponse>> getBusArrivalInfo(String stationId) async {
    try {
      // 호출자가 nodeId만 전달하므로, cityCode가 필요한 경우 여기서 처리
      // 실제로 getBusArrivalInfo는 두 개의 파라미터가 필요함
      // 이 메서드는 nodeId만 받기 때문에, 호출자를 변경해야 함
      print('🚌 서울 버스 도착정보 API 요청 시작: $stationId');
      print('⚠️ 경고: getBusArrivalInfo에는 cityCode가 필요합니다');

      return [];
    } catch (e, stackTrace) {
      print('❌ 서울 버스 도착정보 검색 중 오류: $e');
      print('❌ 오류 타입: ${e.runtimeType}');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }

  /// 서울 버스 도착정보 조회 (cityCode 포함)
  Future<List<SeoulBusArrivalResponse>> getBusArrivalInfoWithCityCode(
    String cityCode,
    String nodeId,
  ) async {
    try {
      print('🚌 서울 버스 도착정보 API 요청 시작: cityCode=$cityCode, nodeId=$nodeId');

      final responseData = await apiProvider.busClient.getSeoulBusArrival(
        cityCode: cityCode,
        nodeId: nodeId,
      );

      print('📊 서울 버스 도착정보 API 응답 데이터: $responseData');
      return _parseArrivalResponse(responseData);
    } catch (e, stackTrace) {
      print('❌ 서울 버스 도착정보 검색 중 오류: $e');
      print('❌ 오류 타입: ${e.runtimeType}');
      print('📍 스택 트레이스: $stackTrace');

      // 404 에러는 API 자체가 작동하지 않는 것이므로 안내
      if (e.toString().contains('404')) {
        print('⚠️ 서울 버스 도착정보 API가 현재 사용 불가능합니다.');
      }

      return [];
    }
  }

  /// JSON 응답 파싱
  List<SeoulBusArrivalResponse> _parseArrivalResponse(dynamic jsonData) {
    try {
      final data = jsonData is String ? jsonDecode(jsonData) : jsonData;
      final result = data['msgBody'];

      List<SeoulBusArrivalResponse> arrivalInfos = [];

      if (result != null && result['itemList'] != null) {
        final itemList = result['itemList'];

        List<dynamic> items = [];
        if (itemList is List) {
          items = itemList;
        } else if (itemList is Map && itemList['item'] != null) {
          if (itemList['item'] is List) {
            items = itemList['item'];
          } else {
            items = [itemList['item']];
          }
        }

        print('📄 서울 버스 도착정보 원본 데이터 개수: ${items.length}');

        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          try {
            final arrivalInfo = SeoulBusArrivalResponse.fromJson(item);
            arrivalInfos.add(arrivalInfo);

            print('서울 버스 도착정보 ${i + 1}. ${arrivalInfo.routeNo}번');
            print('   - 도착 예정: ${arrivalInfo.arrTime}초');
            print('   - 도착 전 정류장: ${arrivalInfo.arrPrevStationCnt}개');
            print('');
          } catch (e) {
            print('❌ 버스 도착정보 파싱 오류 ($i번째): $e');
            print('   - 원본 데이터: $item');
            continue;
          }
        }
      }

      print('✅ 서울 버스 도착정보 파싱 완료! 총 ${arrivalInfos.length}개');
      return arrivalInfos;
    } catch (e, stackTrace) {
      print('❌ JSON 파싱 오류: $e');
      print('📍 스택 트레이스: $stackTrace');
      return [];
    }
  }
}