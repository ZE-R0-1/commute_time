import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/route_step.dart';
import '../models/transport_mode.dart';

class RouteStepCard extends StatelessWidget {
  final RouteStep step;
  final bool isLast;

  const RouteStepCard({
    super.key,
    required this.step,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 타임라인 아이콘
          Column(
            children: [
              _buildTimelineIcon(),
              if (!isLast) _buildTimelineLine(),
            ],
          ),

          const SizedBox(width: 16),

          // 오른쪽: 단계 내용
          Expanded(
            child: _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: step.mode.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: step.mode.color,
          width: 2,
        ),
        boxShadow: step.isDelayed
            ? [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Icon(
        step.mode.icon,
        color: step.mode.color,
        size: 24,
      ),
    );
  }

  Widget _buildTimelineLine() {
    return Container(
      width: 2,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: step.isDelayed
            ? Border.all(color: Colors.orange, width: 1)
            : null,
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
          // 상단: 교통수단 정보와 시간
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 교통수단 + 노선 정보
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: step.mode.backgroundColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            step.mode.displayName,
                            style: TextStyle(
                              color: step.mode.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (step.subwayLine != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: step.mode.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              step.subwayLine!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (step.busNumber != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: step.mode.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${step.busNumber}번',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 안내 메시지
                    Text(
                      step.instruction,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),

              // 소요시간
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    step.formattedDuration,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: step.isDelayed ? Colors.orange : Get.theme.primaryColor,
                    ),
                  ),
                  if (step.mode != TransportMode.walk && step.mode != TransportMode.transfer) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.formattedDistance,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // 시간 정보 (지하철/버스)
          if (step.departureTime != null && step.arrivalTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeInfo(
                    label: '출발',
                    time: step.formattedDepartureTime,
                    location: step.startLocation,
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  _buildTimeInfo(
                    label: '도착',
                    time: step.formattedArrivalTime,
                    location: step.endLocation,
                  ),
                ],
              ),
            ),
          ],

          // 환승 정보
          if (step.transferInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.transferInfo!,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 지연 정보
          if (step.isDelayed && step.delayMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.delayMessage!,
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 비용 정보 (0원이 아닌 경우만)
          if (step.cost > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${step.cost}원',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required String label,
    required String time,
    required String location,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location.length > 8 ? '${location.substring(0, 8)}...' : location,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}