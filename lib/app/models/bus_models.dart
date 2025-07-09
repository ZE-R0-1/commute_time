class BusStation {
  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final double distance;
  final String stationSeq;

  BusStation({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.stationSeq,
  });

  factory BusStation.fromJson(Map<String, dynamic> json) {
    return BusStation(
      stationId: json['arsId'] ?? '',
      stationName: json['stNm'] ?? '',
      latitude: double.tryParse(json['tmY'].toString()) ?? 0.0,
      longitude: double.tryParse(json['tmX'].toString()) ?? 0.0,
      distance: double.tryParse(json['dist'].toString()) ?? 0.0,
      stationSeq: json['stationSeq'] ?? '',
    );
  }
}

class BusArrival {
  final String routeId;
  final String routeName;
  final String routeType;
  final int arrivalTime1;
  final int arrivalTime2;
  final String direction;
  final bool isLowFloor;
  final String congestion;
  final String stationSeq;

  BusArrival({
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.arrivalTime1,
    required this.arrivalTime2,
    required this.direction,
    required this.isLowFloor,
    required this.congestion,
    required this.stationSeq,
  });

  factory BusArrival.fromJson(Map<String, dynamic> json) {
    return BusArrival(
      routeId: json['busRouteId'] ?? '',
      routeName: json['rtNm'] ?? '',
      routeType: _getRouteType(json['routeType']),
      arrivalTime1: int.tryParse(json['traTime1'].toString()) ?? 0,
      arrivalTime2: int.tryParse(json['traTime2'].toString()) ?? 0,
      direction: json['adirection'] ?? '',
      isLowFloor: json['busType1'] == '1',
      congestion: _getCongestionLevel(json['reride_Num1']),
      stationSeq: json['staOrd'] ?? '',
    );
  }

  static String _getRouteType(dynamic type) {
    switch (type.toString()) {
      case '1':
        return '공항';
      case '2':
        return '마을';
      case '3':
        return '간선';
      case '4':
        return '지선';
      case '5':
        return '순환';
      case '6':
        return '광역';
      case '7':
        return '인천';
      case '8':
        return '경기';
      case '9':
        return '폐지';
      case '0':
        return '공용';
      default:
        return '일반';
    }
  }

  static String _getCongestionLevel(dynamic level) {
    switch (level.toString()) {
      case '0':
        return '정보없음';
      case '3':
        return '여유';
      case '4':
        return '보통';
      case '5':
        return '혼잡';
      case '6':
        return '매우혼잡';
      default:
        return '정보없음';
    }
  }

  String get formattedArrivalTime1 {
    if (arrivalTime1 == 0) return '도착';
    final minutes = (arrivalTime1 / 60).floor();
    return '${minutes}분 후';
  }

  String get formattedArrivalTime2 {
    if (arrivalTime2 == 0) return '도착';
    final minutes = (arrivalTime2 / 60).floor();
    return '${minutes}분 후';
  }
}

class BusRoute {
  final String routeId;
  final String routeName;
  final String routeType;
  final String firstBusTime;
  final String lastBusTime;
  final String startStation;
  final String endStation;

  BusRoute({
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.firstBusTime,
    required this.lastBusTime,
    required this.startStation,
    required this.endStation,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      routeId: json['busRouteId'] ?? '',
      routeName: json['busRouteNm'] ?? '',
      routeType: json['routeType'] ?? '',
      firstBusTime: json['firstBusTm'] ?? '',
      lastBusTime: json['lastBusTm'] ?? '',
      startStation: json['stStationNm'] ?? '',
      endStation: json['edStationNm'] ?? '',
    );
  }
}