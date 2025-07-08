import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/services/subway_service.dart';
import '../../app/services/location_service.dart';

class RealtimeController extends GetxController {
  final GetStorage _storage = GetStorage();
  
  // 상태 변수
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<SubwayArrival> subwayArrivals = <SubwayArrival>[].obs;
  final RxString currentStation = ''.obs;
  final Rx<CommuteType> commuteType = CommuteType.none.obs;
  
  // 실시간 카운트다운 관련
  Timer? _countdownTimer;
  final RxInt _elapsedSeconds = 0.obs;
  DateTime? _lastDataUpdateTime;
  
  // 위치 정보
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  final RxString currentAddress = ''.obs;
  
  // 출퇴근 정보
  final RxString homeAddress = ''.obs;
  final RxString workAddress = ''.obs;
  final RxString workStartTime = ''.obs;
  final RxString workEndTime = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeRealtimeData();
    _startCountdownTimer();
  }
  
  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  // 사용자 데이터 로드
  void _loadUserData() {
    homeAddress.value = _storage.read('home_address') ?? '';
    workAddress.value = _storage.read('work_address') ?? '';
    workStartTime.value = _storage.read('work_start_time') ?? '';
    workEndTime.value = _storage.read('work_end_time') ?? '';
    
    print('=== 사용자 기본 데이터 로드 완료 ===');
    print('집: ${homeAddress.value}');
    print('회사: ${workAddress.value}');
    print('근무시간: ${workStartTime.value} ~ ${workEndTime.value}');
    
    // 현재 위치는 실시간 조회를 우선하고, 실패시에만 저장된 값 사용
    currentAddress.value = '위치를 확인하는 중...';
    currentLatitude.value = 0.0;
    currentLongitude.value = 0.0;
  }

  // 실시간 데이터 초기화
  Future<void> _initializeRealtimeData() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // 1. 현재 위치 업데이트
      await _updateCurrentLocation();
      
      // 2. 출퇴근 시간 판단
      _determineCommuteType();
      
      // 3. 지하철 실시간 정보 로드
      await _loadSubwayData();
      
      // 4. 실시간 카운트다운 시작
      _resetCountdownTimer();
      
    } catch (e) {
      errorMessage.value = '지하철 정보를 불러올 수 없습니다.\n잠시 후 다시 시도해주세요.';
      print('실시간 데이터 초기화 오류: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // 현재 위치 업데이트
  Future<void> _updateCurrentLocation() async {
    try {
      print('=== 현재 위치 업데이트 시작 ===');
      
      // 실시간 위치 조회 시도
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        currentLatitude.value = location.latitude;
        currentLongitude.value = location.longitude;
        currentAddress.value = location.address;
        
        // 업데이트된 위치 저장
        await _storage.write('current_latitude', location.latitude);
        await _storage.write('current_longitude', location.longitude);
        await _storage.write('current_address', location.address);
        
        print('실시간 위치 업데이트 성공: ${location.address}');
        print('좌표: ${location.latitude}, ${location.longitude}');
        print('정확도: ${location.accuracyText}');
        return;
      }
      
      print('실시간 위치 조회 실패 - 대체 방법 시도 중...');
      
      // 1차: 마지막 알려진 위치 시도 (GPS 캐시)
      final lastLocation = await LocationService.getLastKnownLocation();
      if (lastLocation != null) {
        currentLatitude.value = lastLocation.latitude;
        currentLongitude.value = lastLocation.longitude;
        currentAddress.value = lastLocation.address;
        print('GPS 마지막 위치 사용: ${lastLocation.address}');
        return;
      }
      
      // 2차: 저장된 위치 정보 시도 (앱 저장소)
      final savedLat = _storage.read('current_latitude') as double?;
      final savedLng = _storage.read('current_longitude') as double?;
      final savedAddress = _storage.read('current_address') as String?;
      
      print('저장된 위치 정보: lat=$savedLat, lng=$savedLng, address=$savedAddress');
      
      if (savedLat != null && savedLng != null && savedAddress != null && savedAddress.isNotEmpty) {
        currentLatitude.value = savedLat;
        currentLongitude.value = savedLng;
        currentAddress.value = '이전 위치: $savedAddress';
        print('저장된 위치 정보 사용: $savedAddress');
        print('좌표: $savedLat, $savedLng');
      } else {
        print('모든 위치 정보 없음 - 위치 권한 확인 필요');
        currentAddress.value = '위치를 찾을 수 없습니다';
        _checkLocationStatus();
      }
    } catch (e) {
      print('위치 업데이트 오류: $e');
      
      // 오류 발생시 저장된 위치라도 사용
      final savedLat = _storage.read('current_latitude') as double?;
      final savedLng = _storage.read('current_longitude') as double?;
      final savedAddress = _storage.read('current_address') as String?;
      
      if (savedLat != null && savedLng != null && savedAddress != null) {
        currentLatitude.value = savedLat;
        currentLongitude.value = savedLng;
        currentAddress.value = savedAddress;
        print('오류로 인해 저장된 위치 정보 사용: $savedAddress');
        print('좌표: $savedLat, $savedLng');
      } else {
        print('저장된 위치 정보도 없음 - 사용자에게 위치 활성화 요청');
        currentAddress.value = '위치 권한을 확인해주세요';
        
        // 위치 권한 상태 확인 및 사용자 알림
        _checkLocationStatus();
      }
    }
  }

  // 출퇴근 시간 판단
  void _determineCommuteType() {
    commuteType.value = SubwayService.getCommuteType();
    
    switch (commuteType.value) {
      case CommuteType.toWork:
        print('출근 시간대 - 집에서 회사로');
        break;
      case CommuteType.toHome:
        print('퇴근 시간대 - 회사에서 집으로');
        break;
      case CommuteType.none:
        print('출퇴근 시간이 아님');
        break;
    }
  }

  // 지하철 실시간 정보 로드
  Future<void> _loadSubwayData() async {
    try {
      String? targetStation;
      String? destinationStation;
      
      // 현재 위치 기준으로 가장 가까운 지하철역 찾기
      if (currentLatitude.value != 0 && currentLongitude.value != 0) {
        targetStation = await SubwayService.findNearestStation(
          currentLatitude.value, 
          currentLongitude.value
        );
      }
      
      // 항상 집(신림역) 방향으로 목적지 설정
      final homeLat = _storage.read('home_latitude') as double?;
      final homeLng = _storage.read('home_longitude') as double?;
      if (homeLat != null && homeLng != null) {
        destinationStation = await SubwayService.findNearestStation(homeLat, homeLng);
      }
      
      if (targetStation != null) {
        currentStation.value = targetStation;
        
        // 지하철 실시간 정보 조회 (목적지 방향 필터링 포함)
        final arrivals = await SubwayService.getRealtimeArrivalFiltered(
          targetStation, 
          destinationStation
        );
        subwayArrivals.value = arrivals;
        
        // 데이터 업데이트 시간 기록
        _lastDataUpdateTime = DateTime.now();
        _elapsedSeconds.value = 0;
        
        if (destinationStation != null) {
          print('지하철 실시간 정보 로드 완료: $targetStation → $destinationStation (${arrivals.length}개)');
        } else {
          print('지하철 실시간 정보 로드 완료: $targetStation (전체 ${arrivals.length}개)');
        }
      } else {
        errorMessage.value = '근처에 지하철역이 없습니다.\n다른 위치에서 시도해주세요.';
        print('지하철역을 찾을 수 없음');
      }
    } catch (e) {
      errorMessage.value = '지하철 정보를 불러올 수 없습니다.\n네트워크를 확인해주세요.';
      print('지하철 데이터 로드 오류: $e');
    }
  }


  // 수동 새로고침
  Future<void> refresh() async {
    print('실시간 정보 새로고침');
    await _loadSubwayData();
    _resetCountdownTimer();
  }

  // 위치 새로고침 (실시간 위치 강제 조회)
  Future<void> refreshLocation() async {
    print('=== 위치 강제 새로고침 시작 ===');
    isLoading.value = true;
    
    try {
      // 강제로 실시간 위치 조회
      final location = await LocationService.getCurrentLocation();
      if (location != null) {
        currentLatitude.value = location.latitude;
        currentLongitude.value = location.longitude;
        currentAddress.value = location.address;
        
        // 업데이트된 위치 저장
        await _storage.write('current_latitude', location.latitude);
        await _storage.write('current_longitude', location.longitude);
        await _storage.write('current_address', location.address);
        
        print('위치 강제 업데이트 완료: ${location.address}');
        print('좌표: ${location.latitude}, ${location.longitude}');
        
        // 새로운 위치 기반으로 지하철 정보 다시 로드
        await _loadSubwayData();
        _resetCountdownTimer();
        
        Get.snackbar(
          '위치 업데이트',
          '현재 위치가 업데이트되었습니다',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '위치 오류',
          '현재 위치를 찾을 수 없습니다.\nGPS가 켜져 있는지 확인해주세요.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      print('위치 강제 업데이트 오류: $e');
      Get.snackbar(
        '위치 오류',
        '위치 정보를 업데이트할 수 없습니다.\n잠시 후 다시 시도해주세요.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 출퇴근 시간대 텍스트
  String get commuteTypeText {
    switch (commuteType.value) {
      case CommuteType.toWork:
        return '출근 시간대';
      case CommuteType.toHome:
        return '퇴근 시간대';
      case CommuteType.none:
        return '평상시';
    }
  }

  // 출퇴근 방향 텍스트
  String get commuteDirectionText {
    switch (commuteType.value) {
      case CommuteType.toWork:
        return '집 → 회사';
      case CommuteType.toHome:
        return '회사 → 집';
      case CommuteType.none:
        // 현재 시간 기준으로 더 구체적인 정보 제공
        final now = DateTime.now();
        final hour = now.hour;
        if (hour >= 6 && hour < 12) {
          return '오전 시간대';
        } else if (hour >= 12 && hour < 18) {
          return '오후 시간대';
        } else {
          return '저녁/밤 시간대';
        }
    }
  }

  // 현재 시간 텍스트 (실시간 업데이트)
  final RxString _currentTime = ''.obs;
  String get currentTimeText {
    if (_currentTime.value.isEmpty) {
      _updateCurrentTime();
    }
    return _currentTime.value;
  }
  
  void _updateCurrentTime() {
    final now = DateTime.now();
    _currentTime.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  // 지하철 정보가 있는지 확인
  bool get hasSubwayData {
    return subwayArrivals.isNotEmpty;
  }
  
  // 위치 상태 확인 및 사용자 알림
  Future<void> _checkLocationStatus() async {
    try {
      final permissionResult = await LocationService.checkLocationPermission();
      if (!permissionResult.success) {
        print('위치 권한 문제: ${permissionResult.message}');
        currentAddress.value = '위치 권한이 필요합니다';
      }
    } catch (e) {
      print('위치 상태 확인 오류: $e');
    }
  }
  
  // 실시간 카운트다운 타이머 시작
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 현재 시간 업데이트
      _updateCurrentTime();
      
      if (_lastDataUpdateTime != null) {
        final elapsed = DateTime.now().difference(_lastDataUpdateTime!).inSeconds;
        _elapsedSeconds.value = elapsed;
        
        // 3분마다 자동 새로고침
        if (elapsed > 0 && elapsed % 180 == 0) {
          print('자동 새로고침 (3분 경과)');
          refresh();
        }
      }
    });
  }
  
  // 카운트다운 타이머 리셋
  void _resetCountdownTimer() {
    _lastDataUpdateTime = DateTime.now();
    _elapsedSeconds.value = 0;
  }
  
  // 실시간 업데이트된 도착 시간 텍스트 가져오기
  String getRealtimeArrivalTime(SubwayArrival arrival) {
    return arrival.getUpdatedArrivalTime(_elapsedSeconds.value);
  }
}