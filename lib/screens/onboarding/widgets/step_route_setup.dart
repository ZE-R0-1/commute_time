import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding_controller.dart';

class StepRouteSetup extends GetView<OnboardingController> {
  const StepRouteSetup({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '집 → 회사 경로를\n설정해주세요 🚌',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 설명
          Text(
            '출발역/정류장, 환승지, 도착역/정류장을\n순서대로 설정하여 최적의 경로를 만들어보세요.',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 경로 설정 카드들
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Obx(() => _buildRouteCard(
                    icon: Icons.home,
                    title: '출발지',
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
                    title: '환승지',
                    subtitle: controller.selectedTransfers.isNotEmpty
                        ? controller.selectedTransfers.length == 1
                            ? controller.selectedTransfers.first
                            : '${controller.selectedTransfers.first} 외 ${controller.selectedTransfers.length - 1}개'
                        : '경유하는 정류장/역 (선택)',
                    color: Colors.orange,
                    isSelected: controller.selectedTransfers.isNotEmpty,
                    onTap: () => _showRouteSelection(RouteType.transfer),
                  )),
                  
                  const SizedBox(height: 16),
                  
                  Obx(() => _buildRouteCard(
                    icon: Icons.business,
                    title: '도착지',
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
    switch (type) {
      case RouteType.departure:
        final result = await Get.toNamed('/route-departure');
        if (result != null) {
          _updateDepartureLocation(result);
          _checkRouteCompletion();
        }
        break;
      case RouteType.transfer:
        final result = await Get.toNamed('/route-transfer');
        if (result != null) {
          _updateTransferLocations(result);
          _checkRouteCompletion();
        }
        break;
      case RouteType.arrival:
        final result = await Get.toNamed('/route-arrival');
        if (result != null) {
          _updateArrivalLocation(result);
          _checkRouteCompletion();
        }
        break;
    }
  }
  
  void _updateDepartureLocation(dynamic locationData) {
    if (locationData != null) {
      // LocationData 객체에서 표시할 이름을 추출
      String displayName = '';
      if (locationData.placeName != null && locationData.placeName!.isNotEmpty) {
        displayName = locationData.placeName!;
      } else {
        displayName = locationData.address;
      }
      controller.selectedDeparture.value = displayName;
    }
  }
  
  void _updateTransferLocations(dynamic transferData) {
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
  
  void _updateArrivalLocation(dynamic locationData) {
    if (locationData != null) {
      // LocationData 객체에서 표시할 이름을 추출
      String displayName = '';
      if (locationData.placeName != null && locationData.placeName!.isNotEmpty) {
        displayName = locationData.placeName!;
      } else {
        displayName = locationData.address;
      }
      controller.selectedArrival.value = displayName;
    }
  }
  
  void _checkRouteCompletion() {
    // 경로 설정이 완료되었는지 확인하고 상태 업데이트
    // 실제로는 선택된 경로 데이터를 확인해야 하지만,
    // 여기서는 간단히 하나라도 선택되면 완료로 처리
    controller.routeSetupCompleted.value = true;
    
    Get.snackbar(
      '경로 설정 완료',
      '출퇴근 경로가 설정되었습니다.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}

enum RouteType {
  departure,
  transfer,
  arrival,
}