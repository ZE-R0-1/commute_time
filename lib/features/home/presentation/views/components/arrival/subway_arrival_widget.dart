import 'package:flutter/material.dart';

import '../../../../../location_search/domain/entities/subway_arrival_entity.dart';
import 'arrival_time_row.dart';

class SubwayArrivalWidget extends StatelessWidget {
  final MaterialColor color;
  final List<SubwayArrivalEntity> subwayArrivalData;

  const SubwayArrivalWidget({
    super.key,
    required this.color,
    required this.subwayArrivalData,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<SubwayArrivalEntity>> groupedByDirection = {};
    for (final arrival in subwayArrivalData) {
      final key = '${arrival.lineDisplayName}_${arrival.cleanTrainLineNm}';
      if (!groupedByDirection.containsKey(key)) {
        groupedByDirection[key] = [];
      }
      groupedByDirection[key]!.add(arrival);
    }

    if (groupedByDirection.isEmpty) {
      return const SizedBox.shrink();
    }

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
        children: groupedByDirection.entries.take(2).map((directionEntry) {
          final arrivals = directionEntry.value.take(2).toList();
          final firstArrival = arrivals.first;
          final secondArrival = arrivals.length > 1 ? arrivals[1] : null;

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
                        color: _getLineColor(firstArrival.subwayId),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        firstArrival.lineDisplayName,
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
                  firstArrival.cleanTrainLineNm,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                ArrivalTimeRow(arrival: firstArrival, isFirst: true),

                if (secondArrival != null) ...[
                  const SizedBox(height: 3),
                  ArrivalTimeRow(arrival: secondArrival, isFirst: false),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF263C96);
      case '1002': return const Color(0xFF00A84D);
      case '1003': return const Color(0xFFEF7C1C);
      case '1004': return const Color(0xFF00A5DE);
      case '1005': return const Color(0xFF996CAC);
      case '1006': return const Color(0xFFCD7C2F);
      case '1007': return const Color(0xFF747F00);
      case '1008': return const Color(0xFFE6186C);
      case '1009': return const Color(0xFFBB8336);
      case '1063': return const Color(0xFF77C4A3);
      case '1065': return const Color(0xFF0090D2);
      case '1067': return const Color(0xFFF5A200);
      case '1075': return const Color(0xFF32C6A6);
      case '1077': return const Color(0xFFB7CE63);
      case '1092': return const Color(0xFF6789CA);
      default: return Colors.grey;
    }
  }
}