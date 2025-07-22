import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../onboarding_controller.dart';

// LocationInfo 클래스 정의
class LocationInfo {
  final String name;
  final String type; // 'subway' 또는 'bus'
  final String lineInfo;
  final String code;

  LocationInfo({
    required this.name,
    required this.type,
    required this.lineInfo,
    required this.code,
  });
}

class StepRouteSetupNew extends GetView<OnboardingController> {
  const StepRouteSetupNew({super.key});

  @override
  Widget build(BuildContext context) {
    // 로컬 상태 관리
    final RxnString selectedDeparture = RxnString();
    final RxList<LocationInfo> transferStations = <LocationInfo>[].obs;
    final RxnString selectedArrival = RxnString();
    final RxList<LocationInfo> searchResults = <LocationInfo>[].obs;
    final RxString searchQuery = ''.obs;
    final RxBool isSearching = false.obs;
    final RxString editingMode = ''.obs; // 'departure', 'transfer', 'arrival'
    final RxInt editingTransferIndex = (-1).obs;

    final TextEditingController searchController = TextEditingController();

    // 더미 검색 결과 생성
    void performSearch(String query) {
      if (query.isEmpty) {
        searchResults.clear();
        return;
      }

      isSearching.value = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        searchResults.value = [
          LocationInfo(name: '강남역', type: 'subway', lineInfo: '2호선, 신분당선', code: '222'),
          LocationInfo(name: '역삼역', type: 'subway', lineInfo: '2호선', code: '223'),
          LocationInfo(name: '선릉역', type: 'subway', lineInfo: '2호선, 분당선', code: '224'),
          LocationInfo(name: '강남역.강남구청', type: 'bus', lineInfo: '간선 146, 472', code: '23-180'),
          LocationInfo(name: '역삼역.포스코센터', type: 'bus', lineInfo: '지선 3412, 4319', code: '23-181'),
        ].where((station) => station.name.contains(query)).toList();
        isSearching.value = false;
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '경로 설정',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '출발지, 환승지, 도착지 설정',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '4단계 중 1단계 완료',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '25%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 출발지 설정
                  Obx(() => _buildLocationCard(
                    title: '출발지',
                    subtitle: '집 근처 지하철역 또는 버스정류장',
                    icon: Icons.home,
                    color: Colors.blue,
                    selectedLocation: selectedDeparture.value,
                    onTap: () {
                      editingMode.value = 'departure';
                      searchController.clear();
                      searchResults.clear();
                    },
                    onClear: () => selectedDeparture.value = null,
                  )),

                  const SizedBox(height: 16),

                  // 환승지들 표시
                  Obx(() {
                    return Column(
                      children: [
                        ...transferStations.asMap().entries.map((entry) {
                          int index = entry.key;
                          LocationInfo transfer = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSelectedCard(
                              location: transfer,
                              color: Colors.orange,
                              label: '환승지 ${index + 1}',
                              onDelete: () => transferStations.removeAt(index),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }),

                  // 환승지 추가 버튼
                  Obx(() {
                    if (transferStations.length < 3) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildAddTransferButton(
                          onTap: () {
                            editingMode.value = 'transfer';
                            editingTransferIndex.value = transferStations.length;
                            searchController.clear();
                            searchResults.clear();
                          },
                          count: transferStations.length,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // 도착지 설정
                  Obx(() => _buildLocationCard(
                    title: '도착지',
                    subtitle: '회사 근처 지하철역 또는 버스정류장',
                    icon: Icons.business,
                    color: Colors.green,
                    selectedLocation: selectedArrival.value,
                    onTap: () {
                      editingMode.value = 'arrival';
                      searchController.clear();
                      searchResults.clear();
                    },
                    onClear: () => selectedArrival.value = null,
                  )),

                  const SizedBox(height: 24),

                  // 경로 요약 카드
                  Obx(() => _buildRouteSummaryCard(
                    departure: selectedDeparture.value,
                    transfers: transferStations,
                    arrival: selectedArrival.value,
                  )),

                  const SizedBox(height: 80), // 하단 버튼 공간
                ],
              ),
            ),
          ),

          // 검색 오버레이
          Obx(() {
            if (editingMode.value.isNotEmpty) {
              return _buildSearchOverlay(
                searchController: searchController,
                searchResults: searchResults,
                isSearching: isSearching,
                onSearch: performSearch,
                onSelect: (LocationInfo location) {
                  if (editingMode.value == 'departure') {
                    selectedDeparture.value = location.name;
                  } else if (editingMode.value == 'transfer') {
                    transferStations.add(location);
                  } else if (editingMode.value == 'arrival') {
                    selectedArrival.value = location.name;
                  }
                  editingMode.value = '';
                  searchController.clear();
                  searchResults.clear();
                },
                onCancel: () {
                  editingMode.value = '';
                  searchController.clear();
                  searchResults.clear();
                },
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final bool canProceed = selectedDeparture.value != null && 
                                   selectedArrival.value != null;
            
            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canProceed ? () {
                  // 다음 단계로 이동
                  controller.nextStep();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed ? Colors.blue[600] : Colors.grey[300],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '다음 단계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? selectedLocation,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    if (selectedLocation != null) {
      return _buildSelectedCard(
        location: LocationInfo(
          name: selectedLocation,
          type: 'subway',
          lineInfo: '2호선',
          code: '222',
        ),
        color: color,
        label: title,
        onDelete: onClear,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 아이콘과 제목
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 검색창 프리뷰
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                title == '출발지' 
                    ? '예: 강남역, 강남역.강남구청'
                    : '예: 역삼역, 선릉역.포스코센터',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCard({
    required LocationInfo location,
    required Color color,
    required String label,
    required VoidCallback onDelete,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            location.type == 'subway' ? Icons.train : Icons.directions_bus,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$label • ${location.type == 'subway' ? '지하철' : '버스'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.close,
              color: color,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransferButton({
    required VoidCallback onTap,
    required int count,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.orange[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '환승지 추가 ($count/3)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.orange[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSummaryCard({
    required String? departure,
    required List<LocationInfo> transfers,
    required String? arrival,
  }) {
    if (departure == null && arrival == null && transfers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '설정된 경로',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (departure != null) ...[
            Row(
              children: [
                const Text('🏠', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '출발: $departure',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          ...transfers.asMap().entries.map((entry) {
            int index = entry.key;
            LocationInfo transfer = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text('🔄', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '환승${index + 1}: ${transfer.name}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
          if (arrival != null) ...[
            Row(
              children: [
                const Text('🏢', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '도착: $arrival',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '총 환승 횟수: ${transfers.length}회',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchOverlay({
    required TextEditingController searchController,
    required RxList<LocationInfo> searchResults,
    required RxBool isSearching,
    required Function(String) onSearch,
    required Function(LocationInfo) onSelect,
    required VoidCallback onCancel,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 검색창
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: '역이나 정류장 이름을 입력하세요',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[400]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onCancel,
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
          
          // 검색 결과
          Expanded(
            child: Obx(() {
              if (isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (searchResults.isEmpty) {
                return Center(
                  child: Text(
                    searchController.text.isEmpty 
                        ? '검색어를 입력해주세요'
                        : '검색 결과가 없습니다',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final location = searchResults[index];
                  return ListTile(
                    leading: Icon(
                      location.type == 'subway' ? Icons.train : Icons.directions_bus,
                      color: location.type == 'subway' ? Colors.blue : Colors.green,
                    ),
                    title: Text(location.name),
                    subtitle: Text(location.lineInfo),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        location.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    onTap: () => onSelect(location),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}