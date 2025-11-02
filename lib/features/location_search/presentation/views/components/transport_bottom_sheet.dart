import 'package:flutter/material.dart';
import '../../../domain/entities/gyeonggi_bus_stop_entity.dart';
import '../../../domain/entities/seoul_bus_stop_entity.dart';
import 'subway_arrival_sheet.dart';
import 'gyeonggi_bus_arrival_sheet.dart';
import 'seoul_bus_arrival_sheet.dart';

/// 대중교통 도착정보 바텀시트 - 통합 진입점
class TransportBottomSheet {
  /// 지하철 도착정보 바텀시트 표시
  static void showSubwayArrival({
    required String stationName,
    required VoidCallback onClose,
    required Function(String) onSelect,
    String mode = '',
    String placeName = '',
    String lineFilter = '',
  }) {
    SubwayArrivalSheet.show(
      stationName: stationName,
      onClose: onClose,
      onSelect: onSelect,
      mode: mode,
      placeName: placeName,
      lineFilter: lineFilter,
    );
  }

  /// 경기도 버스 도착정보 바텀시트 표시
  static void showGyeonggiBusArrival({
    required GyeonggiBusStopEntity busStop,
    required VoidCallback onClose,
    required Function(GyeonggiBusStopEntity) onSelect,
    String mode = '',
  }) {
    GyeonggiBusArrivalSheet.show(
      busStop: busStop,
      onClose: onClose,
      onSelect: onSelect,
      mode: mode,
    );
  }

  /// 서울 버스 도착정보 바텀시트 표시
  static void showSeoulBusArrival({
    required SeoulBusStopEntity busStop,
    required VoidCallback onClose,
    required Function(SeoulBusStopEntity) onSelect,
    String mode = '',
  }) {
    SeoulBusArrivalSheet.show(
      busStop: busStop,
      onClose: onClose,
      onSelect: onSelect,
      mode: mode,
    );
  }
}