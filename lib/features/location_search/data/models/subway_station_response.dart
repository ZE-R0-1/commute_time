import '../../domain/entities/subway_station_entity.dart';

/// 지하철역 검색 응답 모델
class SubwayStationResponse {
  final int id;
  final String place_name;
  final String address_name;
  final double y;
  final double x;
  final int distance;

  SubwayStationResponse({
    required this.id,
    required this.place_name,
    required this.address_name,
    required this.y,
    required this.x,
    required this.distance,
  });

  factory SubwayStationResponse.fromJson(Map<String, dynamic> json) {
    // 각 필드를 안전하게 변환
    final id = json['id'];
    final place_name = json['place_name'] as String;
    final address_name = json['address_name'] as String;
    final x = json['x'];
    final y = json['y'];
    final distance = json['distance'];

    // 숫자 변환 (String 또는 num 모두 지원)
    int idValue = (id is int) ? id : int.parse(id.toString());
    double xValue = (x is double)
        ? x
        : ((x is int) ? x.toDouble() : double.parse(x.toString()));
    double yValue = (y is double)
        ? y
        : ((y is int) ? y.toDouble() : double.parse(y.toString()));
    int distanceValue = (distance is int) ? distance : int.parse(distance.toString());

    return SubwayStationResponse(
      id: idValue,
      place_name: place_name,
      address_name: address_name,
      y: yValue,
      x: xValue,
      distance: distanceValue,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'place_name': place_name,
    'address_name': address_name,
    'y': y,
    'x': x,
    'distance': distance,
  };

  /// Entity로 변환
  SubwayStationEntity toEntity() {
    return SubwayStationEntity(
      id: id.toString(),
      placeName: place_name,
      addressName: address_name,
      latitude: y,
      longitude: x,
      distance: distance,
    );
  }
}