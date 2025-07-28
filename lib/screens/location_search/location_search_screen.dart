import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'location_search_controller.dart';

class LocationSearchScreen extends GetView<LocationSearchController> {
  const LocationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchTextController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 카카오맵 영역 (전체 화면)
          _buildMapSection(),
          
          // 상단 검색창과 카테고리 필터
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchSection(searchTextController),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(TextEditingController searchController) {
    return Column(
      children: [
        // 검색창 (카카오맵 스타일)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: controller.performAddressSearch,
            decoration: InputDecoration(
              hintText: '주소, 건물명, 장소명을 입력하세요',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 22,
              ),
              suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        searchController.clear();
                        controller.performAddressSearch('');
                      },
                    )
                  : const SizedBox.shrink()),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 카테고리 필터 (카카오맵 스타일)
        Row(
          children: [
            Obx(() => _buildKakaoCategoryButton(
              '지하철역',
              0,
              controller.selectedCategory.value,
              Icons.train,
              Colors.blue,
            )),
            const SizedBox(width: 8),
            Obx(() => _buildKakaoCategoryButton(
              '버스정류장',
              1,
              controller.selectedCategory.value,
              Icons.directions_bus,
              Colors.green,
            )),
          ],
        ),
        
        // 주소검색 결과 표시
        Obx(() => controller.showSearchResults.value
            ? _buildAddressSearchResults()
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildKakaoCategoryButton(String title, int index, int selectedIndex, IconData icon, Color color) {
    bool isSelected = index == selectedIndex;
    
    return GestureDetector(
      onTap: () => controller.changeCategory(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 12,
                color: isSelected ? color : color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  '검색 결과',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          // 검색 결과 리스트
          Expanded(
            child: Obx(() => controller.addressSearchResults.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '검색 결과가 없습니다',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.addressSearchResults.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final address = controller.addressSearchResults[index];
                      return ListTile(
                        onTap: () => controller.selectAddress(address),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.place,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          address.placeName.isNotEmpty 
                              ? address.placeName 
                              : address.addressName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (address.addressName.isNotEmpty)
                              Text(
                                address.addressName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (address.roadAddressName.isNotEmpty)
                              Text(
                                address.roadAddressName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return KakaoMap(
      key: const ValueKey('location_search_map'), // 고유 키 추가
      onMapCreated: controller.onMapCreated,
      center: LatLng(37.4980, 127.0276), // 강남역 중심
      minLevel: 3,
      maxLevel: 3,
      markers: controller.markers,
      circles: controller.circles, // 검색 반경 원 추가
    );
  }

}