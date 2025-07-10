import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_departure_controller.dart';

class RouteDepartureScreen extends GetView<RouteDepartureController> {
  const RouteDepartureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            '출발지 선택',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Get.theme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Get.theme.primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.train),
                text: '지하철역',
              ),
              Tab(
                icon: Icon(Icons.directions_bus),
                text: '버스정류장',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SubwayStationTab(),
            _BusStopTab(),
          ],
        ),
      ),
    );
  }
}

/// 지하철역 검색 탭
class _SubwayStationTab extends GetView<RouteDepartureController> {
  const _SubwayStationTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildSubwayHeader(),
          _buildSubwaySearchSection(),
          _buildSubwayRecentSection(),
        ],
      ),
    );
  }

  Widget _buildSubwayHeader() {
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.train,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '출발할 지하철역을 선택하세요',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '역명을 입력하여 검색해주세요',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubwaySearchSection() {
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
              controller: controller.subwaySearchController,
              onChanged: controller.onSubwaySearchChanged,
              decoration: InputDecoration(
                hintText: '역명으로 검색 (예: 강남역, 홍대입구역)',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.train, color: Colors.grey[500]),
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
            if (controller.isSubwaySearching.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (controller.subwaySearchResults.isEmpty) {
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
                itemCount: controller.subwaySearchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final station = controller.subwaySearchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.train, color: Colors.blue),
                    title: Text(
                      station.stationName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      station.displayAddress,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: station.distanceText.isNotEmpty
                        ? Text(
                            station.distanceText,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          )
                        : null,
                    onTap: () => controller.selectSubwayStation(station),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubwayRecentSection() {
    return const Expanded(
      child: SizedBox.shrink(),
    );
  }
}

/// 버스정류장 선택 탭
class _BusStopTab extends GetView<RouteDepartureController> {
  const _BusStopTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildBusStopHeader(),
          _buildBusStopOptions(),
          _buildBusStopRecentSection(),
        ],
      ),
    );
  }

  Widget _buildBusStopHeader() {
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
                  Icons.directions_bus,
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
                      '출발할 버스정류장을 선택하세요',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '주소 검색 또는 지도에서 선택해주세요',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopOptions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '정류장 선택 방법',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // 주소로 검색
          _buildBusStopOptionCard(
            icon: Icons.search,
            title: '주소로 검색',
            subtitle: '주소나 건물명으로 근처 정류장 찾기',
            color: Colors.green,
            onTap: controller.searchByAddress,
          ),
          
          const SizedBox(height: 12),
          
          // 지도에서 선택
          _buildBusStopOptionCard(
            icon: Icons.map,
            title: '지도에서 선택',
            subtitle: '지도를 보며 정류장 위치 선택',
            color: Colors.orange,
            onTap: controller.selectFromMap,
          ),
        ],
      ),
    );
  }

  Widget _buildBusStopOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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

  Widget _buildBusStopRecentSection() {
    return const Expanded(
      child: SizedBox.shrink(),
    );
  }
}