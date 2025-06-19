import 'package:commute_time_app/screens/route_detail/models/transport_mode.dart';

import 'route_step.dart';

class RouteDetail {
  final String routeId;
  final String routeName;       // 경로 이름 (예: "최단시간", "최저요금")
  final String origin;          // 출발지
  final String destination;     // 도착지
  final DateTime departureTime; // 출발 시간
  final DateTime arrivalTime;   // 도착 시간
  final int totalDuration;      // 총 소요시간 (분)
  final int totalCost;         // 총 비용 (원)
  final int totalDistance;     // 총 거리 (미터)
  final List<RouteStep> steps; // 경로 단계들
  final bool isRecommended;    // 추천 경로 여부
  final String routeType;      // "morning" | "evening"
  final String description;    // 경로 설명
  final bool hasRealTimeInfo;  // 실시간 정보 제공 여부
  final DateTime lastUpdated;  // 마지막 업데이트 시간

  const RouteDetail({
    required this.routeId,
    required this.routeName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
    required this.totalDuration,
    required this.totalCost,
    required this.totalDistance,
    required this.steps,
    required this.routeType,
    this.isRecommended = false,
    this.description = '',
    this.hasRealTimeInfo = false,
    required this.lastUpdated,
  });

  // 총 소요시간을 사람이 읽기 쉬운 형태로 변환
  String get formattedTotalDuration {
    if (totalDuration < 60) {
      return '${totalDuration}분';
    } else {
      final hours = totalDuration ~/ 60;
      final minutes = totalDuration % 60;
      if (minutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${minutes}분';
      }
    }
  }

  // 총 거리를 사람이 읽기 쉬운 형태로 변환
  String get formattedTotalDistance {
    if (totalDistance < 1000) {
      return '${totalDistance}m';
    } else {
      final km = (totalDistance / 1000).toStringAsFixed(1);
      return '${km}km';
    }
  }

  // 총 비용을 포맷
  String get formattedTotalCost {
    return '${totalCost.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}원';
  }

  // 출발 시간 포맷
  String get formattedDepartureTime {
    return '${departureTime.hour.toString().padLeft(2, '0')}:${departureTime.minute.toString().padLeft(2, '0')}';
  }

  // 도착 시간 포맷
  String get formattedArrivalTime {
    return '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }

  // 환승 횟수 계산
  int get transferCount {
    return steps.where((step) => step.mode == TransportMode.transfer).length;
  }

  // 도보 시간 계산
  int get walkingDuration {
    return steps
        .where((step) => step.mode == TransportMode.walk)
        .fold(0, (sum, step) => sum + step.duration);
  }

  // 지연 여부 확인
  bool get hasDelays {
    return steps.any((step) => step.isDelayed);
  }

  // 지연된 단계들
  List<RouteStep> get delayedSteps {
    return steps.where((step) => step.isDelayed).toList();
  }

  // 주요 교통수단 (가장 오래 탑승하는 교통수단)
  TransportMode get primaryTransportMode {
    final transportDurations = <TransportMode, int>{};

    for (final step in steps) {
      if (step.mode != TransportMode.walk && step.mode != TransportMode.transfer) {
        transportDurations[step.mode] =
            (transportDurations[step.mode] ?? 0) + step.duration;
      }
    }

    if (transportDurations.isEmpty) return TransportMode.walk;

    return transportDurations.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // 현재 시간 기준으로 경로 상태 확인
  String getRouteStatus() {
    final now = DateTime.now();

    if (now.isBefore(departureTime)) {
      final diff = departureTime.difference(now).inMinutes;
      return '출발까지 ${diff}분 남음';
    } else if (now.isAfter(departureTime) && now.isBefore(arrivalTime)) {
      return '이동 중';
    } else if (now.isAfter(arrivalTime)) {
      return '도착 완료';
    } else {
      return '출발 시간';
    }
  }

  // 복사 메서드 (상태 업데이트용)
  RouteDetail copyWith({
    String? routeId,
    String? routeName,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? totalDuration,
    int? totalCost,
    int? totalDistance,
    List<RouteStep>? steps,
    bool? isRecommended,
    String? routeType,
    String? description,
    bool? hasRealTimeInfo,
    DateTime? lastUpdated,
  }) {
    return RouteDetail(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      totalDuration: totalDuration ?? this.totalDuration,
      totalCost: totalCost ?? this.totalCost,
      totalDistance: totalDistance ?? this.totalDistance,
      steps: steps ?? this.steps,
      isRecommended: isRecommended ?? this.isRecommended,
      routeType: routeType ?? this.routeType,
      description: description ?? this.description,
      hasRealTimeInfo: hasRealTimeInfo ?? this.hasRealTimeInfo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}