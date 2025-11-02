import 'package:flutter/material.dart';

/// 지하철 유틸리티 클래스
class SubwayUtils {
  /// 호선 ID에 따른 색상 반환
  static Color getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF0052A4); // 1호선 - 파랑
      case '1002': return const Color(0xFF00A651); // 2호선 - 초록
      case '1003': return const Color(0xFFC60C30); // 3호선 - 주황
      case '1004': return const Color(0xFF0066B2); // 4호선 - 파랑
      case '1005': return const Color(0xFF996644); // 5호선 - 갈색
      case '1006': return const Color(0xFFCD7C2F); // 6호선 - 주황
      case '1007': return const Color(0xFF747F00); // 7호선 - 올리브
      case '1008': return const Color(0xFF8B4513); // 8호선 - 갈색
      case '1009': return const Color(0xFFA4A400); // 9호선 - 황색
      case '1032': return const Color(0xFF05AB5F); // GTX-A - 초록
      case '1061': return const Color(0xFF82B48C); // 중앙선 - 초록
      case '1063': return const Color(0xFF77B900); // 경의중앙선 - 연두
      case '1065': return const Color(0xFF0E4620); // 공항철도 - 진녹색
      case '1067': return const Color(0xFF00D4FF); // 경춘선 - 스카이블루
      case '1075': return const Color(0xFFEAA800); // 수인분당선 - 황색
      case '1077': return const Color(0xFFC41E3A); // 신분당선 - 빨강
      case '1081': return const Color(0xFFF39C12); // 경강선 - 주황
      case '1092': return const Color(0xFF89CCC0); // 우이신설선 - 민트
      case '1093': return const Color(0xFF6BAE29); // 서해선 - 초록
      case '1094': return const Color(0xFFF4C430); // 신림선 - 황색
      default: return Colors.grey;
    }
  }
}