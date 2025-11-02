/// 위치 정보 모델
///
/// 출발지, 도착지, 환승지 등 경로 설정에서 사용되는 위치 정보를 나타냅니다.
class LocationInfo {
  final String name;
  final String type; // 'subway' 또는 'bus'
  final String lineInfo;
  final String code;
  final String? cityCode; // 서울 버스 API용
  final String? routeId; // 경기도 버스 v2 API용
  final int? staOrder; // 경기도 버스 v2 API용

  LocationInfo({
    required this.name,
    required this.type,
    required this.lineInfo,
    required this.code,
    this.cityCode,
    this.routeId,
    this.staOrder,
  });

  /// LocationInfo를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'lineInfo': lineInfo,
      'code': code,
      if (cityCode != null) 'cityCode': cityCode,
      if (routeId != null) 'routeId': routeId,
      if (staOrder != null) 'staOrder': staOrder,
    };
  }

  /// Map에서 LocationInfo 생성
  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      name: map['name'] ?? '',
      type: map['type'] ?? 'subway',
      lineInfo: map['lineInfo'] ?? '',
      code: map['code'] ?? '',
      cityCode: map['cityCode'],
      routeId: map['routeId'],
      staOrder: map['staOrder'],
    );
  }

  @override
  String toString() => 'LocationInfo(name: $name, type: $type, lineInfo: $lineInfo, code: $code, cityCode: $cityCode, routeId: $routeId, staOrder: $staOrder)';
}