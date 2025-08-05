import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'route_setup_controller.dart';

class RouteSetupScreen extends GetView<RouteSetupController> {
  const RouteSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 제목
              Text(
                '저장된 출퇴근 경로',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                '온보딩에서 설정한 경로 정보입니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 경로 정보 카드
              Obx(() => _buildRouteInfoCard()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.addNewRoute();
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    // 경로 정보가 있는지 확인
    bool hasRouteData = controller.departure.value.isNotEmpty || 
                       controller.arrival.value.isNotEmpty || 
                       controller.transfers.isNotEmpty;

    if (!hasRouteData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 경로 없음',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '온보딩에서 경로를 설정하지 않았거나\n데이터가 삭제되었습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2196F3), // 파란색
                      Color(0xFF3F51B5), // 인디고색
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.route,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '출퇴근 경로',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '온보딩에서 설정됨',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // 수정 버튼
              InkWell(
                onTap: () {
                  controller.editRoute();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 출발지
          if (controller.departure.value.isNotEmpty) ...[
            _buildRouteItem(
              icon: Icons.location_on,
              iconColor: const Color(0xFF3B82F6),
              label: '출발지',
              value: controller.departure.value,
            ),
            const SizedBox(height: 12),
          ],
          
          // 환승지들
          if (controller.transfers.isNotEmpty) ...[
            for (int i = 0; i < controller.transfers.length; i++) ...[
              _buildRouteItem(
                icon: Icons.transfer_within_a_station,
                iconColor: const Color(0xFFF97316),
                label: '환승지 ${i + 1}',
                value: controller.transfers[i],
              ),
              const SizedBox(height: 12),
            ],
          ],
          
          // 도착지
          if (controller.arrival.value.isNotEmpty) ...[
            _buildRouteItem(
              icon: Icons.flag,
              iconColor: const Color(0xFF10B981),
              label: '도착지',
              value: controller.arrival.value,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}