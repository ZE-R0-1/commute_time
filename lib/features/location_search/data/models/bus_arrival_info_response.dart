import '../../domain/entities/bus_arrival_info_entity.dart';

/// 버스 도착정보 응답 모델
class BusArrivalInfoResponse {
  final String routeId;
  final String routeName;
  final String routeTypeName;
  final String stationId;
  final String stationName;
  final int predictTime1;
  final int predictTime2;
  final int locationNo1;
  final int locationNo2;
  final String lowPlate1;
  final String lowPlate2;
  final String plateNo1;
  final String plateNo2;
  final int remainSeatCnt1;
  final int remainSeatCnt2;
  final int staOrder;
  final DateTime loadedAt;

  BusArrivalInfoResponse({
    required this.routeId,
    required this.routeName,
    required this.routeTypeName,
    required this.stationId,
    required this.stationName,
    required this.predictTime1,
    required this.predictTime2,
    required this.locationNo1,
    required this.locationNo2,
    required this.lowPlate1,
    required this.lowPlate2,
    required this.plateNo1,
    required this.plateNo2,
    required this.remainSeatCnt1,
    required this.remainSeatCnt2,
    required this.staOrder,
    DateTime? loadedAt,
  }) : loadedAt = loadedAt ?? DateTime.now();

  /// 엔티티로 변환
  BusArrivalInfoEntity toEntity() {
    return BusArrivalInfoEntity(
      routeId: routeId,
      routeName: routeName,
      routeTypeName: routeTypeName,
      stationId: stationId,
      stationName: stationName,
      predictTime1: predictTime1,
      predictTime2: predictTime2,
      locationNo1: locationNo1,
      locationNo2: locationNo2,
      lowPlate1: lowPlate1,
      lowPlate2: lowPlate2,
      plateNo1: plateNo1,
      plateNo2: plateNo2,
      remainSeatCnt1: remainSeatCnt1,
      remainSeatCnt2: remainSeatCnt2,
      staOrder: staOrder,
      loadedAt: loadedAt,
    );
  }

  /// API 응답에서 변환
  factory BusArrivalInfoResponse.fromJson(Map<String, dynamic> json, String routeTypeCd) {
    // routeTypeCd를 routeTypeName으로 변환
    String routeTypeName = '일반';
    switch (routeTypeCd) {
      case '11':
        routeTypeName = '직행좌석';
        break;
      case '12':
        routeTypeName = '좌석';
        break;
      case '13':
        routeTypeName = '일반';
        break;
      case '21':
        routeTypeName = '광역급행';
        break;
      default:
        routeTypeName = '일반';
    }

    return BusArrivalInfoResponse(
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName']?.toString() ?? '',
      routeTypeName: routeTypeName,
      stationId: json['stationId']?.toString() ?? '',
      stationName: json['stationName']?.toString() ?? '',
      predictTime1: int.tryParse(json['predictTime1']?.toString() ?? '0') ?? 0,
      predictTime2: int.tryParse(json['predictTime2']?.toString() ?? '0') ?? 0,
      locationNo1: int.tryParse(json['locationNo1']?.toString() ?? '0') ?? 0,
      locationNo2: int.tryParse(json['locationNo2']?.toString() ?? '0') ?? 0,
      lowPlate1: json['lowPlate1']?.toString() == '1' ? 'Y' : 'N',
      lowPlate2: json['lowPlate2']?.toString() == '1' ? 'Y' : 'N',
      plateNo1: json['plateNo1']?.toString() ?? '',
      plateNo2: json['plateNo2']?.toString() ?? '',
      remainSeatCnt1: int.tryParse(json['remainSeatCnt1']?.toString() ?? '0') ?? 0,
      remainSeatCnt2: int.tryParse(json['remainSeatCnt2']?.toString() ?? '0') ?? 0,
      staOrder: int.tryParse(json['staOrder']?.toString() ?? '0') ?? 0,
    );
  }
}