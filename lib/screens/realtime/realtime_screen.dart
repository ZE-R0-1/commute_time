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
            color: Colors.black.withValues(alpha: 0.1),
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
              Obx(() => Text(
                controller.currentTimeText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCommuteTypeColor().withValues(alpha: 0.1),
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
                child: Obx(() {
                  if (controller.currentAddress.value == '위치를 확인하는 중...') {
                    return Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '위치를 확인하는 중...',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    controller.currentAddress.value.isEmpty 
                        ? '위치 정보 없음' 
                        : controller.currentAddress.value,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  );
                }),
              ),
              // 위치 새로고침 버튼
              IconButton(
                onPressed: controller.refreshLocation,
                icon: Icon(
                  Icons.my_location,
                  size: 18,
                  color: Colors.blue[600],
                ),
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
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
              Obx(() => Text(
                controller.commuteDirectionText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )),
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.refresh,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: '새로고침',
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
                  arrival.cleanTrainLineNm,
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
                    // 열차 종류 표시 (급행/일반/특급 등)
                    if (arrival.btrainSttus.isNotEmpty && arrival.btrainSttus != '일반')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getTrainTypeColor(arrival.btrainSttus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          arrival.btrainSttus,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (arrival.btrainSttus.isNotEmpty && arrival.btrainSttus != '일반' && arrival.isLastTrain)
                      const SizedBox(width: 4),
                    if (arrival.isLastTrain)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '막차',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // 도착 시간 및 상세 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    arrival.arrivalStatusIcon,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Obx(() => Text(
                    controller.getRealtimeArrivalTime(arrival),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getArrivalColor(arrival.arvlCd),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                arrival.detailedArrivalInfo.isNotEmpty 
                    ? arrival.detailedArrivalInfo 
                    : _cleanStatusText(arrival.btrainSttus),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.end,
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

  // 지하철 호선 색상 (수도권 전체)
  Color _getLineColor(String subwayId) {
    switch (subwayId) {
      // 서울지하철 1~9호선
      case '1001': return const Color(0xFF0052A4); // 1호선 (진파랑)
      case '1002': return const Color(0xFF00A84D); // 2호선 (초록)
      case '1003': return const Color(0xFFEF7C1C); // 3호선 (주황)
      case '1004': return const Color(0xFF00A5DE); // 4호선 (하늘)
      case '1005': return const Color(0xFF996CAC); // 5호선 (보라)
      case '1006': return const Color(0xFFCD7C2F); // 6호선 (갈색)
      case '1007': return const Color(0xFF747F00); // 7호선 (올리브)
      case '1008': return const Color(0xFFEA545D); // 8호선 (분홍)
      case '1009': return const Color(0xFFBDB092); // 9호선 (금색)
      
      // 수도권 광역철도
      case '1061': return const Color(0xFF0C8E72); // 중앙선 (청록)
      case '1063': return const Color(0xFF77C4A3); // 경의중앙선 (연청록)
      case '1065': return const Color(0xFF0090D2); // 공항철도 (진하늘)
      case '1067': return const Color(0xFF178C4B); // 경춘선 (청록)
      case '1075': return const Color(0xFFEAB026); // 수인분당선 (노랑)
      case '1077': return const Color(0xFFD31145); // 신분당선 (빨강)
      case '1092': return const Color(0xFFB7CE63); // 우이신설선 (연노랑)
      case '1093': return const Color(0xFF8FC31F); // 서해선 (연두)
      case '1081': return const Color(0xFF003DA5); // 경강선 (진파랑)
      case '1032': return const Color(0xFF9B1B7E); // GTX-A (자주)
      
      // 인천지하철
      case '1091': return const Color(0xFF759CCE); // 인천1호선 (하늘)
      case '1094': return const Color(0xFFE6A829); // 인천2호선 (주황)
      
      // 대구지하철
      case '2001': return const Color(0xFFD93F3F); // 대구1호선 (빨강)
      case '2002': return const Color(0xFF00B04F); // 대구2호선 (초록)
      case '2003': return const Color(0xFFFFB100); // 대구3호선 (노랑)
      
      // 부산지하철
      case '3001': return const Color(0xFFEC7545); // 부산1호선 (주황)
      case '3002': return const Color(0xFF81BF42); // 부산2호선 (연두)
      case '3003': return const Color(0xFFBB8C00); // 부산3호선 (갈색)
      case '3004': return const Color(0xFF217DCB); // 부산4호선 (파랑)
      
      // 광주지하철
      case '4001': return const Color(0xFF009639); // 광주1호선 (초록)
      
      // 대전지하철
      case '5001': return const Color(0xFF007448); // 대전1호선 (녹색)
      
      default: return Colors.grey; // 알 수 없는 노선
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

  // 열차 종류 색상
  Color _getTrainTypeColor(String trainType) {
    switch (trainType) {
      case '급행': return Colors.red.shade600;      // 급행
      case 'ITX': return Colors.purple.shade600;   // ITX
      case '특급': return Colors.orange.shade600;   // 특급
      case '직행': return Colors.blue.shade600;     // 직행
      default: return Colors.grey.shade600;        // 기타
    }
  }
  
  // 상태 텍스트 정리 (대괄호 제거)
  String _cleanStatusText(String statusText) {
    // [5]번째 전역 → 5번째 전역
    return statusText.replaceAll(RegExp(r'\[(\d+)\]'), r'$1');
  }
}