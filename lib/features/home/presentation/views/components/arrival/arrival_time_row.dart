import 'package:flutter/material.dart';

import '../../../../../location_search/domain/entities/subway_arrival_entity.dart';

class ArrivalTimeRow extends StatelessWidget {
  final SubwayArrivalEntity arrival;
  final bool isFirst;

  const ArrivalTimeRow({
    super.key,
    required this.arrival,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.blue[600]!;
    if (arrival.arrivalTimeText.contains('진입') || arrival.arvlCd == 0) {
      statusColor = Colors.green[600]!;
    } else if (arrival.arrivalTimeText.contains('도착') || arrival.arvlCd == 5) {
      statusColor = Colors.red[600]!;
    }

    return Row(
      children: [
        Text(
          arrival.arrivalStatusIcon,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(width: 4),

        Expanded(
          child: Text(
            arrival.arrivalTimeText,
            style: TextStyle(
              fontSize: isFirst ? 11 : 10,
              fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
              color: statusColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (arrival.btrainNo.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            arrival.btrainNo,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}