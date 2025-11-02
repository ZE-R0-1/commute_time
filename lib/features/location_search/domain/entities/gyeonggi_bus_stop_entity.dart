import 'package:equatable/equatable.dart';

/// 경기도 버스정류장 엔티티
class GyeonggiBusStopEntity extends Equatable {
  final String stationId;
  final String stationName;
  final double x;
  final double y;
  final String regionName;
  final String districtCd;
  final String centerYn;
  final String mgmtId;
  final String mobileNo;

  const GyeonggiBusStopEntity({
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

  @override
  List<Object?> get props => [
    stationId,
    stationName,
    x,
    y,
    regionName,
    districtCd,
    centerYn,
    mgmtId,
    mobileNo,
  ];
}