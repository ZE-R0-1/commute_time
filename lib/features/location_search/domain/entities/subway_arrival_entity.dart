import 'package:equatable/equatable.dart';

/// 지하철 도착 정보 도메인 엔티티
class SubwayArrivalEntity extends Equatable {
  final String subwayId;
  final String updnLine;
  final String trainLineNm;
  final String statnNm;
  final String btrainSttus;
  final int barvlDt;
  final String btrainNo;
  final String bstatnNm;
  final String arvlMsg2;
  final String arvlMsg3;
  final int arvlCd;
  final int lstcarAt;

  const SubwayArrivalEntity({
    required this.subwayId,
    required this.updnLine,
    required this.trainLineNm,
    required this.statnNm,
    required this.btrainSttus,
    required this.barvlDt,
    required this.btrainNo,
    required this.bstatnNm,
    required this.arvlMsg2,
    required this.arvlMsg3,
    required this.arvlCd,
    required this.lstcarAt,
  });

  @override
  List<Object?> get props => [
    subwayId,
    updnLine,
    trainLineNm,
    statnNm,
    btrainSttus,
    barvlDt,
    btrainNo,
    bstatnNm,
    arvlMsg2,
    arvlMsg3,
    arvlCd,
    lstcarAt,
  ];

  /// 지하철 호선 번호를 한글로 변환
  String get lineDisplayName {
    switch (subwayId) {
      case '1001': return '1호선';
      case '1002': return '2호선';
      case '1003': return '3호선';
      case '1004': return '4호선';
      case '1005': return '5호선';
      case '1006': return '6호선';
      case '1007': return '7호선';
      case '1008': return '8호선';
      case '1009': return '9호선';
      case '1032': return 'GTX-A';
      case '1061': return '중앙선';
      case '1063': return '경의중앙선';
      case '1065': return '공항철도';
      case '1067': return '경춘선';
      case '1075': return '수인분당선';
      case '1077': return '신분당선';
      case '1081': return '경강선';
      case '1092': return '우이신설선';
      case '1093': return '서해선';
      case '1094': return '신림선';
      default: return '알 수 없음';
    }
  }

  /// 대괄호 제거된 깔끔한 행선지명
  String get cleanTrainLineNm {
    String cleaned = trainLineNm;
    cleaned = cleaned.replaceAll(RegExp(r'\[(\d+)\]번째'), r'$1번째');

    if (cleaned.contains('도착') || cleaned.contains('진입') || cleaned.contains('출발')) {
      final parts = cleaned.split(' ');
      if (parts.isNotEmpty && !parts[0].endsWith('역')) {
        parts[0] = parts[0] + '역';
        cleaned = parts.join(' ');
      }
    }

    return cleaned.trim();
  }

  /// 도착 시간 텍스트
  String get arrivalTimeText {
    if (barvlDt == 0) {
      return arvlMsg2;
    } else {
      final minutes = (barvlDt / 60).floor();
      final seconds = barvlDt % 60;
      return '${minutes}분 ${seconds}초';
    }
  }

  /// 상하행 표시
  String get directionText {
    return updnLine == '0' ? '상행' : '하행';
  }

  /// 막차 여부
  bool get isLastTrain {
    return lstcarAt == 1;
  }

  /// 도착 상태 아이콘
  String get arrivalStatusIcon {
    switch (arvlCd) {
      case 0: return '🚇'; // 진입
      case 1: return '🔵'; // 도착
      case 2: return '🟢'; // 출발
      case 3: return '⚪'; // 전역출발
      case 4: return '🟡'; // 전역진입
      case 5: return '🔵'; // 전역도착
      case 99: return '🚆'; // 운행중
      default: return '⚫';
    }
  }

  /// 상세한 도착 정보
  String get detailedArrivalInfo {
    if (arvlMsg2.isEmpty && arvlMsg3.isEmpty) {
      return '';
    }

    if (arvlMsg2.contains('도착') || arvlMsg2.contains('진입') || arvlMsg2.contains('출발')) {
      return arvlMsg2;
    }

    if (arvlMsg3.isNotEmpty && arvlMsg3 != statnNm) {
      return '$arvlMsg3 $arvlMsg2';
    }

    return arvlMsg2.isNotEmpty ? arvlMsg2 : arvlMsg3;
  }
}