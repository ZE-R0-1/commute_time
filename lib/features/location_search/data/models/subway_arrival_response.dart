import '../../domain/entities/subway_arrival_entity.dart';

/// 지하철 도착정보 API 응답 모델
class SubwayArrivalResponse {
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

  SubwayArrivalResponse({
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

  factory SubwayArrivalResponse.fromJson(Map<String, dynamic> json) {
    return SubwayArrivalResponse(
      subwayId: json['subwayId'] as String? ?? '',
      updnLine: json['updnLine'] as String? ?? '',
      trainLineNm: json['trainLineNm'] as String? ?? '',
      statnNm: json['statnNm'] as String? ?? '',
      btrainSttus: json['btrainSttus'] as String? ?? '',
      barvlDt: (json['barvlDt'] is int) ? json['barvlDt'] : int.parse(json['barvlDt'].toString()),
      btrainNo: json['btrainNo'] as String? ?? '',
      bstatnNm: json['bstatnNm'] as String? ?? '',
      arvlMsg2: json['arvlMsg2'] as String? ?? '',
      arvlMsg3: json['arvlMsg3'] as String? ?? '',
      arvlCd: (json['arvlCd'] is int) ? json['arvlCd'] : int.parse(json['arvlCd'].toString()),
      lstcarAt: (json['lstcarAt'] is int) ? json['lstcarAt'] : int.parse(json['lstcarAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'subwayId': subwayId,
    'updnLine': updnLine,
    'trainLineNm': trainLineNm,
    'statnNm': statnNm,
    'btrainSttus': btrainSttus,
    'barvlDt': barvlDt,
    'btrainNo': btrainNo,
    'bstatnNm': bstatnNm,
    'arvlMsg2': arvlMsg2,
    'arvlMsg3': arvlMsg3,
    'arvlCd': arvlCd,
    'lstcarAt': lstcarAt,
  };

  /// 도메인 엔티티로 변환
  SubwayArrivalEntity toEntity() {
    return SubwayArrivalEntity(
      subwayId: subwayId,
      updnLine: updnLine,
      trainLineNm: trainLineNm,
      statnNm: statnNm,
      btrainSttus: btrainSttus,
      barvlDt: barvlDt,
      btrainNo: btrainNo,
      bstatnNm: bstatnNm,
      arvlMsg2: arvlMsg2,
      arvlMsg3: arvlMsg3,
      arvlCd: arvlCd,
      lstcarAt: lstcarAt,
    );
  }
}