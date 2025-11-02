import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/usecases/get_bus_arrival_info_usecase.dart';
import '../../../domain/entities/gyeonggi_bus_stop_entity.dart';
import '../../../domain/entities/bus_arrival_info_entity.dart';
import 'gyeonggi_bus_arrival_card.dart';

class GyeonggiBusArrivalSheet {
  // 경기도 버스 도착정보 바텀시트
  static void show({
    required GyeonggiBusStopEntity busStop,
    required VoidCallback onClose,
    required Function(GyeonggiBusStopEntity) onSelect,
    String mode = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<BusArrivalInfoEntity> arrivals = <BusArrivalInfoEntity>[].obs;

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
              busStop.stationName,
              busStop.regionName,
              Colors.green,
              mode,
              onClose,
              () => onSelect(busStop),
              () async {
                isLoading.value = true;
                final usecase = Get.find<GetBusArrivalInfoUseCase>();
                final result = await usecase(busStop.stationId);
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
    _loadArrivalInfo(busStop.stationId, isLoading, arrivals);
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

  // 경기도 버스 내용 위젯
  static Widget _buildContent(
    bool isLoading,
    List<BusArrivalInfoEntity> arrivals,
    GyeonggiBusStopEntity busStop,
    String mode,
    Function(GyeonggiBusStopEntity) onSelect,
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
        return GyeonggiBusArrivalCard(
          info: arrivals[index],
          busStop: busStop,
          mode: mode,
          onSelect: onSelect,
          onClose: onClose,
        );
      },
    );
  }

  // 경기도 버스 도착정보 로드
  static void _loadArrivalInfo(
    String stationId,
    RxBool isLoading,
    RxList<BusArrivalInfoEntity> arrivals,
  ) async {
    isLoading.value = true;
    try {
      print('🚌 경기도 버스 도착정보 요청: $stationId');
      final usecase = Get.find<GetBusArrivalInfoUseCase>();
      final result = await usecase(stationId);
      arrivals.value = result;

      print('✅ 경기도 버스 도착정보 수신 완료: ${result.length}개');
      for (int i = 0; i < result.length; i++) {
        final arrival = result[i];
        print('  ${i + 1}. [${arrival.routeTypeName}] ${arrival.routeName}');
        print('     첫 번째: ${arrival.predictTime1 == 0 ? "곧 도착" : "${arrival.predictTime1}분 후"} (${arrival.locationNo1}정류장 전)');
        if (arrival.predictTime2 > 0) {
          print('     두 번째: ${arrival.predictTime2}분 후 (${arrival.locationNo2}정류장 전)');
        }
      }
    } catch (e) {
      print('❌ 경기도 버스 도착정보 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}