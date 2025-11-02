import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/subway_utils.dart';
import '../../../domain/entities/subway_arrival_entity.dart';

class SubwayArrivalCard extends StatelessWidget {
  final List<SubwayArrivalEntity> arrivals;
  final String stationName;
  final Function(String) onSelect;
  final VoidCallback onClose;

  const SubwayArrivalCard({
    Key? key,
    required this.arrivals,
    required this.stationName,
    required this.onSelect,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstArrival = arrivals.first;
    final secondArrival = arrivals.length > 1 ? arrivals[1] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 열차 노선 정보와 선택 버튼
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SubwayUtils.getLineColor(firstArrival.subwayId),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  firstArrival.lineDisplayName,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstArrival.cleanTrainLineNm,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // 선택 버튼
              GestureDetector(
                onTap: () {
                  Get.back();
                  // 역명, 호선, 방면 정보를 조합해서 전달
                  final selectedStation = '$stationName ${firstArrival.lineDisplayName} (${firstArrival.cleanTrainLineNm})';
                  onSelect(selectedStation);
                  onClose();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '선택',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 도착 예정 시간
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '첫 번째 열차',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(firstArrival.arrivalStatusIcon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              firstArrival.arrivalTimeText,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (secondArrival != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '두 번째 열차',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(secondArrival.arrivalStatusIcon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                secondArrival.arrivalTimeText,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}