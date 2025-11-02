import 'package:equatable/equatable.dart';

/// 버스 도착정보 엔티티
class BusArrivalInfoEntity extends Equatable {
  final String routeId;          // 노선ID
  final String routeName;        // 노선명
  final String routeTypeName;    // 노선유형명
  final String stationId;        // 정류소ID
  final String stationName;      // 정류소명
  final int predictTime1;        // 첫번째차량 도착예정시간(분)
  final int predictTime2;        // 두번째차량 도착예정시간(분)
  final int locationNo1;         // 첫번째차량 현재위치 정류장수
  final int locationNo2;         // 두번째차량 현재위치 정류장수
  final String lowPlate1;        // 첫번째차량 저상버스여부(Y/N)
  final String lowPlate2;        // 두번째차량 저상버스여부(Y/N)
  final String plateNo1;         // 첫번째차량 차량번호
  final String plateNo2;         // 두번째차량 차량번호
  final int remainSeatCnt1;      // 첫번째차량 빈자리수
  final int remainSeatCnt2;      // 두번째차량 빈자리수
  final int staOrder;            // 정류소 순번
  final DateTime loadedAt;       // 데이터 로드 시간

  const BusArrivalInfoEntity({
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
    required this.loadedAt,
  });

  // 실시간 카운트다운을 위한 계산된 시간 (초 단위)
  int get predictTimeInSeconds1 {
    final elapsed = DateTime.now().difference(loadedAt).inSeconds;
    final totalSeconds = predictTime1 * 60;
    final remaining = totalSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  int get predictTimeInSeconds2 {
    final elapsed = DateTime.now().difference(loadedAt).inSeconds;
    final totalSeconds = predictTime2 * 60;
    final remaining = totalSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  // 포맷된 시간 표시 (분:초)
  String get formattedTime1 {
    final seconds = predictTimeInSeconds1;
    if (seconds <= 0) return '곧 도착';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}분 ${remainingSeconds}초';
  }

  String get formattedTime2 {
    final seconds = predictTimeInSeconds2;
    if (seconds <= 0) return '곧 도착';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}분 ${remainingSeconds}초';
  }

  @override
  List<Object?> get props => [
    routeId,
    routeName,
    routeTypeName,
    stationId,
    stationName,
    predictTime1,
    predictTime2,
    locationNo1,
    locationNo2,
    lowPlate1,
    lowPlate2,
    plateNo1,
    plateNo2,
    remainSeatCnt1,
    remainSeatCnt2,
    staOrder,
    loadedAt,
  ];
}