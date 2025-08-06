import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../onboarding/widgets/step_route_setup.dart';

class RouteSetupController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 경로 목록
  final RxList<Map<String, dynamic>> routesList = <Map<String, dynamic>>[].obs;
  
  // 온보딩에서 저장한 경로 정보 (호환성 유지용)
  final RxString departure = ''.obs;
  final RxString arrival = ''.obs;
  final RxList<String> transfers = <String>[].obs;
  
  // 수정 모드 상태
  final RxBool isEditMode = false.obs;
  
  // 현재 수정 중인 경로 ID
  final RxString editingRouteId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('=== 경로 설정 화면 초기화 ===');
    _loadOnboardingRouteData();
  }

  @override
  void onReady() {
    super.onReady();
    print('경로 설정 화면 준비 완료');
  }

  @override
  void onClose() {
    print('경로 설정 화면 종료');
    super.onClose();
  }

  // 온보딩에서 저장한 경로 데이터 로드 (영구 저장소에서)
  void _loadOnboardingRouteData() {
    print('=== 온보딩 경로 데이터 로딩 ===');

    // 새로운 경로 목록 구조 확인
    final savedRoutes = _storage.read<List>('saved_routes');
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      // 경로 목록 업데이트
      routesList.clear();
      routesList.addAll(
        savedRoutes.map((route) => Map<String, dynamic>.from(route as Map))
      );
      
      // 첫 번째 경로를 기본 경로로 사용 (호환성 유지)
      final firstRoute = routesList.first;
      departure.value = firstRoute['departure'] ?? '';
      arrival.value = firstRoute['arrival'] ?? '';
      
      // 환승지들 로드
      final routeTransfers = firstRoute['transfers'] as List? ?? [];
      transfers.clear();
      for (final transfer in routeTransfers) {
        if (transfer is Map && transfer['name'] != null) {
          transfers.add(transfer['name']);
        }
      }
      
      print('📋 경로 목록 로딩 완료 (총 ${routesList.length}개 경로)');
      for (var route in routesList) {
        print('  - ${route['name']}: ${route['departure']} → ${route['arrival']}');
      }
      return;
    }

    // 기존 단일 경로 구조 확인 (호환성 유지)
    final savedDeparture = _storage.read<String>('saved_departure');
    if (savedDeparture != null) {
      departure.value = savedDeparture;
      print('출발지: $savedDeparture');
    }

    final savedArrival = _storage.read<String>('saved_arrival');
    if (savedArrival != null) {
      arrival.value = savedArrival;
      print('도착지: $savedArrival');
    }

    final savedTransfers = _storage.read<List>('saved_transfers');
    if (savedTransfers != null) {
      transfers.clear();
      for (final transfer in savedTransfers) {
        if (transfer is Map && transfer['name'] != null) {
          transfers.add(transfer['name']);
        }
      }
      print('환승지: ${transfers.length}개 - ${transfers.join(', ')}');
    }

    if (departure.value.isEmpty && arrival.value.isEmpty && transfers.isEmpty) {
      print('저장된 경로 정보가 없습니다.');
      routesList.clear();
    } else {
      print('경로 정보 로딩 완료');
    }
  }

  // 새 경로 추가 버튼 클릭 시
  void addNewRoute() {
    print('새 경로 추가 버튼 클릭');
    
    // step_route_setup 화면을 새 경로 추가 모드로 열기
    Get.to(
      () => const StepRouteSetup(),
      arguments: {
        'mode': 'add_new',
        'title': '새 경로 추가'
      },
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    )?.then((result) {
      // 새 경로가 추가되었으면 데이터 새로고침
      if (result == true) {
        _loadOnboardingRouteData();
      }
    });
  }

  // 경로 수정 버튼 클릭 시
  void editRoute() {
    print('경로 수정 버튼 클릭');
    isEditMode.value = !isEditMode.value;
    print(isEditMode.value ? '수정 모드 활성화' : '수정 모드 비활성화');
  }

  // 출발지 수정
  void editDeparture() async {
    print('출발지 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'departure',
      'title': '출발지 수정'
    });
    
    if (result != null && result['name'] != null) {
      departure.value = result['name'];
      await _storage.write('saved_departure', result['name']);
      
      print('출발지 수정 완료: ${result['name']}');
    }
  }

  // 도착지 수정
  void editArrival() async {
    print('도착지 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'arrival',
      'title': '도착지 수정'
    });
    
    if (result != null && result['name'] != null) {
      arrival.value = result['name'];
      await _storage.write('saved_arrival', result['name']);
      
      print('도착지 수정 완료: ${result['name']}');
    }
  }

  // 환승지 수정
  void editTransfer(int index) async {
    print('환승지 $index 수정 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 ${index + 1} 수정'
    });
    
    if (result != null && result['name'] != null) {
      transfers[index] = result['name'];
      
      // 환승지 데이터를 맵 형태로 저장
      final transfersData = transfers.map((name) => {'name': name}).toList();
      await _storage.write('saved_transfers', transfersData);
      
      print('환승지 $index 수정 완료: ${result['name']}');
    }
  }

  // 환승지 삭제
  void deleteTransfer(int index) async {
    print('환승지 $index 삭제');
    
    final transferName = transfers[index];
    transfers.removeAt(index);
    
    // 환승지 데이터를 맵 형태로 저장
    final transfersData = transfers.map((name) => {'name': name}).toList();
    await _storage.write('saved_transfers', transfersData);
  }

  // 환승지 추가
  void addTransfer() async {
    print('환승지 추가 버튼 클릭');
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 추가'
    });
    
    if (result != null && result['name'] != null) {
      transfers.add(result['name']);
      
      // 환승지 데이터를 맵 형태로 저장
      final transfersData = transfers.map((name) => {'name': name}).toList();
      await _storage.write('saved_transfers', transfersData);
      
      print('환승지 추가 완료: ${result['name']}');
    }
  }

  // 특정 경로의 수정 모드 토글
  void toggleEditMode(String routeId) {
    print('경로 $routeId 수정 모드 토글');
    
    if (editingRouteId.value == routeId) {
      // 이미 수정 중인 경로면 수정 모드 해제
      editingRouteId.value = '';
      print('수정 모드 비활성화');
    } else {
      // 다른 경로를 수정 모드로 설정
      editingRouteId.value = routeId;
      print('경로 $routeId 수정 모드 활성화');
    }
  }

  // 특정 경로의 출발지/도착지 수정
  void editRouteLocation(String routeId, String locationType) async {
    print('경로 $routeId의 $locationType 수정');
    
    final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
    if (routeIndex == -1) return;
    
    final title = locationType == 'departure' ? '출발지 수정' : '도착지 수정';
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': locationType,
      'title': title
    });
    
    if (result != null && result['name'] != null) {
      // 경로 목록에서 해당 경로 업데이트
      final updatedRoute = Map<String, dynamic>.from(routesList[routeIndex]);
      updatedRoute[locationType] = result['name'];
      routesList[routeIndex] = updatedRoute;
      
      // 스토리지에 저장
      _saveRoutesToStorage();
      
      final locationName = locationType == 'departure' ? '출발지' : '도착지';
      
      print('$locationName 수정 완료: ${result['name']}');
    }
  }

  // 특정 경로의 환승지 수정
  void editRouteTransfer(String routeId, int transferIndex) async {
    print('경로 $routeId의 환승지 $transferIndex 수정');
    
    final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
    if (routeIndex == -1) return;
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 ${transferIndex + 1} 수정'
    });
    
    if (result != null && result['name'] != null) {
      // 경로 목록에서 해당 경로의 환승지 업데이트
      final updatedRoute = Map<String, dynamic>.from(routesList[routeIndex]);
      final transfers = List<Map<String, dynamic>>.from(updatedRoute['transfers'] ?? []);
      
      if (transferIndex < transfers.length) {
        transfers[transferIndex] = {
          'name': result['name'],
          'type': result['type'] ?? 'subway',
          'lineInfo': result['lineInfo'] ?? '',
          'code': result['code'] ?? '',
        };
        updatedRoute['transfers'] = transfers;
        routesList[routeIndex] = updatedRoute;
        
        // 스토리지에 저장
        _saveRoutesToStorage();
        
        print('환승지 $transferIndex 수정 완료: ${result['name']}');
      }
    }
  }

  // 특정 경로의 환승지 삭제
  void deleteRouteTransfer(String routeId, int transferIndex) async {
    print('경로 $routeId의 환승지 $transferIndex 삭제');
    
    final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
    if (routeIndex == -1) return;
    
    // 경로 목록에서 해당 경로의 환승지 삭제
    final updatedRoute = Map<String, dynamic>.from(routesList[routeIndex]);
    final transfers = List<Map<String, dynamic>>.from(updatedRoute['transfers'] ?? []);
    
    if (transferIndex < transfers.length) {
      final deletedTransferName = transfers[transferIndex]['name'];
      transfers.removeAt(transferIndex);
      updatedRoute['transfers'] = transfers;
      routesList[routeIndex] = updatedRoute;
      
      // 스토리지에 저장
      _saveRoutesToStorage();
      
      print('환승지 $transferIndex 삭제 완료: $deletedTransferName');
    }
  }

  // 특정 경로에 환승지 추가
  void addRouteTransfer(String routeId) async {
    print('경로 $routeId에 환승지 추가');
    
    final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
    if (routeIndex == -1) return;
    
    final result = await Get.toNamed('/location-search', arguments: {
      'mode': 'transfer',
      'title': '환승지 추가'
    });
    
    if (result != null && result['name'] != null) {
      // 경로 목록에서 해당 경로에 환승지 추가
      final updatedRoute = Map<String, dynamic>.from(routesList[routeIndex]);
      final transfers = List<Map<String, dynamic>>.from(updatedRoute['transfers'] ?? []);
      
      transfers.add({
        'name': result['name'],
        'type': result['type'] ?? 'subway',
        'lineInfo': result['lineInfo'] ?? '',
        'code': result['code'] ?? '',
      });
      
      updatedRoute['transfers'] = transfers;
      routesList[routeIndex] = updatedRoute;
      
      // 스토리지에 저장
      _saveRoutesToStorage();
      
      print('환승지 추가 완료: ${result['name']}');
    }
  }

  // 경로 이름 변경
  void editRouteName(String routeId, String currentName) async {
    print('경로 $routeId 이름 변경');
    
    // 텍스트 입력 다이얼로그 표시
    final TextEditingController textController = TextEditingController(text: currentName);
    
    final newName = await Get.dialog<String>(
      AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: const Text(
                '경로 이름 변경',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(
                Icons.close,
                size: 20,
                color: Colors.grey,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '새로운 경로 이름을 입력해주세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '예: 집 → 회사, 출근길 등',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onSubmitted: (value) {
                Get.back(result: value.trim().isNotEmpty ? value.trim() : null);
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final newName = textController.text.trim();
              Get.back(result: newName.isNotEmpty ? newName : null);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('변경'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    
    if (newName != null && newName != currentName) {
      final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
      if (routeIndex != -1) {
        // 경로 목록에서 해당 경로의 이름 업데이트
        final updatedRoute = Map<String, dynamic>.from(routesList[routeIndex]);
        updatedRoute['name'] = newName;
        routesList[routeIndex] = updatedRoute;
        
        // 스토리지에 저장
        _saveRoutesToStorage();
        
        print('경로 이름 변경 완료: $currentName → $newName');
      }
    }
  }

  // 경로 삭제
  void deleteRoute(String routeId, String routeName) async {
    print('경로 $routeId 삭제 요청');
    
    final routeIndex = routesList.indexWhere((route) => route['id'] == routeId);
    if (routeIndex != -1) {
      // 수정 모드 해제 (삭제되는 경로가 현재 수정 중이면)
      if (editingRouteId.value == routeId) {
        editingRouteId.value = '';
      }
      
      // 경로 목록에서 제거
      routesList.removeAt(routeIndex);
      
      // 스토리지에 저장
      _saveRoutesToStorage();
      
      print('경로 삭제 완료: $routeName');
    }
  }

  // 경로 목록을 스토리지에 저장
  void _saveRoutesToStorage() {
    _storage.write('saved_routes', routesList.toList());
    print('💾 경로 목록 스토리지 저장 완료 (총 ${routesList.length}개 경로)');
  }
}