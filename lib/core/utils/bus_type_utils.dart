import 'package:flutter/material.dart';

/// 버스 노선 타입 유틸리티
class BusTypeUtils {
  /// 경기도 버스 타입별 색상 반환
  static MaterialColor getBusTypeColor(String routeTypeName) {
    switch (routeTypeName) {
      case '직행좌석':
        return Colors.purple;
      case '좌석':
        return Colors.red;
      case '일반':
        return Colors.green;
      case '광역급행':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 서울 버스 타입별 색상 반환
  static MaterialColor getSeoulBusTypeColor(String routeType) {
    switch (routeType) {
      case '1': // 간선버스 - 파란색
        return Colors.blue;
      case '2': // 광역버스 - 빨간색
        return Colors.red;
      case '3': // 지선버스 - 초록색
        return Colors.green;
      case '4': // 순환버스 - 노란색
        return Colors.amber;
      case '5': // 따릉이 셔틀
        return Colors.teal;
      case '6': // 야간버스
        return Colors.purple;
      case '7': // 공항버스
        return Colors.indigo;
      case '8': // 마을버스
        return Colors.lime;
      default:
        return Colors.grey;
    }
  }

  /// 서울 버스 타입 이름 반환
  static String getSeoulBusTypeName(String routeType) {
    switch (routeType) {
      case '1':
        return '간선버스';
      case '2':
        return '광역버스';
      case '3':
        return '지선버스';
      case '4':
        return '순환버스';
      case '5':
        return '셔틀';
      case '6':
        return '야간버스';
      case '7':
        return '공항버스';
      case '8':
        return '마을버스';
      default:
        return '일반버스';
    }
  }
}