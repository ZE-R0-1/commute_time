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
            '출발지와 도착지를 필수로 설정해주세요.\n환승지는 선택사항입니다.',
            style: Get.textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 48),
          
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
    // 출발지와 도착지가 모두 선택되었는지 확인
    final hasDepature = controller.selectedDeparture.value.isNotEmpty;
    final hasArrival = controller.selectedArrival.value.isNotEmpty;
    
    if (hasDepature && hasArrival) {
      controller.routeSetupCompleted.value = true;
      
      Get.snackbar(
        '필수 경로 설정 완료',
        '출발지와 도착지가 설정되었습니다! 이제 온보딩을 완료할 수 있습니다.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green[700],
      );
    } else {
      controller.routeSetupCompleted.value = false;
    }
  }
}

enum RouteType {
  departure,
  transfer,
  arrival,
}