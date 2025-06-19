// 출퇴근 타입
enum CommuteType {
  morning,
  evening;

  String get name => this == CommuteType.morning ? '출근' : '퇴근';
}

// 경로 단계 타입
enum RouteStepType { walk, subway, bus, transfer }

// 경로 단계 정보
class RouteStep {
  final RouteStepType type;
  final String instruction;
  final String duration;
  final String distance;
  final String icon;
  final String color;
  final String? lineNumber;

  RouteStep({
    required this.type,
    required this.instruction,
    required this.duration,
    required this.distance,
    required this.icon,
    required this.color,
    this.lineNumber,
  });
}

// 대안 경로 정보
class AlternativeRoute {
  final String title;
  final String duration;
  final String cost;
  final int transfers;
  final String description;
  final bool isRecommended;

  AlternativeRoute({
    required this.title,
    required this.duration,
    required this.cost,
    required this.transfers,
    required this.description,
    required this.isRecommended,
  });
}

// 실시간 업데이트 타입
enum LiveUpdateType { info, warning, error }

// 실시간 업데이트 정보
class LiveUpdate {
  final LiveUpdateType type;
  final String message;
  final String time;

  LiveUpdate({
    required this.type,
    required this.message,
    required this.time,
  });
}