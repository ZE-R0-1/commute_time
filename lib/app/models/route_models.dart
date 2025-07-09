import '../services/subway_service.dart';
import 'bus_models.dart';

/// 교통수단 타입
enum TransportType {
  subway,  // 지하철
  bus,     // 버스
  walk,    // 도보
}

/// 출퇴근 방향
enum CommuteDirection {
  toWork,    // 출근 (집 → 회사)
  toHome,    // 퇴근 (회사 → 집)
  flexible,  // 유연 (현재 위치 기준)
}

/// 경로 구간 정보
class RouteSection {
  final TransportType transportType;
  final String startStationName;
  final String endStationName;
  final String lineName;        // 노선명 (예: 2호선, 271번)
  final String color;           // 노선 색상
  final double distance;        // 거리(미터)
  final int duration;          // 소요시간(초)

  RouteSection({
    required this.transportType,
    required this.startStationName,
    required this.endStationName,
    required this.lineName,
    required this.color,
    required this.distance,
    required this.duration,
  });

  /// 교통수단 아이콘 이름
  String get iconName {
    switch (transportType) {
      case TransportType.subway:
        return 'subway';
      case TransportType.bus:
        return 'directions_bus';
      case TransportType.walk:
        return 'directions_walk';
    }
  }

  /// 교통수단 이름
  String get typeName {
    switch (transportType) {
      case TransportType.subway:
        return '지하철';
      case TransportType.bus:
        return '버스';
      case TransportType.walk:
        return '도보';
    }
  }

  /// 소요시간 텍스트
  String get durationText {
    final minutes = duration ~/ 60;
    if (minutes < 1) {
      return '1분 미만';
    } else if (minutes < 60) {
      return '${minutes}분';
    } else {
      final hours = minutes ~/ 60;
      final remainMinutes = minutes % 60;
      return remainMinutes > 0 ? '${hours}시간 ${remainMinutes}분' : '${hours}시간';
    }
  }

  /// 거리 텍스트
  String get distanceText {
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}

/// 전체 출퇴근 경로 정보
class CommuteRoute {
  final String startName;
  final String endName;
  final double totalDistance;
  final int totalDuration;
  final List<RouteSection> sections;

  CommuteRoute({
    required this.startName,
    required this.endName,
    required this.totalDistance,
    required this.totalDuration,
    required this.sections,
  });

  /// 지하철 구간만 필터링
  List<RouteSection> get subwaySections {
    return sections.where((section) => section.transportType == TransportType.subway).toList();
  }

  /// 버스 구간만 필터링
  List<RouteSection> get busSections {
    return sections.where((section) => section.transportType == TransportType.bus).toList();
  }

  /// 도보 구간만 필터링
  List<RouteSection> get walkSections {
    return sections.where((section) => section.transportType == TransportType.walk).toList();
  }

  /// 전체 소요시간 텍스트
  String get totalDurationText {
    final minutes = totalDuration ~/ 60;
    if (minutes < 60) {
      return '${minutes}분';
    } else {
      final hours = minutes ~/ 60;
      final remainMinutes = minutes % 60;
      return remainMinutes > 0 ? '${hours}시간 ${remainMinutes}분' : '${hours}시간';
    }
  }

  /// 전체 거리 텍스트
  String get totalDistanceText {
    if (totalDistance < 1000) {
      return '${totalDistance.toInt()}m';
    } else {
      return '${(totalDistance / 1000).toStringAsFixed(1)}km';
    }
  }

  /// 경로 요약 텍스트
  String get routeSummary {
    final types = sections.map((section) => section.typeName).toList();
    return types.join(' → ');
  }

  /// 주요 노선 정보
  String get mainLines {
    final lines = sections
        .where((section) => section.transportType != TransportType.walk)
        .map((section) => section.lineName)
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.join(', ');
  }
}

/// 경로 기반 실시간 교통정보
class RouteBasedTransportInfo {
  final CommuteRoute route;
  final List<SubwayStationInfo> subwayInfos;
  final List<BusStationInfo> busInfos;
  final DateTime lastUpdated;

  RouteBasedTransportInfo({
    required this.route,
    required this.subwayInfos,
    required this.busInfos,
    required this.lastUpdated,
  });

  /// 업데이트 필요 여부 (3분 경과시)
  bool get needsUpdate {
    return DateTime.now().difference(lastUpdated).inMinutes >= 3;
  }
}

/// 경로상 지하철역 정보
class SubwayStationInfo {
  final String stationName;
  final String lineName;
  final String color;
  final List<SubwayArrival> arrivals;

  SubwayStationInfo({
    required this.stationName,
    required this.lineName,
    required this.color,
    required this.arrivals,
  });
}

/// 경로상 버스정류장 정보
class BusStationInfo {
  final String stationName;
  final String stationId;
  final List<BusArrival> arrivals;

  BusStationInfo({
    required this.stationName,
    required this.stationId,
    required this.arrivals,
  });
}

// Note: SubwayArrival과 BusArrival은 기존 모델을 import해서 사용
// import '../services/subway_service.dart' for SubwayArrival
// import '../models/bus_models.dart' for BusArrival