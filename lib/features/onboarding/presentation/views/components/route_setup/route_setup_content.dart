import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/models/location_info.dart';
import 'location_card.dart';

/// 경로 설정 메인 콘텐츠 (출발지, 환승지, 도착지 선택 UI)
class RouteSetupContent extends StatelessWidget {
  final RxnString selectedDeparture;
  final Rx<LocationInfo?> selectedDepartureInfo;
  final RxList<LocationInfo> transferStations;
  final RxnString selectedArrival;
  final Rx<LocationInfo?> selectedArrivalInfo;

  const RouteSetupContent({
    super.key,
    required this.selectedDeparture,
    required this.selectedDepartureInfo,
    required this.transferStations,
    required this.selectedArrival,
    required this.selectedArrivalInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 출발지 설정 버튼 또는 선택된 출발지 카드
        Obx(() {
          if (selectedDeparture.value == null) {
            return LocationAddButton(
              label: '출발지 설정',
              color: const Color(0xFF3B82F6),
              onTap: () async {
                final result = await Get.toNamed('/location-search',
                    arguments: {'mode': 'departure', 'title': '출발지 설정'});

                if (result != null) {
                  selectedDeparture.value = result['name'];
                  selectedDepartureInfo.value = LocationInfo(
                    name: result['name'],
                    type: result['type'] ?? 'subway',
                    lineInfo: result['lineInfo'] ?? '',
                    code: result['code'] ?? '',
                    cityCode: result['cityCode'],
                    routeId: result['routeId'],
                    staOrder: result['staOrder'],
                  );
                }
              },
            );
          } else {
            return LocationCard(
              location: selectedDepartureInfo.value ??
                  LocationInfo(
                    name: selectedDeparture.value!,
                    type: 'subway',
                    lineInfo: '출발지',
                    code: '',
                  ),
              color: const Color(0xFF3B82F6),
              label: '출발지',
              onDelete: () {
                selectedDeparture.value = null;
                selectedDepartureInfo.value = null;
              },
            );
          }
        }),

        const SizedBox(height: 16),

        // 환승지들 표시
        Obx(() {
          return Column(
            children: [
              ...transferStations.asMap().entries.map((entry) {
                int index = entry.key;
                LocationInfo transfer = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LocationCard(
                    location: transfer,
                    color: const Color(0xFFF97316), // 주황색
                    label: '환승지 ${index + 1}',
                    onDelete: () => transferStations.removeAt(index),
                  ),
                );
              }),
            ],
          );
        }),

        // 환승지 추가 버튼 (주황색)
        Obx(() {
          if (transferStations.length < 3) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LocationAddButton(
                label: '환승지 추가',
                color: const Color(0xFFF97316),
                additionalInfo: '${transferStations.length}/3',
                onTap: () async {
                  final result = await Get.toNamed('/location-search',
                      arguments: {'mode': 'transfer', 'title': '환승지 추가'});

                  if (result != null) {
                    transferStations.add(LocationInfo(
                      name: result['name'],
                      type: result['type'] ?? 'subway',
                      lineInfo: result['lineInfo'] ?? '',
                      code: result['code'] ?? '',
                      cityCode: result['cityCode'],
                      routeId: result['routeId'],
                      staOrder: result['staOrder'],
                    ));
                  }
                },
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // 도착지 설정 버튼 또는 선택된 도착지 카드
        Obx(() {
          if (selectedArrival.value == null) {
            return LocationAddButton(
              label: '도착지 설정',
              color: const Color(0xFF10B981),
              onTap: () async {
                final result = await Get.toNamed('/location-search',
                    arguments: {'mode': 'arrival', 'title': '도착지 설정'});

                if (result != null) {
                  selectedArrival.value = result['name'];
                  selectedArrivalInfo.value = LocationInfo(
                    name: result['name'],
                    type: result['type'] ?? 'subway',
                    lineInfo: result['lineInfo'] ?? '',
                    code: result['code'] ?? '',
                    cityCode: result['cityCode'],
                    routeId: result['routeId'],
                    staOrder: result['staOrder'],
                  );
                }
              },
            );
          } else {
            return LocationCard(
              location: selectedArrivalInfo.value ??
                  LocationInfo(
                    name: selectedArrival.value!,
                    type: 'subway',
                    lineInfo: '도착지',
                    code: '',
                  ),
              color: const Color(0xFF10B981),
              label: '도착지',
              onDelete: () {
                selectedArrival.value = null;
                selectedArrivalInfo.value = null;
              },
            );
          }
        }),
      ],
    );
  }
}