import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'map_selection_controller.dart';

class MapSelectionScreen extends GetView<MapSelectionController> {
  const MapSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          controller.title.value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        )),
        centerTitle: true,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.selectedLocation.value != null
                ? controller.confirmSelection
                : null,
            child: Text(
              '선택',
              style: TextStyle(
                color: controller.selectedLocation.value != null
                    ? Get.theme.primaryColor
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: Stack(
        children: [
          // 지도 영역
          _buildMapArea(),
          
          // 상단 검색바
          _buildSearchBar(),
          
          // 하단 선택된 위치 정보
          _buildSelectedLocationInfo(),
          
          // 근처 정류장 목록
          _buildNearbyStations(),
        ],
      ),
    );
  }
  
  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // 지도 플레이스홀더
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '지도 영역',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '여기에 실제 지도가 표시됩니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // 중앙 마커
          const Center(
            child: Icon(
              Icons.location_on,
              size: 48,
              color: Colors.red,
            ),
          ),
          
          // 지도 제어 버튼들
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildMapControlButton(
                  icon: Icons.my_location,
                  onTap: controller.moveToCurrentLocation,
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.add,
                  onTap: controller.zoomIn,
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove,
                  onTap: controller.zoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: '역명 또는 정류장명으로 검색',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            
            // 검색 결과
            Obx(() {
              if (controller.isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (controller.searchResults.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.searchResults.length.clamp(0, 3),
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(
                        result,
                        style: const TextStyle(fontSize: 14),
                      ),
                      onTap: () => controller.moveToSearchResult(result),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedLocationInfo() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Obx(() {
        if (controller.selectedLocation.value == null) {
          return const SizedBox.shrink();
        }
        
        final location = controller.selectedLocation.value!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                children: [
                  Icon(
                    Icons.location_on,
                    color: Get.theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '선택된 위치',
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                location.placeName ?? location.address,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              if (location.placeName != null) ...[
                const SizedBox(height: 4),
                Text(
                  location.address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildNearbyStations() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // 제목
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '근처 역/정류장',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 정류장 목록
              Expanded(
                child: Obx(() {
                  if (controller.nearbyStations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_bus,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '근처 역/정류장을 검색 중입니다',
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
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.nearbyStations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final station = controller.nearbyStations[index];
                      return _buildStationCard(station);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStationCard(NearbyStation station) {
    return GestureDetector(
      onTap: () => controller.selectStation(station),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                station.type == 'bus' ? Icons.directions_bus : Icons.train,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${station.distance}m • ${station.type == 'bus' ? '버스정류장' : '지하철역'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
}