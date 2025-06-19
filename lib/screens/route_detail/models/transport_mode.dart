import 'package:flutter/material.dart';

enum TransportMode {
  subway,
  bus,
  walk,
  taxi,
  transfer;

  // 아이콘 반환
  IconData get icon {
    switch (this) {
      case TransportMode.subway:
        return Icons.train;
      case TransportMode.bus:
        return Icons.directions_bus;
      case TransportMode.walk:
        return Icons.directions_walk;
      case TransportMode.taxi:
        return Icons.local_taxi;
      case TransportMode.transfer:
        return Icons.swap_horiz;
    }
  }

  // 색상 반환
  Color get color {
    switch (this) {
      case TransportMode.subway:
        return const Color(0xFF1976D2); // 파란색
      case TransportMode.bus:
        return const Color(0xFF388E3C); // 초록색
      case TransportMode.walk:
        return const Color(0xFF757575); // 회색
      case TransportMode.taxi:
        return const Color(0xFFF57C00); // 주황색
      case TransportMode.transfer:
        return const Color(0xFF7B1FA2); // 보라색
    }
  }

  // 한글 이름 반환
  String get displayName {
    switch (this) {
      case TransportMode.subway:
        return '지하철';
      case TransportMode.bus:
        return '버스';
      case TransportMode.walk:
        return '도보';
      case TransportMode.taxi:
        return '택시';
      case TransportMode.transfer:
        return '환승';
    }
  }

  // 배경색 (연한 색상)
  Color get backgroundColor {
    return color.withValues(alpha: 0.1);
  }
}