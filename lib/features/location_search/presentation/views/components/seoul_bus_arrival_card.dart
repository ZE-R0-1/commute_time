import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/bus_type_utils.dart';
import '../../../domain/entities/seoul_bus_stop_entity.dart';
import '../../../domain/entities/seoul_bus_arrival_entity.dart';

class SeoulBusArrivalCard extends StatelessWidget {
  final SeoulBusArrivalEntity info;
  final SeoulBusStopEntity busStop;
  final String mode;
  final Function(SeoulBusStopEntity) onSelect;
  final VoidCallback onClose;

  const SeoulBusArrivalCard({
    Key? key,
    required this.info,
    required this.busStop,
    required this.mode,
    required this.onSelect,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          // 버스 노선 정보와 선택 버튼
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BusTypeUtils.getSeoulBusTypeColor(info.routeTp),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BusTypeUtils.getSeoulBusTypeName(info.routeTp),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.routeNo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (mode.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    Get.back(); // 바텀시트 닫기
                    Get.back(result: { // 온보딩 화면으로 돌아가면서 결과 전달
                      'name': '${busStop.stationNm} ${info.routeNo}번 버스',
                      'type': 'bus',
                      'lineInfo': '서울 버스정류장',
                      'code': busStop.stationId,
                      'latitude': busStop.gpsY,
                      'longitude': busStop.gpsX,
                      'routeName': info.routeNo,
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '선택',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 도착 시간 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '도착 예정',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                    ),
                    if (info.arrPrevStationCnt > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${info.arrPrevStationCnt}정류장 전',
                          style: TextStyle(fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  info.arrTimeInMinutes == 0 ? '곧 도착' : '${info.arrTimeInMinutes}분 후',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}