import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_setup_controller.dart';

// RouteType enum 정의
enum RouteType {
  departure,
  transfer,
  arrival,
}

class RouteSetupScreen extends GetView<RouteSetupController> {
  const RouteSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Get.theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
          controller.isHomeToWork.value ? '집 → 회사 경로' : '회사 → 집 경로',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        )),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: controller.cancelRouteSetup,
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.routeSetupCompleted.value 
              ? controller.completeRouteSetup 
              : null,
            child: Text(
              '완료',
              style: TextStyle(
                color: controller.routeSetupCompleted.value 
                  ? Colors.white 
                  : Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 정보 영역
            _buildInfoHeader(),
            
            // 메인 경로 설정 영역
            Expanded(
              child: _buildRouteSetupContent(),
            ),
            
            // 하단 버튼 영역
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // 상단 정보 헤더
  Widget _buildInfoHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            controller.currentStepTitle,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          )),
          
          const SizedBox(height: 12),
          
          Obx(() => Text(
            controller.currentStepDescription,
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
          )),
        ],
      ),
    );
  }

  // 경로 설정 콘텐츠 (온보딩 6단계 위젯 재사용)
  Widget _buildRouteSetupContent() {
    return _RouteSetupContentWrapper();
  }

  // 하단 버튼
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: controller.cancelRouteSetup,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 완료 버튼
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.routeSetupCompleted.value 
                ? controller.completeRouteSetup 
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.routeSetupCompleted.value 
                  ? Get.theme.primaryColor 
                  : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: controller.routeSetupCompleted.value ? 2 : 0,
              ),
              child: Text(
                '경로 저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: controller.routeSetupCompleted.value 
                    ? Colors.white 
                    : Colors.grey[500],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// 온보딩 6단계 위젯을 설정에서 사용할 수 있도록 래핑
class _RouteSetupContentWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RouteSetupController>();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필수/선택 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '출발지와 도착지는 필수입니다. 환승지는 나중에 추가할 수 있습니다.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 경로 설정 카드들
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Obx(() => _buildRouteCard(
                    icon: Icons.home,
                    title: '출발지 (필수)',
                    subtitle: controller.selectedDeparture.value.isNotEmpty
                        ? controller.selectedDeparture.value
                        : '출발하는 역 또는 정류장',
                    color: Colors.green,
                    isSelected: controller.selectedDeparture.value.isNotEmpty,
                    onTap: () => _showRouteSelection(RouteType.departure),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  Obx(() => _buildRouteCard(
                    icon: Icons.swap_horiz,
                    title: '환승지 (선택)',
                    subtitle: controller.selectedTransfers.isNotEmpty
                        ? controller.selectedTransfers.length == 1
                            ? controller.selectedTransfers.first
                            : '${controller.selectedTransfers.first} 외 ${controller.selectedTransfers.length - 1}개'
                        : '경유하는 정류장/역 (선택사항)',
                    color: Colors.orange,
                    isSelected: controller.selectedTransfers.isNotEmpty,
                    onTap: () => _showRouteSelection(RouteType.transfer),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  Obx(() => _buildRouteCard(
                    icon: Icons.business,
                    title: '도착지 (필수)',
                    subtitle: controller.selectedArrival.value.isNotEmpty
                        ? controller.selectedArrival.value
                        : '도착하는 역 또는 정류장',
                    color: Colors.blue,
                    isSelected: controller.selectedArrival.value.isNotEmpty,
                    onTap: () => _showRouteSelection(RouteType.arrival),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRouteCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.3) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  void _showRouteSelection(RouteType type) async {
    final controller = Get.find<RouteSetupController>();
    
    switch (type) {
      case RouteType.departure:
        final result = await Get.toNamed('/route-departure');
        if (result != null) {
          _updateDepartureLocation(result, controller);
          controller.checkRouteCompletion();
        }
        break;
      case RouteType.transfer:
        final result = await Get.toNamed('/route-transfer');
        if (result != null) {
          _updateTransferLocations(result, controller);
          controller.checkRouteCompletion();
        }
        break;
      case RouteType.arrival:
        final result = await Get.toNamed('/route-arrival');
        if (result != null) {
          _updateArrivalLocation(result, controller);
          controller.checkRouteCompletion();
        }
        break;
    }
  }
  
  void _updateDepartureLocation(dynamic locationData, RouteSetupController controller) {
    if (locationData != null) {
      String displayName = '';
      if (locationData.placeName != null && locationData.placeName!.isNotEmpty) {
        displayName = locationData.placeName!;
      } else {
        displayName = locationData.address;
      }
      controller.selectedDeparture.value = displayName;
    }
  }
  
  void _updateTransferLocations(dynamic transferData, RouteSetupController controller) {
    if (transferData != null && transferData is List) {
      List<String> transferNames = [];
      for (var transfer in transferData) {
        String displayName = '';
        if (transfer.placeName != null && transfer.placeName!.isNotEmpty) {
          displayName = transfer.placeName!;
        } else {
          displayName = transfer.address;
        }
        transferNames.add(displayName);
      }
      controller.selectedTransfers.value = transferNames;
    }
  }
  
  void _updateArrivalLocation(dynamic locationData, RouteSetupController controller) {
    if (locationData != null) {
      String displayName = '';
      if (locationData.placeName != null && locationData.placeName!.isNotEmpty) {
        displayName = locationData.placeName!;
      } else {
        displayName = locationData.address;
      }
      controller.selectedArrival.value = displayName;
    }
  }
}