import 'package:flutter/material.dart';

import '../arrival/real_time_arrival_info.dart';

// 역 정보 카드
class StationCard extends StatelessWidget {
  final String stationName;
  final String label;
  final IconData icon;
  final MaterialColor color;
  final bool isFirst;
  final bool isLast;

  const StationCard({
    super.key,
    required this.stationName,
    required this.label,
    required this.icon,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    if (stationName.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.shade200),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _extractStationName(stationName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.shade800,
                      ),
                    ),
                    if (_extractDirectionInfo(stationName).isNotEmpty)
                      Text(
                        _extractDirectionInfo(stationName),
                        style: TextStyle(
                          fontSize: 12,
                          color: color.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // 실시간 도착정보
              if (isFirst)
                RealTimeArrivalInfoWidget(color: color, stationType: 'departure')
              else if (!isFirst && !isLast)
                RealTimeArrivalInfoWidget(
                  color: color,
                  stationType: 'transfer',
                  stationName: stationName,
                )
              else if (isLast)
                RealTimeArrivalInfoWidget(color: color, stationType: 'destination'),
            ],
          ),
        ),
      ],
    );
  }

  String _extractStationName(String fullStationName) {
    final parts = fullStationName.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return fullStationName;
  }

  String _extractDirectionInfo(String fullStationName) {
    final cleanStationName = _extractStationName(fullStationName);
    if (fullStationName.length > cleanStationName.length) {
      return fullStationName.substring(cleanStationName.length).trim();
    }
    return '';
  }
}