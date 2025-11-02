import 'package:equatable/equatable.dart';

/// 서울 버스 도착정보 엔티티
class SeoulBusArrivalEntity extends Equatable {
  final String routeNo;        // 노선번호
  final String routeTp;        // 노선유형 (1:간선, 2:광역, 3:지선, 4:순환, 5:셔틀, 6:야간, 7:공항, 8:마을)
  final int arrTime;           // 도착예정시간(초)
  final int arrPrevStationCnt; // 도착 전 정류장 수

  const SeoulBusArrivalEntity({
    required this.routeNo,
    required this.routeTp,
    required this.arrTime,
    required this.arrPrevStationCnt,
  });

  /// 분 단위 도착예정시간
  int get arrTimeInMinutes => arrTime ~/ 60;

  @override
  List<Object?> get props => [routeNo, routeTp, arrTime, arrPrevStationCnt];
}