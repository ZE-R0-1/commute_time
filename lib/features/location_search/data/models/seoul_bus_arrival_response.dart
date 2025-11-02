import '../../domain/entities/seoul_bus_arrival_entity.dart';

/// 서울 버스 도착정보 응답 모델
class SeoulBusArrivalResponse {
  final String routeNo;
  final String routeTp;
  final int arrTime;
  final int arrPrevStationCnt;

  SeoulBusArrivalResponse({
    required this.routeNo,
    required this.routeTp,
    required this.arrTime,
    required this.arrPrevStationCnt,
  });

  /// 엔티티로 변환
  SeoulBusArrivalEntity toEntity() {
    return SeoulBusArrivalEntity(
      routeNo: routeNo,
      routeTp: routeTp,
      arrTime: arrTime,
      arrPrevStationCnt: arrPrevStationCnt,
    );
  }

  /// API 응답에서 변환
  factory SeoulBusArrivalResponse.fromJson(Map<String, dynamic> json) {
    return SeoulBusArrivalResponse(
      routeNo: json['routeNo']?.toString() ?? '',
      routeTp: json['routeTp']?.toString() ?? '1',
      arrTime: int.tryParse(json['arrTime']?.toString() ?? '0') ?? 0,
      arrPrevStationCnt: int.tryParse(json['arrPrevStationCnt']?.toString() ?? '0') ?? 0,
    );
  }
}