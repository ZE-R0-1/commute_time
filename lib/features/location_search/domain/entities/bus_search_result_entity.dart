import 'package:equatable/equatable.dart';
import 'gyeonggi_bus_stop_entity.dart';
import 'seoul_bus_stop_entity.dart';

/// 버스 검색 결과 엔티티
class BusSearchResultEntity extends Equatable {
  final List<GyeonggiBusStopEntity> gyeonggiBusStops;
  final List<SeoulBusStopEntity> seoulBusStops;

  const BusSearchResultEntity({
    required this.gyeonggiBusStops,
    required this.seoulBusStops,
  });

  int get totalCount => gyeonggiBusStops.length + seoulBusStops.length;
  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;

  @override
  List<Object?> get props => [
    gyeonggiBusStops,
    seoulBusStops,
  ];
}