import 'package:flutter/material.dart';
import '../../../../../../../core/utils/bus_type_utils.dart';
import '../../../../../location_search/domain/entities/seoul_bus_arrival_entity.dart';

class SeoulBusArrivalWidget extends StatelessWidget {
  final MaterialColor color;
  final List<SeoulBusArrivalEntity> seoulBusArrivalData;

  const SeoulBusArrivalWidget({
    super.key,
    required this.color,
    required this.seoulBusArrivalData,
  });

  @override
  Widget build(BuildContext context) {
    if (seoulBusArrivalData.isEmpty) return const SizedBox.shrink();

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
        children: seoulBusArrivalData.take(2).map((busInfo) {
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
                        color: BusTypeUtils.getSeoulBusTypeColor(busInfo.routeTp),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        busInfo.routeNo,
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
                  busInfo.routeTp,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${busInfo.arrTimeInMinutes}분 후',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Text(
                  '${busInfo.arrPrevStationCnt}정류장 전',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}