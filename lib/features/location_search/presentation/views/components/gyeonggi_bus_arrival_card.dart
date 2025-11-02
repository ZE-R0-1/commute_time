import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/bus_type_utils.dart';
import '../../../domain/entities/gyeonggi_bus_stop_entity.dart';
import '../../../domain/entities/bus_arrival_info_entity.dart';

class GyeonggiBusArrivalCard extends StatelessWidget {
  final BusArrivalInfoEntity info;
  final GyeonggiBusStopEntity busStop;
  final String mode;
  final Function(GyeonggiBusStopEntity) onSelect;
  final VoidCallback onClose;

  const GyeonggiBusArrivalCard({
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
                  color: BusTypeUtils.getBusTypeColor(info.routeTypeName),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.routeTypeName,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.routeName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (mode.isNotEmpty) ...[
                GestureDetector(
                  onTap: () {
                    Get.back(); // 바텀시트 닫기
                    Get.back(result: { // 온보딩 화면으로 돌아가면서 결과 전달
                      'name': '${busStop.stationName} ${info.routeName}번 버스',
                      'type': 'bus',
                      'lineInfo': '경기도 버스정류장',
                      'code': busStop.stationId,
                      'latitude': busStop.y,
                      'longitude': busStop.x,
                      'routeName': info.routeName,
                      'routeId': info.routeId,
                      'staOrder': info.staOrder,
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
                        '첫 번째 버스',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        info.predictTime1 == 0 ? '곧 도착' : '${info.predictTime1}분 후',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                      if (info.locationNo1 > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${info.locationNo1}정류장 전',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (info.predictTime2 > 0) ...[
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
                          '두 번째 버스',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${info.predictTime2}분 후',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                        if (info.locationNo2 > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${info.locationNo2}정류장 전',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
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