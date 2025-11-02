import 'package:commute_time_app/features/location_search/domain/entities/bus_arrival_info_entity.dart';
import 'package:flutter/material.dart';

class BusArrivalTimeRow extends StatelessWidget {
  final BusArrivalInfoEntity busInfo;
  final bool isFirstBus;
  final bool isFirst;

  const BusArrivalTimeRow({
    super.key,
    required this.busInfo,
    required this.isFirstBus,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final predictTime = isFirstBus ? busInfo.predictTime1 : busInfo.predictTime2;
    final locationNo = isFirstBus ? busInfo.locationNo1 : busInfo.locationNo2;

    if (predictTime <= 0) return const SizedBox.shrink();

    Color statusColor = Colors.green[600]!;
    if (predictTime <= 1) {
      statusColor = Colors.red[600]!;
    } else if (predictTime <= 3) {
      statusColor = Colors.orange[600]!;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            '$predictTime분 후',
            style: TextStyle(
              fontSize: isFirst ? 11 : 10,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
              color: statusColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Text(
          '$locationNo정류장',
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}