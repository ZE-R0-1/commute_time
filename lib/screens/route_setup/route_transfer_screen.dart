import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_transfer_controller.dart';

class RouteTransferScreen extends GetView<RouteTransferController> {
  const RouteTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '환승지 선택',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.transferLocations.isNotEmpty
                ? () => Get.back(result: controller.transferLocations.toList())
                : null,
            child: Text(
              '완료',
              style: TextStyle(
                color: controller.transferLocations.isNotEmpty
                    ? Get.theme.primaryColor
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            _buildSelectedTransfers(),
            _buildRecentSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addFromMap,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '환승지를 선택하세요',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '경유할 정류장이나 역을 여러 개 선택할 수 있습니다',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 팁 카드
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
                  Icons.lightbulb_outline,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '환승지는 선택사항입니다. 필요한 경우에만 추가하세요.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 검색 입력 필드
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: '정류장이나 역 이름으로 검색',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 검색 결과
          Obx(() {
            if (controller.isSearching.value) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (controller.searchResults.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final result = controller.searchResults[index];
                  final isSelected = controller.isLocationSelected(result);
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.location_on,
                      color: isSelected ? Colors.green : Colors.grey,
                    ),
                    title: Text(
                      result,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.add, color: Colors.grey),
                    onTap: isSelected ? null : () => controller.addTransferLocation(result),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  
  Widget _buildSelectedTransfers() {
    return Obx(() {
      if (controller.transferLocations.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '선택된 환승지',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.transferLocations.length}개',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.transferLocations.length,
                onReorder: controller.reorderTransferLocations,
                itemBuilder: (context, index) {
                  final location = controller.transferLocations[index];
                  return _buildTransferItem(location, index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildTransferItem(TransferLocation location, int index) {
    return Container(
      key: ValueKey(location.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          location.placeName ?? location.address,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: location.placeName != null
            ? Text(
                location.address,
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_handle,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.removeTransferLocation(location),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최근 환승지',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Obx(() {
                if (controller.recentTransferLocations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.transfer_within_a_station,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '최근 사용한 환승지가 없습니다',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  itemCount: controller.recentTransferLocations.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final location = controller.recentTransferLocations[index];
                    final isSelected = controller.isLocationSelectedByAddress(location.address);
                    
                    return _buildRecentLocationCard(location, isSelected);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentLocationCard(TransferLocation location, bool isSelected) {
    return GestureDetector(
      onTap: isSelected ? null : () => controller.addRecentTransferLocation(location),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.transfer_within_a_station,
              color: isSelected ? Colors.green : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.placeName ?? location.address,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: isSelected ? Colors.grey : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location.placeName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      location.address,
                      style: TextStyle(
                        color: isSelected ? Colors.grey : Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Colors.green)
            else
              const Icon(Icons.add, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}