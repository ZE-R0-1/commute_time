import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/bus_type_utils.dart';
import '../../../domain/usecases/get_seoul_bus_arrival_usecase.dart';
import '../../../domain/entities/seoul_bus_stop_entity.dart';
import '../../../domain/entities/seoul_bus_arrival_entity.dart';
import 'seoul_bus_arrival_card.dart';

class SeoulBusArrivalSheet {
  // 서울 버스 도착정보 바텀시트
  static void show({
    required SeoulBusStopEntity busStop,
    required VoidCallback onClose,
    required Function(SeoulBusStopEntity) onSelect,
    String mode = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<SeoulBusArrivalEntity> arrivals = <SeoulBusArrivalEntity>[].obs;

    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            _buildBusHeader(
              busStop.stationNm,
              '${busStop.regionName} • ${busStop.stationId}',
              Colors.green,
              mode,
              onClose,
              () => onSelect(busStop),
              () async {
                isLoading.value = true;
                final usecase = Get.find<GetSeoulBusArrivalUseCase>();
                final result = await usecase(busStop.cityCode, busStop.stationId);
                arrivals.value = result;
                isLoading.value = false;
              },
            ),

            // 내용
            Expanded(
              child: Obx(() => _buildContent(isLoading.value, arrivals, busStop, mode, onSelect, onClose)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    ).then((_) => onClose());

    // 데이터 로드
    _loadArrivalInfo(busStop.cityCode, busStop.stationId, isLoading, arrivals);
  }

  // 버스 헤더 위젯
  static Widget _buildBusHeader(
    String stationName,
    String subtitle,
    MaterialColor themeColor,
    String mode,
    VoidCallback onClose,
    VoidCallback onSelect,
    VoidCallback onRefresh,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_bus, color: themeColor.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stationName,
                  style: TextStyle(
                    color: themeColor.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: themeColor.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, color: themeColor.shade600, size: 20),
            tooltip: '새로고침',
          ),
          IconButton(
            onPressed: () {
              Get.back();
              onClose();
            },
            icon: Icon(Icons.close, color: themeColor.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  // 서울 버스 내용 위젯
  static Widget _buildContent(
    bool isLoading,
    List<SeoulBusArrivalEntity> arrivals,
    SeoulBusStopEntity busStop,
    String mode,
    Function(SeoulBusStopEntity) onSelect,
    VoidCallback onClose,
  ) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('버스 도착정보를 불러오는 중...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    if (arrivals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '현재 도착 예정인 버스가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: arrivals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return SeoulBusArrivalCard(
          info: arrivals[index],
          busStop: busStop,
          mode: mode,
          onSelect: onSelect,
          onClose: onClose,
        );
      },
    );
  }

  // 서울 버스 도착정보 로드
  static void _loadArrivalInfo(
    String cityCode,
    String stationId,
    RxBool isLoading,
    RxList<SeoulBusArrivalEntity> arrivals,
  ) async {
    isLoading.value = true;
    try {
      print('🚌 서울 버스 도착정보 요청: cityCode=$cityCode, stationId=$stationId');
      final usecase = Get.find<GetSeoulBusArrivalUseCase>();
      final result = await usecase(cityCode, stationId);
      arrivals.value = result;

      print('✅ 서울 버스 도착정보 수신 완료: ${result.length}개');
      for (int i = 0; i < result.length; i++) {
        final arrival = result[i];
        final busTypeName = BusTypeUtils.getSeoulBusTypeName(arrival.routeTp);
        print('  ${i + 1}. [$busTypeName] ${arrival.routeNo}');
        print('     도착예정: ${arrival.arrTimeInMinutes == 0 ? "곧 도착 (${arrival.arrTime}초)'" : "${arrival.arrTimeInMinutes}분 후 (${arrival.arrTime}초)'"}');
        if (arrival.arrPrevStationCnt > 0) {
          print('     위치: ${arrival.arrPrevStationCnt}정류장 전');
        }
      }
    } catch (e) {
      print('❌ 서울 버스 도착정보 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}