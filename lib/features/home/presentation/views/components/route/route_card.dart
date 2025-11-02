import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../controllers/route_controller.dart';
import 'station_card.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final routeCtrl = Get.find<RouteController>();
    final homeCtrl = Get.find<HomeController>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (경로 제목과 설정 버튼)
          Row(
            children: [
              Icon(
                Icons.route,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Text(
                  routeCtrl.routeName.value.isEmpty ? '경로' : routeCtrl.routeName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )),
              ),
              InkWell(
                onTap: homeCtrl.refreshAllArrivalInfo,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 출발지 정보
          Obx(() => StationCard(
            stationName: routeCtrl.departureStation.value,
            label: '출발지',
            icon: Icons.train,
            color: Colors.blue,
            isFirst: true,
          )),

          // 환승지들 (있을 때만)
          Obx(() {
            if (routeCtrl.transferStations.isNotEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  ...routeCtrl.transferStations.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> transfer = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StationCard(
                        stationName: transfer['name'] ?? '',
                        label: '환승지 ${index + 1}',
                        icon: Icons.swap_horiz,
                        color: Colors.orange,
                      ),
                    );
                  }),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 8),

          // 도착지 정보
          Obx(() => StationCard(
            stationName: routeCtrl.arrivalStation.value,
            label: '도착지',
            icon: Icons.location_on,
            color: Colors.green,
            isLast: true,
          )),
        ],
      ),
    );
  }
}
