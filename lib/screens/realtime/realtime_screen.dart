import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'realtime_controller.dart';
import '../../app/services/subway_service.dart';

class RealtimeScreen extends GetView<RealtimeController> {
  const RealtimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 현재 상태 정보
                _buildStatusCard(),
                
                // 지하철 실시간 정보
                _buildSubwayInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 현재 상태 정보 카드
  Widget _buildStatusCard() {
    return Obx(() => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.currentTimeText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCommuteTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.commuteTypeText,
                  style: TextStyle(
                    color: _getCommuteTypeColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  controller.currentAddress.value.isEmpty 
                      ? '위치 정보 없음' 
                      : controller.currentAddress.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                controller.commuteDirectionText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // 지하철 실시간 정보
  Widget _buildSubwayInfo() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      if (!controller.hasSubwayData) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.train_outlined,
                color: Colors.grey.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '지하철 정보를 불러오는 중입니다...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // 지하철역 정보
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.train,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${controller.currentStation.value}역',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '실시간 정보',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 지하철 도착 정보 리스트
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.subwayArrivals.length,
            itemBuilder: (context, index) {
              final arrival = controller.subwayArrivals[index];
              return _buildSubwayArrivalCard(arrival);
            },
          ),
        ],
      );
    });
  }

  // 지하철 도착 정보 카드
  Widget _buildSubwayArrivalCard(SubwayArrival arrival) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: _getLineColor(arrival.subwayId),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              arrival.lineDisplayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // 열차 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arrival.trainLineNm,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      arrival.directionText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (arrival.isLastTrain)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '막차',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // 도착 시간
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                arrival.arrivalTimeText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getArrivalColor(arrival.arvlCd),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                arrival.btrainSttus,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // 출퇴근 시간대 색상
  Color _getCommuteTypeColor() {
    switch (controller.commuteType.value) {
      case CommuteType.toWork:
        return Colors.blue;
      case CommuteType.toHome:
        return Colors.green;
      case CommuteType.none:
        return Colors.grey;
    }
  }

  // 지하철 호선 색상
  Color _getLineColor(String subwayId) {
    switch (subwayId) {
      case '1001': return const Color(0xFF0052A4); // 1호선
      case '1002': return const Color(0xFF00A84D); // 2호선
      case '1003': return const Color(0xFFEF7C1C); // 3호선
      case '1004': return const Color(0xFF00A5DE); // 4호선
      case '1005': return const Color(0xFF996CAC); // 5호선
      case '1006': return const Color(0xFFCD7C2F); // 6호선
      case '1007': return const Color(0xFF747F00); // 7호선
      case '1008': return const Color(0xFFEA545D); // 8호선
      case '1009': return const Color(0xFFBDB092); // 9호선
      default: return Colors.grey;
    }
  }

  // 도착 상태 색상
  Color _getArrivalColor(int arvlCd) {
    switch (arvlCd) {
      case 0: return Colors.red;        // 진입
      case 1: return Colors.orange;     // 도착
      case 2: return Colors.green;      // 출발
      case 3: return Colors.blue;       // 전역출발
      case 4: return Colors.purple;     // 전역진입
      case 5: return Colors.orange;     // 전역도착
      case 99: return Colors.grey;      // 운행중
      default: return Colors.black;
    }
  }
}