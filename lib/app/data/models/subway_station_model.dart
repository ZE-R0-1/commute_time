class SubwayStation {
  final String stationName;    // 역명
  final String lineNum;        // 호선 번호
  final String stationCode;    // 역 코드
  final String? frCode;        // 외부 코드
  final double? lat;           // 위도
  final double? lng;           // 경도

  SubwayStation({
    required this.stationName,
    required this.lineNum,
    required this.stationCode,
    this.frCode,
    this.lat,
    this.lng,
  });

  factory SubwayStation.fromJson(Map<String, dynamic> json) {
    return SubwayStation(
      stationName: json['STATION_NM'] ?? json['statnNm'] ?? '',
      lineNum: json['LINE_NUM'] ?? json['lineNum'] ?? '',
      stationCode: json['STATION_CD'] ?? json['statnCd'] ?? '',
      frCode: json['FR_CODE'] ?? json['frCode'],
      lat: _parseDouble(json['XPOINT'] ?? json['lat']),
      lng: _parseDouble(json['YPOINT'] ?? json['lng']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    if (value is int) return value.toDouble();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'STATION_NM': stationName,
      'LINE_NUM': lineNum,
      'STATION_CD': stationCode,
      'FR_CODE': frCode,
      'XPOINT': lat,
      'YPOINT': lng,
    };
  }

  /// 노선명 표시 (예: "2호선")
  String get lineDisplayName {
    switch (lineNum) {
      case '1':
        return '1호선';
      case '2':
        return '2호선';
      case '3':
        return '3호선';
      case '4':
        return '4호선';
      case '5':
        return '5호선';
      case '6':
        return '6호선';
      case '7':
        return '7호선';
      case '8':
        return '8호선';
      case '9':
        return '9호선';
      case 'K':
        return '경의중앙선';
      case 'B':
        return '분당선';
      case 'A':
        return '공항철도';
      case 'G':
        return '경춘선';
      case 'S':
        return '신분당선';
      default:
        return '${lineNum}호선';
    }
  }

  /// 노선 색상
  String get lineColor {
    final colors = {
      '1': '#263C96',   // 1호선
      '2': '#00A84D',   // 2호선
      '3': '#EF7C1C',   // 3호선
      '4': '#00A4E3',   // 4호선
      '5': '#996CAC',   // 5호선
      '6': '#CD7C2F',   // 6호선
      '7': '#747F00',   // 7호선
      '8': '#E6186C',   // 8호선
      '9': '#BB8336',   // 9호선
      'K': '#77C4A3',   // 경의중앙선
      'B': '#FFCD12',   // 분당선
      'A': '#0090D2',   // 공항철도
      'G': '#2FB8AD',   // 경춘선
      'S': '#D31145',   // 신분당선
    };
    return colors[lineNum] ?? '#6B7280';
  }

  /// 역명에서 "역" 제거
  String get cleanStationName {
    return stationName.replaceAll('역', '');
  }

  /// 전체 표시명 (역명 + 호선)
  String get fullDisplayName {
    return '$cleanStationName ($lineDisplayName)';
  }

  @override
  String toString() {
    return 'SubwayStation(name: $stationName, line: $lineDisplayName, code: $stationCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubwayStation &&
        other.stationName == stationName &&
        other.lineNum == lineNum &&
        other.stationCode == stationCode;
  }

  @override
  int get hashCode {
    return stationName.hashCode ^ lineNum.hashCode ^ stationCode.hashCode;
  }
}