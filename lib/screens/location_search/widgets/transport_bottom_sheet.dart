import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/services/bus_search_service.dart';
import '../../../app/services/seoul_bus_service.dart';
import '../../../app/services/subway_search_service.dart';
import '../../../app/services/subway_service.dart';
import '../../../app/services/gyeonggi_bus_service.dart';
import '../../../app/services/bus_arrival_service.dart';

class TransportBottomSheet {
  // 지하철 도착정보 바텀시트
  static void showSubwayArrival({
    required String stationName,
    required VoidCallback onClose,
    required Function(String) onSelect,
    String mode = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<SubwayArrival> arrivals = <SubwayArrival>[].obs;
    final RxString errorMessage = ''.obs;

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
            _buildSubwayHeader(stationName, mode, onClose, onSelect, () async {
              isLoading.value = true;
              errorMessage.value = '';
              try {
                final result = await SubwaySearchService.getArrivalInfo(stationName);
                arrivals.value = result;
              } catch (e) {
                errorMessage.value = '도착정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';
              } finally {
                isLoading.value = false;
              }
            }),
            
            // 내용
            Expanded(
              child: Obx(() => _buildSubwayContent(isLoading.value, arrivals, errorMessage.value, stationName)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    ).then((_) => onClose());

    // 데이터 로드
    _loadSubwayArrivalInfo(stationName, isLoading, arrivals, errorMessage);
  }

  // 경기도 버스 도착정보 바텀시트
  static void showGyeonggiBusArrival({
    required GyeonggiBusStop busStop,
    required VoidCallback onClose,
    required Function(GyeonggiBusStop) onSelect,
    String mode = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<BusArrivalInfo> arrivals = <BusArrivalInfo>[].obs;

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
                final result = await BusSearchService.getGyeonggiBusArrivalInfo(busStop.stationId);
                arrivals.value = result;
                isLoading.value = false;
              },
            ),
            
            // 내용
            Expanded(
              child: Obx(() => _buildBusContent(isLoading.value, arrivals, [])),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    ).then((_) => onClose());

    // 데이터 로드
    _loadGyeonggiBusArrivalInfo(busStop.stationId, isLoading, arrivals);
  }

  // 서울 버스 도착정보 바텀시트
  static void showSeoulBusArrival({
    required SeoulBusStop busStop,
    required VoidCallback onClose,
    required Function(SeoulBusStop) onSelect,
    String mode = '',
  }) {
    final RxBool isLoading = true.obs;
    final RxList<SeoulBusArrival> arrivals = <SeoulBusArrival>[].obs;

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
                final result = await BusSearchService.getSeoulBusArrivalInfo(busStop.stationId);
                arrivals.value = result;
                isLoading.value = false;
              },
            ),
            
            // 내용
            Expanded(
              child: Obx(() => _buildBusContent(isLoading.value, [], arrivals)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    ).then((_) => onClose());

    // 데이터 로드
    _loadSeoulBusArrivalInfo(busStop.stationId, isLoading, arrivals);
  }

  // 지하철 헤더 위젯
  static Widget _buildSubwayHeader(
    String stationName,
    String mode,
    VoidCallback onClose,
    Function(String) onSelect,
    VoidCallback onRefresh,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.train, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${stationName}역',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, color: Colors.blue.shade600, size: 20),
            tooltip: '새로고침',
          ),
          if (mode.isNotEmpty) ...[
            IconButton(
              onPressed: () {
                Get.back();
                onSelect(stationName);
              },
              icon: Icon(Icons.check, color: Colors.blue.shade600, size: 20),
              tooltip: '이 역 선택',
            ),
          ],
          IconButton(
            onPressed: () {
              Get.back();
              onClose();
            },
            icon: Icon(Icons.close, color: Colors.blue.shade600, size: 20),
          ),
        ],
      ),
    );
  }

  // 버스 헤더 위젯 (지하철 헤더 스타일 적용)
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
          if (mode.isNotEmpty) ...[
            IconButton(
              onPressed: () {
                Get.back();
                onSelect();
              },
              icon: Icon(Icons.check, color: themeColor.shade600, size: 20),
              tooltip: '이 정류장 선택',
            ),
          ],
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

  // 지하철 내용 위젯
  static Widget _buildSubwayContent(
    bool isLoading,
    RxList<SubwayArrival> arrivals,
    String errorMessage,
    String stationName,
  ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (arrivals.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.train_outlined, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              '현재 도착 정보가 없습니다',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: arrivals.length,
      itemBuilder: (context, index) => _buildSubwayArrivalCard(arrivals[index]),
    );
  }

  // 버스 내용 위젯
  static Widget _buildBusContent(
    bool isLoading,
    List<BusArrivalInfo> gyeonggiArrivals,
    List<SeoulBusArrival> seoulArrivals,
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

    if (gyeonggiArrivals.isEmpty && seoulArrivals.isEmpty) {
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
      itemCount: gyeonggiArrivals.length + seoulArrivals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index < gyeonggiArrivals.length) {
          return _buildBusArrivalCard(gyeonggiArrivals[index]);
        } else {
          return _buildSeoulBusArrivalCard(seoulArrivals[index - gyeonggiArrivals.length]);
        }
      },
    );
  }

  // 지하철 도착정보 카드
  static Widget _buildSubwayArrivalCard(SubwayArrival arrival) {
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
      child: Row(
        children: [
          // 호선 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SubwaySearchService.getLineColor(arrival.subwayId),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              arrival.lineDisplayName,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          
          // 열차 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arrival.cleanTrainLineNm,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  arrival.directionText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // 도착 시간
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(arrival.arrivalStatusIcon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    arrival.arrivalTimeText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SubwaySearchService.getArrivalColor(arrival.arvlCd),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 경기도 버스 도착정보 카드
  static Widget _buildBusArrivalCard(BusArrivalInfo info) {
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
          // 버스 노선 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BusSearchService.getBusTypeColor(info.routeTypeName),
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

  // 서울 버스 도착정보 카드
  static Widget _buildSeoulBusArrivalCard(SeoulBusArrival info) {
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
          // 버스 노선 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: BusSearchService.getSeoulBusTypeColor(info.routeTp),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  BusSearchService.getSeoulBusTypeName(info.routeTp),
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

  // 지하철 도착정보 로드
  static void _loadSubwayArrivalInfo(
    String stationName,
    RxBool isLoading,
    RxList<SubwayArrival> arrivals,
    RxString errorMessage,
  ) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await SubwaySearchService.getArrivalInfo(stationName);
      arrivals.value = result;
    } catch (e) {
      errorMessage.value = '도착정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';
    } finally {
      isLoading.value = false;
    }
  }

  // 경기도 버스 도착정보 로드
  static void _loadGyeonggiBusArrivalInfo(
    String stationId,
    RxBool isLoading,
    RxList<BusArrivalInfo> arrivals,
  ) async {
    isLoading.value = true;
    try {
      final result = await BusSearchService.getGyeonggiBusArrivalInfo(stationId);
      arrivals.value = result;
    } catch (e) {
      print('❌ 경기도 버스 도착정보 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 서울 버스 도착정보 로드
  static void _loadSeoulBusArrivalInfo(
    String stationId,
    RxBool isLoading,
    RxList<SeoulBusArrival> arrivals,
  ) async {
    isLoading.value = true;
    try {
      final result = await BusSearchService.getSeoulBusArrivalInfo(stationId);
      arrivals.value = result;
    } catch (e) {
      print('❌ 서울 버스 도착정보 로드 실패: $e');
    } finally {
      isLoading.value = false;
    }
  }
}