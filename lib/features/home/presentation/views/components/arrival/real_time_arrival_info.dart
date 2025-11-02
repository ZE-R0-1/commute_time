import 'package:commute_time_app/features/location_search/domain/entities/bus_arrival_info_entity.dart';
import 'package:commute_time_app/features/location_search/domain/entities/seoul_bus_arrival_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../location_search/domain/entities/subway_arrival_entity.dart';
import '../../../controllers/arrival_controller.dart';
import '../../../controllers/route_controller.dart';
import 'subway_arrival_widget.dart';
import 'bus_arrival_widget.dart';
import 'seoul_bus_arrival_widget.dart';

class RealTimeArrivalInfoWidget extends StatelessWidget {
  final MaterialColor color;
  final String stationType;
  final String? stationName;
  final int? transferIndex;

  const RealTimeArrivalInfoWidget({
    super.key,
    required this.color,
    required this.stationType,
    this.stationName,
    this.transferIndex,
  });

  @override
  Widget build(BuildContext context) {
    final arrivalCtrl = Get.find<ArrivalController>();

    // transfer 타입일 때 stationName으로 index 찾기
    int? actualTransferIndex = transferIndex;
    if (stationType == 'transfer' && stationName != null && actualTransferIndex == null) {
      final routeCtrl = Get.find<RouteController>();
      for (int i = 0; i < routeCtrl.transferStations.length; i++) {
        if (routeCtrl.transferStations[i]['name'] == stationName) {
          actualTransferIndex = i;
          break;
        }
      }
    }

    // Obx로 래핑하여 반응적 업데이트 구현
    return Obx(() {
      // 로딩 상태 확인
      bool isLoading = false;
      String errorMessage = '';
      List<SubwayArrivalEntity> subwayArrivalData = [];
      List<BusArrivalInfoEntity> busArrivalData = [];
      List<SeoulBusArrivalEntity> seoulBusArrivalData = [];

      switch (stationType) {
        case 'departure':
          isLoading = arrivalCtrl.isLoadingArrival.value;
          errorMessage = arrivalCtrl.arrivalError.value;
          subwayArrivalData = arrivalCtrl.departureArrivalInfo;
          busArrivalData = arrivalCtrl.departureBusArrivalInfo;
          seoulBusArrivalData = arrivalCtrl.departureSeoulBusArrivalInfo;
          break;
        case 'transfer':
          if (actualTransferIndex != null) {
            isLoading = arrivalCtrl.isLoadingTransferArrival.value;
            errorMessage = arrivalCtrl.transferArrivalError.value;

            if (actualTransferIndex < arrivalCtrl.transferArrivalInfo.length) {
              subwayArrivalData = arrivalCtrl.transferArrivalInfo[actualTransferIndex];
            }

            if (actualTransferIndex < arrivalCtrl.transferBusArrivalInfo.length) {
              busArrivalData = arrivalCtrl.transferBusArrivalInfo[actualTransferIndex];
            }

            if (actualTransferIndex < arrivalCtrl.transferSeoulBusArrivalInfo.length) {
              seoulBusArrivalData = arrivalCtrl.transferSeoulBusArrivalInfo[actualTransferIndex];
            }
          }
          break;
        case 'destination':
          isLoading = arrivalCtrl.isLoadingDestinationArrival.value;
          errorMessage = arrivalCtrl.destinationArrivalError.value;
          subwayArrivalData = arrivalCtrl.destinationArrivalInfo;
          busArrivalData = arrivalCtrl.destinationBusArrivalInfo;
          seoulBusArrivalData = arrivalCtrl.destinationSeoulBusArrivalInfo;
          break;
      }

      if (isLoading) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      }

      if (errorMessage.isNotEmpty) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '정보없음',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      bool hasSubwayData = subwayArrivalData.isNotEmpty;
      bool hasBusData = busArrivalData.isNotEmpty;
      bool hasSeoulBusData = seoulBusArrivalData.isNotEmpty;

      if (!hasSubwayData && !hasBusData && !hasSeoulBusData) {
        return const SizedBox.shrink();
      }

      if (hasSeoulBusData) {
        return SeoulBusArrivalWidget(color: color, seoulBusArrivalData: seoulBusArrivalData);
      }

      if (hasBusData) {
        return BusArrivalWidget(color: color, busArrivalData: busArrivalData);
      }

      if (hasSubwayData) {
        return SubwayArrivalWidget(color: color, subwayArrivalData: subwayArrivalData);
      }

      return const SizedBox.shrink();
    });
  }
}