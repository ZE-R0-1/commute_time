class SubwayArrival {
  final String stationName;     // 지하철 역명
  final String subwayNm;        // 노선명 (예: "2호선")
  final String subwayId;        // 호선ID (예: "2")
  final String updnLine;        // 상하행선구분 (상행/하행)
  final String trainLineNm;     // 도착지방면 (예: "외선순환")
  final String arvlMsg2;        // 첫번째 도착 메시지
  final String arvlMsg3;        // 두번째 도착 메시지
  final String arvlCd;          // 도착코드 (0:진입, 1:도착, 2:출발, 3:전역출발, 4:전역진입, 5:전역도착)
  final String? barvlDt;        // 첫번째 도착 시간
  final String? ordkey;         // 순서

  SubwayArrival({
    required this.stationName,
    required this.subwayNm,
    required this.subwayId,
    required this.updnLine,
    required this.trainLineNm,
    required this.arvlMsg2,
    required this.arvlMsg3,
    required this.arvlCd,
    this.barvlDt,
    this.ordkey,
  });

  factory SubwayArrival.fromJson(Map<String, dynamic> json) {
    return SubwayArrival(
      stationName: json['statnNm'] ?? '',
      subwayNm: _getSubwayDisplayName(json['subwayId']),
      subwayId: json['subwayId']?.toString() ?? '',
      updnLine: json['updnLine'] ?? '',
      trainLineNm: json['trainLineNm'] ?? '',
      arvlMsg2: json['arvlMsg2'] ?? '',
      arvlMsg3: json['arvlMsg3'] ?? '',
      arvlCd: json['arvlCd']?.toString() ?? '',
      barvlDt: json['barvlDt']?.toString(),
      ordkey: json['ordkey']?.toString(),
    );
  }

  /// 지하철 ID를 노선명으로 변환
  static String _getSubwayDisplayName(dynamic subwayId) {
    final id = subwayId?.toString() ?? '';
    final lineNames = {
      '1001': '1호선',
      '1002': '2호선',
      '1003': '3호선',
      '1004': '4호선',
      '1005': '5호선',
      '1006': '6호선',
      '1007': '7호선',
      '1008': '8호선',
      '1009': '9호선',
      '1077': '신분당선',
      '1075': '분당선',
      '1063': '경의중앙선',
      '1065': '공항철도',
      '1067': '경춘선',
    };
    return lineNames[id] ?? '${id}호선';
  }

  Map<String, dynamic> toJson() {
    return {
      'statnNm': stationName,
      'subwayNm': subwayNm,
      'subwayId': subwayId,
      'updnLine': updnLine,
      'trainLineNm': trainLineNm,
      'arvlMsg2': arvlMsg2,
      'arvlMsg3': arvlMsg3,
      'arvlCd': arvlCd,
      'barvlDt': barvlDt,
      'ordkey': ordkey,
    };
  }

  /// 도착 상태 텍스트
  String get arrivalStatusText {
    switch (arvlCd) {
      case '0':
        return '진입';
      case '1':
        return '도착';
      case '2':
        return '출발';
      case '3':
        return '전역출발';
      case '4':
        return '전역진입';
      case '5':
        return '전역도착';
      default:
        return '정보없음';
    }
  }

  /// 방향 표시 (상행/하행)
  String get directionText {
    return updnLine.contains('상행') ? '상행' : '하행';
  }

  /// 노선 색상 (16진수)
  String get lineColor {
    final colors = {
      '1001': '#263C96',   // 1호선
      '1002': '#00A84D',   // 2호선
      '1003': '#EF7C1C',   // 3호선
      '1004': '#00A4E3',   // 4호선
      '1005': '#996CAC',   // 5호선
      '1006': '#CD7C2F',   // 6호선
      '1007': '#747F00',   // 7호선
      '1008': '#E6186C',   // 8호선
      '1009': '#BB8336',   // 9호선
      '1077': '#D31145',   // 신분당선
      '1075': '#FFCD12',   // 분당선
      '1063': '#77C4A3',   // 경의중앙선
      '1065': '#0090D2',   // 공항철도
      '1067': '#2FB8AD',   // 경춘선
      // 기존 1-9 호선 호환성
      '1': '#263C96', '2': '#00A84D', '3': '#EF7C1C', '4': '#00A4E3',
      '5': '#996CAC', '6': '#CD7C2F', '7': '#747F00', '8': '#E6186C', '9': '#BB8336',
    };
    return colors[subwayId] ?? '#6B7280';
  }

  /// 첫 번째 도착 시간 (분 단위 추출)
  int? get firstArrivalMinutes {
    final regex = RegExp(r'(\d+)분');
    final match = regex.firstMatch(arvlMsg2);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// 도착 메시지 정리 (더 읽기 쉽게)
  String get cleanArrivalMessage {
    if (arvlMsg2.contains('곧 도착') || arvlMsg2.contains('도착')) {
      return '곧 도착';
    }
    if (arvlMsg2.contains('분')) {
      return arvlMsg2.replaceAll('후 도착', '').trim();
    }
    return arvlMsg2;
  }

  @override
  String toString() {
    return 'SubwayArrival(station: $stationName, line: $subwayNm, direction: $directionText, arrival: $cleanArrivalMessage)';
  }
}