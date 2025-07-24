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
    final RxInt selectedTab = 0.obs; // 검색 탭 (0: 지하철, 1: 버스, 2: 지도)

    final TextEditingController searchController = TextEditingController();

    // 더미 검색 결과 생성
    void performSearch(String query) {
      if (query.isEmpty) {
        searchResults.clear();
        return;
      }

      isSearching.value = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        List<LocationInfo> allResults = [
          LocationInfo(name: '강남역', type: 'subway', lineInfo: '2호선, 신분당선', code: '222'),
          LocationInfo(name: '역삼역', type: 'subway', lineInfo: '2호선', code: '223'),
          LocationInfo(name: '선릉역', type: 'subway', lineInfo: '2호선, 분당선', code: '224'),
          LocationInfo(name: '서초역', type: 'subway', lineInfo: '2호선', code: '225'),
          LocationInfo(name: '강남역.강남구청', type: 'bus', lineInfo: '간선 146, 472', code: '23-180'),
          LocationInfo(name: '역삼역.포스코센터', type: 'bus', lineInfo: '지선 3412, 4319', code: '23-181'),
          LocationInfo(name: '선릉역.엘타워', type: 'bus', lineInfo: '간선 240, 341', code: '23-182'),
        ];

        // 탭에 따른 필터링
        if (selectedTab.value == 0) {
          // 지하철만
          searchResults.value = allResults
              .where((station) => station.type == 'subway' && station.name.contains(query))
              .toList();
        } else if (selectedTab.value == 1) {
          // 버스만
          searchResults.value = allResults
              .where((station) => station.type == 'bus' && station.name.contains(query))
              .toList();
        } else {
          // 지도 검색은 별도 처리
          searchResults.clear();
        }
        isSearching.value = false;
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // 연한 파란색
              Color(0xFFE8EAF6), // 연한 인디고색
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 커스텀 헤더
                _buildHeader(),
                
                // 진행률 표시
                _buildProgressIndicator(),
                
                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 출발지 설정 / 환승지 추가 버튼
                        _buildAddTransferButton(
                          onTap: () async {
                            // 첫 번째는 출발지 설정, 그 이후는 환승지 추가
                            String mode = transferStations.length == 0 ? 'departure' : 'transfer';
                            final result = await Get.toNamed('/location-search', arguments: {
                              'mode': mode,
                              'title': transferStations.length == 0 ? '출발지 설정' : '환승지 추가'
                            });
                            
                            if (result != null) {
                              if (mode == 'departure') {
                                selectedDeparture.value = result['name'];
                              } else {
                                transferStations.add(LocationInfo(
                                  name: result['name'],
                                  type: result['type'] ?? 'subway',
                                  lineInfo: result['lineInfo'] ?? '',
                                  code: result['code'] ?? '',
                                ));
                              }
                            }
                          },
                          count: transferStations.length,
                        ),

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
                                  child: _buildSelectedLocationCard(
                                    location: transfer,
                                    color: const Color(0xFFF97316), // 주황색
                                    label: '환승지 ${index + 1}',
                                    onDelete: () => transferStations.removeAt(index),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),

                        // 환승지 추가 버튼 (주황색)
                        Obx(() {
                          if (transferStations.length < 3) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildOrangeTransferButton(
                                onTap: () async {
                                  final result = await Get.toNamed('/location-search', arguments: {
                                    'mode': 'transfer',
                                    'title': '환승지 추가'
                                  });
                                  
                                  if (result != null) {
                                    transferStations.add(LocationInfo(
                                      name: result['name'],
                                      type: result['type'] ?? 'subway',
                                      lineInfo: result['lineInfo'] ?? '',
                                      code: result['code'] ?? '',
                                    ));
                                  }
                                },
                                count: transferStations.length,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),

                        // 도착지 설정 버튼
                        _buildArrivalButton(
                          onTap: () async {
                            final result = await Get.toNamed('/location-search', arguments: {
                              'mode': 'arrival',
                              'title': '도착지 설정'
                            });
                            
                            if (result != null) {
                              selectedArrival.value = result['name'];
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // 경로 요약 카드
                        Obx(() => _buildRouteSummaryCard(
                          departure: selectedDeparture.value,
                          transfers: transferStations,
                          arrival: selectedArrival.value,
                        )),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                
                // 커스텀 하단 버튼
                _buildCustomBottomBar(selectedDeparture, selectedArrival),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 24,
              height: 24,
              child: const Icon(Icons.arrow_back, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final gapWidth = 8.0; // 👈 여백 넓히기 (4 → 6)
        final totalGaps = gapWidth * 3; // 3개의 간격
        final segmentWidth = (totalWidth - totalGaps) / 4;

        return Row(
          children: [
            // 1단계 (완료)
            Container(
              width: segmentWidth,
              height: 6, // 👈 높이 키우기 (4 → 6)
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(3), // 👈 radius도 조정 (2 → 3)
              ),
            ),
            SizedBox(width: gapWidth), // 👈 넓어진 여백
            // 2~4단계 (미완료)
            ...List.generate(3, (index) => [
              Container(
                width: segmentWidth,
                height: 6, // 👈 높이 키우기
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3), // 👈 radius 조정
                ),
              ),
              if (index < 2) SizedBox(width: gapWidth), // 👈 넓어진 여백
            ]).expand((x) => x),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String? selectedLocation,
    required String placeholder,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    if (selectedLocation != null) {
      return _buildSelectedLocationCard(
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
          border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
                ),
                Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                placeholder,
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

  Widget _buildSelectedLocationCard({
    required LocationInfo location,
    required Color color,
    required String label,
    required VoidCallback onDelete,
  }) {
    IconData getLocationIcon() {
      switch (location.type) {
        case 'subway':
          return Icons.train;
        case 'bus':
          return Icons.directions_bus;
        case 'map':
          return Icons.location_on;
        default:
          return Icons.location_on;
      }
    }

    String getLocationTypeText() {
      switch (location.type) {
        case 'subway':
          return '지하철';
        case 'bus':
          return '버스';
        case 'map':
          return '지도';
        default:
          return '위치';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            getLocationIcon(),
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
                  '$label • ${getLocationTypeText()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
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
    // 첫 번째는 '출발지 설정', 그 이후는 '환승지 추가'
    String buttonText = count == 0 ? '출발지 설정' : '환승지 추가 ($count/3)';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFF3B82F6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrangeTransferButton({
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
            color: const Color(0xFFF97316).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFFF97316),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '환승지 추가 ($count/3)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF97316),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalButton({
    required VoidCallback onTap,
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
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: const Color(0xFF10B981),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '도착지 설정',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF10B981),
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
          }),
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
    required RxInt selectedTab,
    required Function(String) onSearch,
    required Function(int) onTabChanged,
    required Function(LocationInfo) onSelect,
    required VoidCallback onCancel,
    required VoidCallback onMapSelect,
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
                  color: Colors.black.withValues(alpha: 0.05),
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
          
          // 탭 바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
              children: [
                _buildTabButton('지하철', 0, selectedTab.value, onTabChanged),
                _buildTabButton('버스', 1, selectedTab.value, onTabChanged),
                _buildTabButton('지도', 2, selectedTab.value, onTabChanged),
              ],
            )),
          ),
          
          // 검색 결과 또는 지도
          Expanded(
            child: Obx(() {
              if (selectedTab.value == 2) {
                // 지도 탭
                return _buildMapSection(onMapSelect);
              }
              
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

  Widget _buildTabButton(String title, int index, int selectedIndex, Function(int) onTap) {
    bool isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue[600]! : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.blue[600] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(VoidCallback onMapSelect) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  '지도에서 위치를 선택하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '임시 지도 영역',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onMapSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '이 위치로 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar(RxnString selectedDeparture, RxnString selectedArrival) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final bool canProceed = selectedDeparture.value != null &&
            selectedArrival.value != null;

        return GestureDetector(
          onTap: canProceed ? () {
            controller.nextStep();
          } : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: canProceed ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF3B82F6), // 파란색
                  Color(0xFF6366F1), // 인디고색
                ],
              ) : null,
              color: canProceed ? null : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: canProceed ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: const Center(
              child: Text(
                '다음 단계',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}