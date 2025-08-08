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
              
              Obx(() {
                final routeCount = controller.routesList.length;
                return Text(
                  routeCount > 0 ? '총 ${routeCount}개의 경로가 저장되어 있습니다' : '아직 저장된 경로가 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // 경로 목록
              Obx(() => _buildRoutesList()),
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


  Widget _buildRouteItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool isEditMode = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    bool showDelete = false,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
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
        // 수정 모드일 때 버튼들 표시
        if (isEditMode) ...[
          const SizedBox(width: 8),
          // 수정 버튼
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: iconColor,
              ),
            ),
          ),
          // 삭제 버튼 (환승지만)
          if (showDelete && onDelete != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete,
                  size: 16,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildAddTransferButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF97316).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF97316).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: Color(0xFFF97316),
            ),
            SizedBox(width: 8),
            Text(
              '환승지 추가',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList() {
    if (controller.routesList.isEmpty) {
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
              '우측 하단의 + 버튼을 눌러\n새 경로를 추가해보세요',
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

    return Column(
      children: controller.routesList.map((route) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRouteCard(route),
        );
      }).toList(),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    final routeId = route['id'] ?? '';
    final routeName = route['name'] ?? '이름 없는 경로';
    final departure = route['departure'] ?? '';
    final arrival = route['arrival'] ?? '';
    final transfers = route['transfers'] as List? ?? [];
    final createdAt = route['createdAt'] as String?;
    
    DateTime? createdDate;
    if (createdAt != null) {
      try {
        createdDate = DateTime.parse(createdAt);
      } catch (e) {
        // 파싱 실패시 무시
      }
    }

    return Obx(() {
      final isEditMode = controller.editingRouteId.value == routeId;
      
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
                Expanded(
                  child: Text(
                    routeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                // 버튼들
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 적용하기/적용중 버튼 (항상 표시)
                    Obx(() {
                      final isActive = controller.isRouteActive(routeId);
                      final canApply = controller.totalRouteCount >= 2;
                      return InkWell(
                        onTap: (isActive || !canApply) ? null : () {
                          controller.applyRoute(routeId);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive 
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFF2196F3).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isActive 
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2196F3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            isActive ? '적용중' : '적용하기',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive 
                                ? const Color(0xFF10B981)
                                : const Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    
                    // 삭제 버튼 (수정 모드일 때만)
                    if (isEditMode) ...[
                      InkWell(
                        onTap: () {
                          controller.deleteRoute(routeId, routeName);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 이름 변경 버튼
                      InkWell(
                        onTap: () {
                          controller.editRouteName(routeId, routeName);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            size: 20,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 수정 버튼
                    InkWell(
                      onTap: () {
                        controller.toggleEditMode(routeId);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEditMode 
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEditMode ? Icons.check : Icons.edit_outlined,
                          size: 20,
                          color: isEditMode 
                            ? const Color(0xFF10B981)
                            : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 출발지
            if (departure.isNotEmpty) ...[
              _buildRouteItem(
                icon: Icons.location_on,
                iconColor: const Color(0xFF3B82F6),
                label: '출발지',
                value: departure,
                isEditMode: isEditMode,
                onEdit: () => controller.editRouteLocation(routeId, 'departure'),
              ),
              const SizedBox(height: 12),
            ],
            
            // 환승지들
            if (transfers.isNotEmpty) ...[
              for (int i = 0; i < transfers.length; i++) ...[
                _buildRouteItem(
                  icon: Icons.swap_horiz,
                  iconColor: const Color(0xFFF97316),
                  label: '환승지 ${i + 1}',
                  value: transfers[i]['name'] ?? '',
                  isEditMode: isEditMode,
                  onEdit: () => controller.editRouteTransfer(routeId, i),
                  onDelete: () => controller.deleteRouteTransfer(routeId, i),
                  showDelete: true,
                ),
                const SizedBox(height: 12),
              ],
            ],
            
            // 환승지 추가 버튼 (수정 모드일 때만)
            if (isEditMode && transfers.length < 3) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildAddTransferButton(() => controller.addRouteTransfer(routeId)),
              ),
            ],
            
            // 도착지
            if (arrival.isNotEmpty) ...[
              _buildRouteItem(
                icon: Icons.flag,
                iconColor: const Color(0xFF10B981),
                label: '도착지',
                value: arrival,
                isEditMode: isEditMode,
                onEdit: () => controller.editRouteLocation(routeId, 'arrival'),
              ),
            ],
          ],
        ),
      );
    });
  }
}