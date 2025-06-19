import 'transport_mode.dart';

class RouteStep {
  final String id;
  final TransportMode mode;
  final String instruction;      // 안내 메시지
  final int duration;           // 소요시간 (분)
  final int distance;           // 거리 (미터)
  final String startLocation;   // 시작점
  final String endLocation;     // 도착점
  final Map<String, dynamic> details; // 세부정보 (노선번호, 차량번호 등)
  final DateTime? departureTime; // 출발 시간
  final DateTime? arrivalTime;   // 도착 시간
  final int cost;               // 비용 (원)
  final bool isDelayed;         // 지연 여부
  final String? delayMessage;   // 지연 메시지

  const RouteStep({
    required this.id,
    required this.mode,
    required this.instruction,
    required this.duration,
    required this.distance,
    required this.startLocation,
    required this.endLocation,
    required this.details,
    this.departureTime,
    this.arrivalTime,
    this.cost = 0,
    this.isDelayed = false,
    this.delayMessage,
  });

  // 거리를 사람이 읽기 쉬운 형태로 변환
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance}m';
    } else {
      final km = (distance / 1000).toStringAsFixed(1);
      return '${km}km';
    }
  }

  // 소요시간을 사람이 읽기 쉬운 형태로 변환
  String get formattedDuration {
    if (duration < 60) {
      return '${duration}분';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '${hours}시간';
      } else {
        return '${hours}시간 ${minutes}분';
      }
    }
  }

  // 출발 시간 포맷
  String get formattedDepartureTime {
    if (departureTime == null) return '';
    return '${departureTime!.hour.toString().padLeft(2, '0')}:${departureTime!.minute.toString().padLeft(2, '0')}';
  }

  // 도착 시간 포맷
  String get formattedArrivalTime {
    if (arrivalTime == null) return '';
    return '${arrivalTime!.hour.toString().padLeft(2, '0')}:${arrivalTime!.minute.toString().padLeft(2, '0')}';
  }

  // 지하철 노선 정보 가져오기
  String? get subwayLine {
    if (mode != TransportMode.subway) return null;
    return details['line'] as String?;
  }

  // 버스 번호 가져오기
  String? get busNumber {
    if (mode != TransportMode.bus) return null;
    return details['busNumber'] as String?;
  }

  // 정류장/역 정보 가져오기
  String? get stationInfo {
    return details['station'] as String?;
  }

  // 환승 정보 가져오기
  String? get transferInfo {
    if (mode != TransportMode.transfer) return null;
    return details['transferInfo'] as String?;
  }

  // 복사 메서드 (상태 업데이트용)
  RouteStep copyWith({
    String? id,
    TransportMode? mode,
    String? instruction,
    int? duration,
    int? distance,
    String? startLocation,
    String? endLocation,
    Map<String, dynamic>? details,
    DateTime? departureTime,
    DateTime? arrivalTime,
    int? cost,
    bool? isDelayed,
    String? delayMessage,
  }) {
    return RouteStep(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      instruction: instruction ?? this.instruction,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      details: details ?? this.details,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      cost: cost ?? this.cost,
      isDelayed: isDelayed ?? this.isDelayed,
      delayMessage: delayMessage ?? this.delayMessage,
    );
  }
}