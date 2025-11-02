import 'package:commute_time_app/features/location_search/domain/entities/bus_arrival_info_entity.dart';
import 'package:flutter/material.dart';

import 'bus_arrival_time_row.dart';

class BusArrivalWidget extends StatelessWidget {
  final MaterialColor color;
  final List<BusArrivalInfoEntity> busArrivalData;

  const BusArrivalWidget({
    super.key,
    required this.color,
    required this.busArrivalData,
  });

  @override
  Widget build(BuildContext context) {
    if (busArrivalData.isEmpty) return const SizedBox.shrink();

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: busArrivalData.take(2).map((busInfo) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getBusTypeColor(busInfo.routeTypeName),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        busInfo.routeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  busInfo.routeTypeName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                BusArrivalTimeRow(busInfo: busInfo, isFirstBus: true, isFirst: true),

                if (busInfo.predictTime2 > 0) ...[
                  const SizedBox(height: 3),
                  BusArrivalTimeRow(busInfo: busInfo, isFirstBus: false, isFirst: false),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBusTypeColor(String routeTypeName) {
    switch (routeTypeName) {
      case '직행좌석': return Colors.red;
      case '좌석': return Colors.blue;
      case '일반': return Colors.green;
      case '광역급행': return Colors.purple;
      default: return Colors.grey;
    }
  }
}