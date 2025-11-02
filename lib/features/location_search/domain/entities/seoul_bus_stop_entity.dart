import 'package:equatable/equatable.dart';

/// 서울 버스정류장 엔티티
class SeoulBusStopEntity extends Equatable {
  final String stationId;
  final String stationNm;
  final double gpsX;
  final double gpsY;
  final String direction;
  final String stationTp;
  final String regionName;
  final String cityCode;

  const SeoulBusStopEntity({
    required this.stationId,
    required this.stationNm,
    required this.gpsX,
    required this.gpsY,
    required this.direction,
    required this.stationTp,
    this.regionName = '서울',
    required this.cityCode,
  });

  @override
  List<Object?> get props => [
    stationId,
    stationNm,
    gpsX,
    gpsY,
    direction,
    stationTp,
    regionName,
    cityCode,
  ];
}