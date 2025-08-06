import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

class StepRouteSetup extends GetView<OnboardingController> {
  const StepRouteSetup({super.key});

  @override
  Widget build(BuildContext context) {
    // Arguments에서 모드 확인
    final arguments = Get.arguments as Map<String, dynamic>?;
    final isAddNewMode = arguments?['mode'] == 'add_new';
    final customTitle = arguments?['title'] as String?;
    
    // 로컬 상태 관리 (GetStorage에서 복원)
    final RxnString selectedDeparture = RxnString();
    final RxList<LocationInfo> transferStations = <LocationInfo>[].obs;
    final RxnString selectedArrival = RxnString();
    final RxnString routeName = RxnString(); // 경로 이름
    
    // 저장된 데이터 복원
    _loadSavedRouteData(selectedDeparture, transferStations, selectedArrival, isAddNewMode);

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
                _buildHeader(isAddNewMode, customTitle),
                
                // 진행률 표시 (온보딩 모드에서만)
                if (!isAddNewMode) _buildProgressIndicator(),
                
                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // 경로 이름 입력 필드 (새 경로 추가 모드에서만)
                        if (isAddNewMode) ...[
                          _buildRouteNameInput(routeName),
                          const SizedBox(height: 16),
                        ],
                        
                        // 출발지 설정 버튼 또는 선택된 출발지 카드
                        Obx(() {
                          if (selectedDeparture.value == null) {
                            return _buildDepartureButton(
                              onTap: () async {
                                final result = await Get.toNamed('/location-search', arguments: {
                                  'mode': 'departure',
                                  'title': '출발지 설정'
                                });
                                
                                if (result != null) {
                                  selectedDeparture.value = result['name'];
                                }
                              },
                            );
                          } else {
                            return _buildSelectedLocationCard(
                              location: LocationInfo(
                                name: selectedDeparture.value!,
                                type: 'subway',
                                lineInfo: '출발지',
                                code: '',
                              ),
                              color: const Color(0xFF3B82F6),
                              label: '출발지',
                              onDelete: () => selectedDeparture.value = null,
                            );
                          }
                        }),

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

                        // 도착지 설정 버튼 또는 선택된 도착지 카드
                        Obx(() {
                          if (selectedArrival.value == null) {
                            return _buildArrivalButton(
                              onTap: () async {
                                final result = await Get.toNamed('/location-search', arguments: {
                                  'mode': 'arrival',
                                  'title': '도착지 설정'
                                });
                                
                                if (result != null) {
                                  selectedArrival.value = result['name'];
                                }
                              },
                            );
                          } else {
                            return _buildSelectedLocationCard(
                              location: LocationInfo(
                                name: selectedArrival.value!,
                                type: 'subway',
                                lineInfo: '도착지',
                                code: '',
                              ),
                              color: const Color(0xFF10B981),
                              label: '도착지',
                              onDelete: () => selectedArrival.value = null,
                            );
                          }
                        }),

                        const SizedBox(height: 100), // 하단 버튼 공간
                      ],
                    ),
                  ),
                ),

                
                // 커스텀 하단 버튼
                _buildCustomBottomBar(selectedDeparture, selectedArrival, transferStations, routeName, isAddNewMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isAddNewMode, String? customTitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => isAddNewMode ? Get.back() : controller.previousStep(),
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
                Text(
                  customTitle ?? '경로 설정',
                  style: const TextStyle(
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
                '3단계 중 1단계 완료',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '33%',
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
        final gapWidth = 8.0;
        final totalGaps = gapWidth * 2; // 3단계이므로 간격은 2개
        final segmentWidth = (totalWidth - totalGaps) / 3; // 3개의 세그먼트

        return Row(
          children: [
            // 1단계 (완료)
            Container(
              width: segmentWidth,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(width: gapWidth),
            // 2-3단계 (미완료)
            ...List.generate(2, (index) => [
              Container(
                width: segmentWidth,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (index < 1) SizedBox(width: gapWidth),
            ]).expand((x) => x),
          ],
        );
      },
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
        color: Colors.white,
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

  Widget _buildDepartureButton({
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
              '출발지 설정',
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


  Widget _buildCustomBottomBar(RxnString selectedDeparture, RxnString selectedArrival, RxList<LocationInfo> transferStations, RxnString routeName, bool isAddNewMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final bool canProceed = selectedDeparture.value != null &&
            selectedArrival.value != null;

        return GestureDetector(
          onTap: canProceed ? () {
            if (isAddNewMode) {
              _saveNewRoute(selectedDeparture, selectedArrival, transferStations, routeName);
            } else {
              controller.nextStep();
            }
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
            child: Center(
              child: Text(
                isAddNewMode ? '경로 저장' : '다음 단계',
                style: const TextStyle(
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

  Widget _buildRouteNameInput(RxnString routeName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_outline,
                color: Colors.purple[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '경로 이름',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => routeName.value = value.isNotEmpty ? value : null,
            decoration: InputDecoration(
              hintText: '예: 집 → 회사, 출근길 등',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.purple[600]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  // 저장된 경로 데이터 복원
  void _loadSavedRouteData(
    RxnString selectedDeparture,
    RxList<LocationInfo> transferStations,
    RxnString selectedArrival,
    bool isAddNewMode,
  ) {
    final storage = GetStorage();
    
    // 새 경로 추가 모드라면 깨끗한 상태로 시작
    if (isAddNewMode) {
      print('🆕 새 경로 추가 모드 - 깨끗한 상태로 시작');
      return;
    }
    
    // 온보딩 모드에서는 기존 데이터 복원
    // 출발지 복원
    final savedDeparture = storage.read<String>('onboarding_departure');
    if (savedDeparture != null) {
      selectedDeparture.value = savedDeparture;
      print('🔄 출발지 복원: $savedDeparture');
    }
    
    // 도착지 복원
    final savedArrival = storage.read<String>('onboarding_arrival');
    if (savedArrival != null) {
      selectedArrival.value = savedArrival;
      print('🔄 도착지 복원: $savedArrival');
    }
    
    // 환승지들 복원
    final savedTransfers = storage.read<List>('onboarding_transfers');
    if (savedTransfers != null) {
      transferStations.clear();
      for (final transfer in savedTransfers) {
        if (transfer is Map) {
          transferStations.add(LocationInfo(
            name: transfer['name'] ?? '',
            type: transfer['type'] ?? 'subway',
            lineInfo: transfer['lineInfo'] ?? '',
            code: transfer['code'] ?? '',
          ));
        }
      }
      print('🔄 환승지 복원: ${transferStations.length}개');
    }
    
    // 데이터 변경 감지 및 자동 저장 설정 (온보딩 모드에서만)
    selectedDeparture.listen((value) => _saveRouteData(selectedDeparture, transferStations, selectedArrival));
    selectedArrival.listen((value) => _saveRouteData(selectedDeparture, transferStations, selectedArrival));
    transferStations.listen((value) => _saveRouteData(selectedDeparture, transferStations, selectedArrival));
  }
  
  // 경로 데이터 저장
  void _saveRouteData(
    RxnString selectedDeparture,
    RxList<LocationInfo> transferStations,
    RxnString selectedArrival,
  ) {
    final storage = GetStorage();
    
    // 출발지 저장
    if (selectedDeparture.value != null) {
      storage.write('onboarding_departure', selectedDeparture.value);
    } else {
      storage.remove('onboarding_departure');
    }
    
    // 도착지 저장
    if (selectedArrival.value != null) {
      storage.write('onboarding_arrival', selectedArrival.value);
    } else {
      storage.remove('onboarding_arrival');
    }
    
    // 환승지들 저장
    if (transferStations.isNotEmpty) {
      final transfersData = transferStations.map((transfer) => {
        'name': transfer.name,
        'type': transfer.type,
        'lineInfo': transfer.lineInfo,
        'code': transfer.code,
      }).toList();
      storage.write('onboarding_transfers', transfersData);
    } else {
      storage.remove('onboarding_transfers');
    }
    
    print('💾 경로 데이터 저장 완료');
    print('   출발지: ${selectedDeparture.value}');
    print('   도착지: ${selectedArrival.value}');
    print('   환승지: ${transferStations.length}개');
  }
  
  // 새 경로 저장 (새 경로 추가 모드용)
  void _saveNewRoute(RxnString selectedDeparture, RxnString selectedArrival, RxList<LocationInfo> transferStations, RxnString routeName) {
    final storage = GetStorage();
    
    // 현재 설정된 경로를 새 경로로 저장
    if (selectedDeparture.value != null && selectedArrival.value != null) {
      
      // 경로 이름 생성 (없으면 자동 생성)
      final finalRouteName = routeName.value ?? 
          '${selectedDeparture.value} → ${selectedArrival.value}';
      
      // 새 경로 데이터 생성
      final newRoute = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // 고유 ID 생성
        'name': finalRouteName,
        'departure': selectedDeparture.value,
        'arrival': selectedArrival.value,
        'transfers': transferStations.map((transfer) => {
          'name': transfer.name,
          'type': transfer.type,
          'lineInfo': transfer.lineInfo,
          'code': transfer.code,
        }).toList(),
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      // 기존 경로 목록 가져오기
      final existingRoutes = storage.read<List>('saved_routes') ?? [];
      final routesList = List<Map<String, dynamic>>.from(
        existingRoutes.map((route) => Map<String, dynamic>.from(route as Map))
      );
      
      // 새 경로 추가
      routesList.add(newRoute);
      
      // 업데이트된 경로 목록 저장
      storage.write('saved_routes', routesList);
      
      // 첫 번째 경로라면 현재 경로로도 설정 (기존 로직과 호환성 유지)
      if (routesList.length == 1) {
        storage.write('saved_departure', selectedDeparture.value);
        storage.write('saved_arrival', selectedArrival.value);
        storage.write('saved_route_name', finalRouteName);
        
        if (transferStations.isNotEmpty) {
          final transfersData = transferStations.map((transfer) => {
            'name': transfer.name,
            'type': transfer.type,
            'lineInfo': transfer.lineInfo,
            'code': transfer.code,
          }).toList();
          storage.write('saved_transfers', transfersData);
        } else {
          storage.remove('saved_transfers');
        }
      }
      
      print('🆕 새 경로 저장 완료');
      print('   경로 ID: ${newRoute['id']}');
      print('   경로 이름: $finalRouteName');
      print('   출발지: ${selectedDeparture.value}');
      print('   도착지: ${selectedArrival.value}');
      print('   환승지: ${transferStations.length}개');
      print('   총 경로 수: ${routesList.length}개');
      
      // 이전 화면으로 돌아가기 (성공 결과 전달)
      Get.back(result: true);
    }
  }
}