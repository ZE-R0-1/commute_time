import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../app/services/weather_service.dart';
import '../../app/services/subway_service.dart';
import '../../app/services/subway_search_service.dart';
import '../../app/services/bus_arrival_service.dart';
import '../../app/services/seoul_bus_service.dart';

class HomeController extends GetxController {
  final GetStorage _storage = GetStorage();

  // 날씨 정보
  final Rx<WeatherInfo?> currentWeather = Rx<WeatherInfo?>(null);
  final RxList<WeatherForecast> weatherForecast = <WeatherForecast>[].obs;
  final Rx<RainForecastInfo?> rainForecast = Rx<RainForecastInfo?>(null);
  
  // 로딩 상태
  final RxBool isWeatherLoading = false.obs;
  final RxString weatherError = ''.obs;
  final RxString loadingMessage = '날씨 정보를 불러오는 중...'.obs;

  // 위치 정보
  final RxString currentAddress = '위치 정보 없음'.obs;

  // 경로 정보
  final RxString routeName = ''.obs;
  final RxString departureStation = ''.obs;
  final RxString arrivalStation = ''.obs;
  final RxList<Map<String, dynamic>> transferStations = <Map<String, dynamic>>[].obs;
  final RxBool hasRouteData = false.obs;
  final RxString activeRouteId = ''.obs; // 현재 활성화된 경로 ID

  @override
  void onInit() {
    super.onInit();
    print('=== 홈 화면 초기화 ===');
    _loadSavedLocation();
    _loadRouteData();
  }

  @override
  void onReady() {
    super.onReady();
    print('홈 화면 준비 완료');
    loadWeatherData();
  }

  @override
  void onClose() {
    print('홈 화면 종료');
    super.onClose();
  }

  // 저장된 위치 정보 로드
  void _loadSavedLocation() {
    final address = _storage.read('current_address') ?? 
                   _storage.read('home_address') ?? 
                   '위치 정보 없음';
    currentAddress.value = address;
    
    print('현재 주소: ${currentAddress.value}');
  }

  // 날씨 데이터 로딩
  Future<void> loadWeatherData() async {
    try {
      isWeatherLoading.value = true;
      weatherError.value = '';
      
      // 저장된 좌표 정보 확인
      final latitude = _storage.read<double>('current_latitude') ?? 
                      _storage.read<double>('home_latitude');
      final longitude = _storage.read<double>('current_longitude') ?? 
                       _storage.read<double>('home_longitude');

      if (latitude == null || longitude == null) {
        print('저장된 위치 정보가 없음. 현재 위치 요청 시작');
        await _requestCurrentLocation();
      } else {
        print('저장된 좌표 사용: $latitude, $longitude');
        await _fetchWeatherData(latitude, longitude);
      }

    } catch (e) {
      weatherError.value = '날씨 정보를 불러오는데 실패했습니다';
      print('날씨 데이터 로딩 오류: $e');
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // 현재 위치 요청 및 처리
  Future<void> _requestCurrentLocation() async {
    try {
      loadingMessage.value = '위치 서비스 확인 중...';
      
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화됨');
        weatherError.value = '위치 서비스를 활성화해 주세요';
        return;
      }

      loadingMessage.value = '위치 권한 확인 중...';

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한이 거부됨. 권한 요청 시작');
        loadingMessage.value = '위치 권한 요청 중...';
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한 요청 거부됨');
          weatherError.value = '위치 권한이 필요합니다';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부됨');
        weatherError.value = '설정에서 위치 권한을 허용해 주세요';
        return;
      }

      print('위치 권한 허용됨. 현재 위치 가져오는 중...');
      loadingMessage.value = '현재 위치 가져오는 중...';
      
      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('현재 위치: ${position.latitude}, ${position.longitude}');

      // 현재 위치 저장
      _storage.write('current_latitude', position.latitude);
      _storage.write('current_longitude', position.longitude);

      loadingMessage.value = '주소 변환 중...';
      
      // 주소 변환
      await _updateAddressFromCoordinates(position.latitude, position.longitude);

      loadingMessage.value = '날씨 정보 불러오는 중...';
      
      // 날씨 데이터 가져오기
      await _fetchWeatherData(position.latitude, position.longitude);

    } catch (e) {
      print('현재 위치 요청 오류: $e');
      weatherError.value = '현재 위치를 가져올 수 없습니다';
    }
  }

  // 좌표를 주소로 변환
  Future<void> _updateAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        String address = '';
        
        // 시/도 (administrativeArea)
        String? area = place.administrativeArea;
        // 시/군/구 (locality)
        String? locality = place.locality;
        // 동/읍/면 (subLocality)
        String? subLocality = place.subLocality;
        
        print('=== 주소 정보 디버그 ===');
        print('administrativeArea: $area');
        print('locality: $locality');
        print('subLocality: $subLocality');
        print('thoroughfare: ${place.thoroughfare}');
        print('subThoroughfare: ${place.subThoroughfare}');
        
        // 주소 조합 (중복 제거)
        if (area != null && area.isNotEmpty) {
          address = area;
        }
        
        // locality가 area와 다른 경우에만 추가 (중복 방지)
        if (locality != null && locality.isNotEmpty && locality != area) {
          if (address.isNotEmpty) address += ' ';
          address += locality;
        }
        
        // subLocality 추가 (동/읍/면)
        if (subLocality != null && subLocality.isNotEmpty) {
          if (address.isNotEmpty) address += ' ';
          address += subLocality;
        }

        if (address.isEmpty) {
          address = '현재 위치';
        }

        currentAddress.value = address;
        _storage.write('current_address', address);
        
        print('주소 변환 완료: $address');
      }
    } catch (e) {
      print('주소 변환 오류: $e');
      currentAddress.value = '현재 위치';
    }
  }

  // 실제 날씨 데이터 가져오기 (예보 데이터만 사용)
  Future<void> _fetchWeatherData(double lat, double lon) async {
    try {
      print('날씨 API 호출 시작: $lat, $lon');

      // 날씨 예보 조회 (예보 데이터로 현재 날씨도 추출)
      final forecasts = await WeatherService.getWeatherForecast(lat, lon);
      if (forecasts.isNotEmpty) {
        weatherForecast.value = forecasts;
        print('날씨 예보 로드 성공: ${forecasts.length}개 항목');

        // 현재 시간과 가장 가까운 예보 데이터를 현재 날씨로 사용
        final now = DateTime.now();
        final currentForecast = forecasts
            .where((f) => f.dateTime.isAtSameMomentAs(now) || f.dateTime.isAfter(now))
            .firstOrNull;
        
        if (currentForecast != null) {
          // 예보 데이터를 현재 날씨로 변환
          currentWeather.value = WeatherInfo(
            temperature: currentForecast.temperature,
            humidity: currentForecast.humidity,
            precipitation: currentForecast.precipitation,
            skyCondition: currentForecast.skyCondition,
            precipitationType: currentForecast.precipitationType,
          );
          print('현재 날씨 (예보 기반) 설정 성공: ${currentForecast.temperature}°C');
        }

        // 비 예보 분석
        final rainInfo = WeatherService.analyzeTodayRainForecast(forecasts);
        if (rainInfo != null) {
          rainForecast.value = rainInfo;
          print('비 예보: ${rainInfo.message}');
        }
      }

    } catch (e) {
      print('날씨 API 호출 오류: $e');
      throw e;
    }
  }

  // 날씨 새로고침 (현재 위치로 갱신)
  Future<void> refreshWeather() async {
    print('날씨 데이터 새로고침 - 현재 위치로 갱신');
    isWeatherLoading.value = true;
    weatherError.value = '';
    
    try {
      await _requestCurrentLocation();
    } catch (e) {
      weatherError.value = '날씨 정보를 새로고침하는데 실패했습니다';
      print('새로고침 오류: $e');
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // 예보용 날씨 아이콘 가져오기
  String getWeatherIconForForecast(WeatherForecast forecast) {
    // 강수 형태 우선 확인
    switch (forecast.precipitationType) {
      case PrecipitationType.rain:
      case PrecipitationType.rainDrop:
        return '🌧️';
      case PrecipitationType.snow:
      case PrecipitationType.snowDrop:
        return '🌨️';
      case PrecipitationType.rainSnow:
      case PrecipitationType.rainSnowDrop:
        return '🌦️';
      default:
        // 하늘 상태로 구분
        switch (forecast.skyCondition) {
          case SkyCondition.clear:
            return '☀️';
          case SkyCondition.partlyCloudy:
            return '⛅';
          case SkyCondition.cloudy:
            return '☁️';
        }
    }
  }

  // 날씨 아이콘 가져오기
  String getWeatherIcon(WeatherInfo? weather) {
    if (weather == null) return '🌤️';

    // 강수 형태 우선 확인
    switch (weather.precipitationType) {
      case PrecipitationType.rain:
      case PrecipitationType.rainDrop:
        return '🌧️';
      case PrecipitationType.snow:
      case PrecipitationType.snowDrop:
        return '🌨️';
      case PrecipitationType.rainSnow:
      case PrecipitationType.rainSnowDrop:
        return '🌦️';
      default:
        // 하늘 상태로 구분
        switch (weather.skyCondition) {
          case SkyCondition.clear:
            return '☀️';
          case SkyCondition.partlyCloudy:
            return '⛅';
          case SkyCondition.cloudy:
            return '☁️';
        }
    }
  }

  // 날씨 상태 텍스트
  String getWeatherStatusText(WeatherInfo? weather) {
    if (weather == null) return '날씨 정보 없음';

    String status = weather.weatherDescription;
    
    if (weather.precipitationType != PrecipitationType.none) {
      switch (weather.precipitationType) {
        case PrecipitationType.rain:
        case PrecipitationType.rainDrop:
          status = '비';
          break;
        case PrecipitationType.snow:
        case PrecipitationType.snowDrop:
          status = '눈';
          break;
        default:
          break;
      }
    }

    return status;
  }

  // 앱 설정 페이지 열기
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // 경로 데이터 로드
  void _loadRouteData() {
    print('=== 경로 데이터 로딩 ===');
    
    final savedRoutes = _storage.read<List>('saved_routes');
    
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      // 저장된 활성 경로 ID 확인
      final savedActiveRouteId = _storage.read<String>('active_route_id');
      
      Map<String, dynamic>? targetRoute;
      
      if (savedRoutes.length == 1) {
        // 경로가 1개뿐이면 자동으로 선택
        targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
        activeRouteId.value = targetRoute['id'] ?? '';
        // 자동 선택된 경우 스토리지에도 저장
        _storage.write('active_route_id', activeRouteId.value);
      } else if (savedActiveRouteId != null && savedActiveRouteId.isNotEmpty) {
        // 저장된 활성 경로 ID가 있으면 해당 경로 찾기
        for (var route in savedRoutes) {
          final routeMap = Map<String, dynamic>.from(route as Map);
          if (routeMap['id'] == savedActiveRouteId) {
            targetRoute = routeMap;
            activeRouteId.value = savedActiveRouteId;
            break;
          }
        }
        
        // 저장된 활성 경로 ID에 해당하는 경로가 없으면 첫 번째 경로 사용
        if (targetRoute == null) {
          targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
          activeRouteId.value = targetRoute['id'] ?? '';
          _storage.write('active_route_id', activeRouteId.value);
        }
      } else {
        // 활성 경로 ID가 없으면 첫 번째 경로 사용 (2개 이상일 때는 수동 선택 필요)
        targetRoute = Map<String, dynamic>.from(savedRoutes.first as Map);
        activeRouteId.value = targetRoute['id'] ?? '';
        _storage.write('active_route_id', activeRouteId.value);
      }
      
      if (targetRoute != null) {
        routeName.value = targetRoute['name'] ?? '저장된 경로';
        
        // 출발지 처리 (Map 구조만 지원)
        final departure = targetRoute['departure'];
        print('🔍 [홈화면] 출발지 원본 데이터: $departure');
        print('🔍 [홈화면] 출발지 데이터 타입: ${departure.runtimeType}');
        if (departure is Map) {
          print('🔍 [홈화면] 출발지 상세정보: name=${departure['name']}, type=${departure['type']}, lineInfo=${departure['lineInfo']}, code=${departure['code']}');
          departureStation.value = departure['name'] ?? '';
        } else {
          print('⚠️ [홈화면] 출발지가 구형식 데이터입니다. 마이그레이션이 필요합니다.');
          departureStation.value = departure?.toString() ?? '';
        }
        
        // 도착지 처리 (Map 구조만 지원)
        final arrival = targetRoute['arrival'];
        print('🔍 [홈화면] 도착지 원본 데이터: $arrival');
        print('🔍 [홈화면] 도착지 데이터 타입: ${arrival.runtimeType}');
        if (arrival is Map) {
          print('🔍 [홈화면] 도착지 상세정보: name=${arrival['name']}, type=${arrival['type']}, lineInfo=${arrival['lineInfo']}, code=${arrival['code']}');
          arrivalStation.value = arrival['name'] ?? '';
        } else {
          print('⚠️ [홈화면] 도착지가 구형식 데이터입니다. 마이그레이션이 필요합니다.');
          arrivalStation.value = arrival?.toString() ?? '';
        }
        
        final routeTransfers = targetRoute['transfers'] as List?;
        print('🔍 [홈화면] 환승지 원본 데이터: $routeTransfers');
        if (routeTransfers != null) {
          print('🔍 [홈화면] 환승지 개수: ${routeTransfers.length}');
          for (int i = 0; i < routeTransfers.length; i++) {
            final transfer = routeTransfers[i];
            print('🔍 [홈화면] 환승지 ${i+1}: $transfer');
            if (transfer is Map) {
              print('🔍 [홈화면] 환승지 ${i+1} 상세정보: name=${transfer['name']}, type=${transfer['type']}, lineInfo=${transfer['lineInfo']}, code=${transfer['code']}');
            }
          }
          transferStations.value = routeTransfers.map((transfer) => 
            Map<String, dynamic>.from(transfer as Map)).toList();
        } else {
          print('🔍 [홈화면] 환승지 없음');
          transferStations.clear();
        }
        
        hasRouteData.value = true;
        
        print('✅ 활성 경로 데이터 로드 완료:');
        print('   활성 경로 ID: ${activeRouteId.value}');
        print('   경로명: ${routeName.value}');
        print('   출발지: ${targetRoute['departure']}');
        print('   도착지: ${targetRoute['arrival']}');
        print('   환승지: ${transferStations.length}개');
        print('   총 경로 수: ${savedRoutes.length}개');
        
        // 경로 데이터 로드 후 모든 도착정보 로드
        loadAllArrivalInfo();
      }
    } else {
      // 온보딩 경로 확인
      final departure = _storage.read<String>('onboarding_departure');
      final arrival = _storage.read<String>('onboarding_arrival');
      final transfers = _storage.read<List>('onboarding_transfers');

      if (departure != null && arrival != null) {
        routeName.value = '온보딩 경로';
        departureStation.value = departure;
        arrivalStation.value = arrival;
        
        if (transfers != null) {
          transferStations.value = transfers.map((transfer) => 
            Map<String, dynamic>.from(transfer as Map)).toList();
        }
        
        hasRouteData.value = true;
        activeRouteId.value = 'onboarding';
        
        print('✅ 온보딩 경로 데이터 로드 완료:');
        print('   경로명: ${routeName.value}');
        print('   출발지: $departure');
        print('   도착지: $arrival');
        print('   환승지: ${transferStations.length}개');
        
        // 경로 데이터 로드 후 모든 도착정보 로드
        loadAllArrivalInfo();
      } else {
        hasRouteData.value = false;
        activeRouteId.value = '';
        print('❌ 저장된 경로 데이터가 없습니다');
      }
    }
  }

  // 경로 데이터 새로고침 (RouteSetupController에서 호출)
  void refreshRouteData() {
    print('🔄 홈화면 경로 데이터 새로고침 요청');
    _loadRouteData();
  }

  // 경로 적용하기
  void applyRoute(String routeId) {
    print('🔄 경로 적용: $routeId');
    
    final savedRoutes = _storage.read<List>('saved_routes');
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      // 해당 경로 찾기
      for (var route in savedRoutes) {
        final routeMap = Map<String, dynamic>.from(route as Map);
        if (routeMap['id'] == routeId) {
          // 활성 경로 변경
          activeRouteId.value = routeId;
          _storage.write('active_route_id', routeId);
          
          // 홈화면 데이터 즉시 업데이트
          routeName.value = routeMap['name'] ?? '저장된 경로';
          
          // 출발지 처리 (Map 구조만 지원)
          final departure = routeMap['departure'];
          if (departure is Map) {
            departureStation.value = departure['name'] ?? '';
          } else {
            print('⚠️ [경로적용] 출발지가 구형식 데이터입니다.');
            departureStation.value = departure?.toString() ?? '';
          }
          
          // 도착지 처리 (Map 구조만 지원)
          final arrival = routeMap['arrival'];
          if (arrival is Map) {
            arrivalStation.value = arrival['name'] ?? '';
          } else {
            print('⚠️ [경로적용] 도착지가 구형식 데이터입니다.');
            arrivalStation.value = arrival?.toString() ?? '';
          }
          
          final routeTransfers = routeMap['transfers'] as List?;
          if (routeTransfers != null) {
            transferStations.value = routeTransfers.map((transfer) => 
              Map<String, dynamic>.from(transfer as Map)).toList();
          } else {
            transferStations.clear();
          }
          
          hasRouteData.value = true;
          
          print('✅ 경로 적용 완료:');
          print('   활성 경로 ID: ${activeRouteId.value}');
          print('   경로명: ${routeName.value}');
          
          // 경로 변경 후 모든 도착정보 새로고침
          loadAllArrivalInfo();
          
          break;
        }
      }
    }
  }

  // 지하철 도착정보 상태
  final RxList<SubwayArrival> departureArrivalInfo = <SubwayArrival>[].obs;
  final RxList<List<SubwayArrival>> transferArrivalInfo = <List<SubwayArrival>>[].obs;
  final RxList<SubwayArrival> destinationArrivalInfo = <SubwayArrival>[].obs;
  final RxBool isLoadingArrival = false.obs;
  final RxBool isLoadingTransferArrival = false.obs;
  final RxBool isLoadingDestinationArrival = false.obs;
  final RxString arrivalError = ''.obs;
  final RxString transferArrivalError = ''.obs;
  final RxString destinationArrivalError = ''.obs;

  // 버스 도착정보 상태
  final RxList<BusArrivalInfo> departureBusArrivalInfo = <BusArrivalInfo>[].obs;
  final RxList<List<BusArrivalInfo>> transferBusArrivalInfo = <List<BusArrivalInfo>>[].obs;
  final RxList<BusArrivalInfo> destinationBusArrivalInfo = <BusArrivalInfo>[].obs;
  final RxList<SeoulBusArrival> departureSeoulBusArrivalInfo = <SeoulBusArrival>[].obs;
  final RxList<List<SeoulBusArrival>> transferSeoulBusArrivalInfo = <List<SeoulBusArrival>>[].obs;
  final RxList<SeoulBusArrival> destinationSeoulBusArrivalInfo = <SeoulBusArrival>[].obs;

  // 모든 역의 실시간 도착정보 로딩
  Future<void> loadAllArrivalInfo() async {
    await Future.wait([
      loadDepartureArrivalInfo(),
      loadTransferArrivalInfo(),
      loadDestinationArrivalInfo(),
    ]);
  }

  // 출발지 실시간 도착정보 로딩 (버스/지하철 구분)
  Future<void> loadDepartureArrivalInfo() async {
    if (departureStation.value.isEmpty) return;
    
    // 현재 활성 경로에서 출발지 데이터 가져오기
    final savedRoutes = _storage.read<List>('saved_routes');
    Map<String, dynamic>? departureData;
    
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      final activeRoute = savedRoutes.firstWhere(
        (route) => (route as Map)['id'] == activeRouteId.value,
        orElse: () => savedRoutes.first,
      ) as Map<String, dynamic>;
      
      departureData = activeRoute['departure'] as Map<String, dynamic>?;
    }
    
    if (departureData == null) {
      print('⚠️ 출발지 상세 데이터를 찾을 수 없습니다');
      return;
    }
    
    final type = departureData['type'] ?? 'subway';
    final stationCode = departureData['code'] ?? '';
    final lineInfo = departureData['lineInfo'] ?? '';
    
    print('🚦 출발지 도착정보 로딩 시작: ${departureData['name']} (type: $type, code: $stationCode)');
    
    try {
      isLoadingArrival.value = true;
      arrivalError.value = '';
      
      if (type == 'bus') {
        await _loadBusArrivalInfo('departure', departureData);
      } else if (type == 'subway') {
        await _loadSubwayArrivalInfo('departure', departureData);
      }
      
    } catch (e) {
      arrivalError.value = '도착정보 로딩 실패';
      departureArrivalInfo.clear();
      departureBusArrivalInfo.clear(); 
      departureSeoulBusArrivalInfo.clear();
      print('❌ 출발지 도착정보 로딩 오류: $e');
    } finally {
      isLoadingArrival.value = false;
    }
  }
  
  // 버스 도착정보 로딩
  Future<void> _loadBusArrivalInfo(String locationType, Map<String, dynamic> locationData) async {
    final stationCode = locationData['code'] ?? '';
    final lineInfo = locationData['lineInfo'] ?? '';
    final stationName = locationData['name'] ?? '';
    
    print('🚌 $locationType 버스 도착정보 로딩: $stationName (code: $stationCode, region: $lineInfo)');
    
    if (lineInfo.contains('경기도')) {
      // 경기도 버스 도착정보 (v2 API 사용)
      final routeId = locationData['routeId']?.toString() ?? '';
      final staOrder = locationData['staOrder'] ?? 0;
      
      List<BusArrivalInfo> arrivals = [];
      
      if (routeId.isNotEmpty && staOrder > 0) {
        // routeId와 staOrder가 있는 경우 - 새로운 v2 API 사용
        print('🚌 경기도 버스 v2 API 호출: stationId=$stationCode, routeId=$routeId, staOrder=$staOrder');
        final arrivalInfo = await BusArrivalService.getBusArrivalItemv2(stationCode, routeId, staOrder);
        if (arrivalInfo != null) {
          arrivals = [arrivalInfo];
        }
      } else {
        // routeId와 staOrder가 없는 경우 - 도착정보 없음으로 처리
        print('⚠️ 경기도 버스 routeId 또는 staOrder가 없어 도착정보를 가져올 수 없습니다.');
        arrivals = [];
      }
      
      if (locationType == 'departure') {
        departureBusArrivalInfo.value = arrivals;
        departureSeoulBusArrivalInfo.clear(); // 서울버스 정보 클리어
        departureArrivalInfo.clear(); // 지하철 정보 클리어
      } else if (locationType == 'destination') {
        destinationBusArrivalInfo.value = arrivals;
        destinationSeoulBusArrivalInfo.clear(); // 서울버스 정보 클리어
      } else if (locationType.startsWith('transfer_')) {
        // 환승지 버스 도착정보 처리
        final transferIndex = int.tryParse(locationType.replaceFirst('transfer_', '')) ?? 0;
        
        // transferBusArrivalInfo 리스트 크기 확장
        while (transferBusArrivalInfo.length <= transferIndex) {
          transferBusArrivalInfo.add(<BusArrivalInfo>[].obs);
        }
        
        transferBusArrivalInfo[transferIndex] = arrivals.obs;
        print('✅ 환승지 ${transferIndex + 1} 경기도 버스 도착정보 저장: ${arrivals.length}개');
      }
      
    } else if (lineInfo.contains('서울')) {
      // 서울 버스 도착정보 (cityCode 필요)
      // cityCode를 저장된 데이터에서 가져오거나 기본값 사용
      final cityCode = locationData['cityCode']?.toString() ?? '23';
      print('🏙️ 서울 버스 API 호출: cityCode=$cityCode, nodeId=$stationCode');
      final arrivals = await SeoulBusService.getBusArrivalInfo(cityCode, stationCode);
      
      if (locationType == 'departure') {
        departureSeoulBusArrivalInfo.value = arrivals;
        departureBusArrivalInfo.clear(); // 경기도버스 정보 클리어
        departureArrivalInfo.clear(); // 지하철 정보 클리어
      } else if (locationType == 'destination') {
        destinationSeoulBusArrivalInfo.value = arrivals;
        destinationBusArrivalInfo.clear(); // 경기도버스 정보 클리어
      } else if (locationType.startsWith('transfer_')) {
        // 환승지 서울 버스 도착정보 처리
        final transferIndex = int.tryParse(locationType.replaceFirst('transfer_', '')) ?? 0;
        
        // transferSeoulBusArrivalInfo 리스트 크기 확장
        while (transferSeoulBusArrivalInfo.length <= transferIndex) {
          transferSeoulBusArrivalInfo.add(<SeoulBusArrival>[].obs);
        }
        
        transferSeoulBusArrivalInfo[transferIndex] = arrivals.obs;
        print('✅ 환승지 ${transferIndex + 1} 서울 버스 도착정보 저장: ${arrivals.length}개');
      }
      
    }
  }
  
  // 지하철 도착정보 로딩 
  Future<void> _loadSubwayArrivalInfo(String locationType, Map<String, dynamic> locationData) async {
    final stationName = locationData['name'] ?? '';
    
    // 역명에서 순수 역명 추출 (예: "강남역 2호선" → "강남역")
    String cleanStationName = _cleanStationName(stationName);
    
    print('🚇 $locationType 지하철 도착정보 로딩: $stationName → $cleanStationName');
    
    // SubwaySearchService를 사용하여 도착정보 조회
    final allArrivals = await SubwaySearchService.getArrivalInfo(cleanStationName);
    
    // 호선 필터링 적용
    final filteredArrivals = _filterArrivalsByLine(allArrivals, stationName);
    
    if (locationType == 'departure') {
      departureBusArrivalInfo.clear(); // 버스 정보 클리어
      departureSeoulBusArrivalInfo.clear();
      
      if (filteredArrivals.isNotEmpty) {
        departureArrivalInfo.value = filteredArrivals;
        print('✅ 지하철 도착정보 로딩 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
      } else {
        departureArrivalInfo.clear();
        print('⚠️ 지하철 도착정보 없음 (전체 ${allArrivals.length}개 → 필터링 후 0개)');
      }
    }
  }

  // 역명에서 호선 정보 제거 (순수 역명 추출)
  String _cleanStationName(String stationName) {
    // "강남역 2호선 (성수방면)", "사당역 4호선" → "강남역", "사당역"
    // 첫 번째 공백 이전의 역명만 추출
    final parts = stationName.split(' ');
    if (parts.isNotEmpty) {
      return parts.first;
    }
    return stationName;
  }

  // 호선별 도착정보 필터링 (transport_bottom_sheet와 동일한 로직)
  List<SubwayArrival> _filterArrivalsByLine(List<SubwayArrival> arrivals, String lineFilter) {
    if (lineFilter.isEmpty) {
      return arrivals;
    }
    
    // lineFilter에서 노선명과 방면 정보 추출 (예: "강남역 2호선 (성수방면)" -> "2호선", "성수방면")
    String extractedLine = '';
    String extractedDirection = '';
    
    if (lineFilter.contains('1호선')) extractedLine = '1호선';
    else if (lineFilter.contains('2호선')) extractedLine = '2호선';
    else if (lineFilter.contains('3호선')) extractedLine = '3호선';
    else if (lineFilter.contains('4호선')) extractedLine = '4호선';
    else if (lineFilter.contains('5호선')) extractedLine = '5호선';
    else if (lineFilter.contains('6호선')) extractedLine = '6호선';
    else if (lineFilter.contains('7호선')) extractedLine = '7호선';
    else if (lineFilter.contains('8호선')) extractedLine = '8호선';
    else if (lineFilter.contains('9호선')) extractedLine = '9호선';
    else if (lineFilter.contains('신분당선')) extractedLine = '신분당선';
    else if (lineFilter.contains('분당선')) extractedLine = '분당선';
    else if (lineFilter.contains('경의중앙선')) extractedLine = '경의중앙선';
    else if (lineFilter.contains('공항철도')) extractedLine = '공항철도';
    else if (lineFilter.contains('경춘선')) extractedLine = '경춘선';
    else if (lineFilter.contains('수인분당선')) extractedLine = '수인분당선';
    else if (lineFilter.contains('우이신설선')) extractedLine = '우이신설선';
    else if (lineFilter.contains('서해선')) extractedLine = '서해선';
    else if (lineFilter.contains('김포골드라인')) extractedLine = '김포골드라인';
    else if (lineFilter.contains('신림선')) extractedLine = '신림선';
    
    // 방면 정보 추출 (예: "(성수방면)" 부분)
    final directionMatch = RegExp(r'\(([^)]+)방면\)').firstMatch(lineFilter);
    if (directionMatch != null) {
      extractedDirection = directionMatch.group(1) ?? '';
    }
    
    if (extractedLine.isEmpty) {
      return arrivals;
    }
    
    print('🔍 필터링 적용: $lineFilter → 호선: $extractedLine, 방면: $extractedDirection');
    
    // 먼저 호선으로 필터링
    List<SubwayArrival> filtered = arrivals.where((arrival) {
      return arrival.lineDisplayName.contains(extractedLine);
    }).toList();
    
    // 방면 정보가 있으면 추가로 방면 필터링
    if (extractedDirection.isNotEmpty && filtered.isNotEmpty) {
      final directionFiltered = filtered.where((arrival) {
        // cleanTrainLineNm에서 방면 검색 (예: "성수행", "성수방면")
        return arrival.cleanTrainLineNm.contains(extractedDirection) ||
               arrival.cleanTrainLineNm.contains('${extractedDirection}행') ||
               arrival.bstatnNm.contains(extractedDirection);
      }).toList();
      
      // 방면 필터링 결과가 있으면 사용, 없으면 호선 필터링만 사용
      if (directionFiltered.isNotEmpty) {
        filtered = directionFiltered;
        print('📊 방면 필터링 적용: ${arrivals.length}개 → 호선: ${filtered.length}개 → 방면: ${directionFiltered.length}개');
      } else {
        print('📊 방면 필터링 결과 없음, 호선 필터링만 사용: ${arrivals.length}개 → ${filtered.length}개');
      }
    } else {
      print('📊 호선 필터링만 적용: ${arrivals.length}개 → ${filtered.length}개');
    }
    
    return filtered;
  }

  // 특정 호선의 도착정보만 필터링
  List<SubwayArrival> getArrivalsByLine(String targetSubwayId) {
    return departureArrivalInfo
        .where((arrival) => arrival.subwayId == targetSubwayId)
        .take(2) // 최대 2개만
        .toList();
  }

  // 경로에서 호선 정보 추출 (환승지에서 호선 정보를 가져옴)
  List<String> getAvailableSubwayLines() {
    List<String> lines = [];
    
    // 환승지에서 호선 정보 추출
    for (var transfer in transferStations) {
      final subwayLines = transfer['subway_lines'] as List?;
      if (subwayLines != null) {
        for (var line in subwayLines) {
          final subwayId = line['subway_id']?.toString() ?? '';
          if (subwayId.isNotEmpty && !lines.contains(subwayId)) {
            lines.add(subwayId);
          }
        }
      }
    }
    
    // 출발지/도착지가 지하철역인 경우에도 호선 정보 추출 가능
    // (현재 데이터 구조에서는 환승지에서만 호선 정보 저장됨)
    
    return lines;
  }

  // 호선별로 그룹화된 도착정보
  Map<String, List<SubwayArrival>> get groupedArrivalInfo {
    final Map<String, List<SubwayArrival>> grouped = {};
    
    for (final arrival in departureArrivalInfo) {
      final lineKey = arrival.lineDisplayName;
      if (!grouped.containsKey(lineKey)) {
        grouped[lineKey] = [];
      }
      grouped[lineKey]!.add(arrival);
    }
    
    return grouped;
  }

  // 경로 설정 화면으로 이동
  void goToRouteSettings() {
    Get.toNamed('/route-setup');
  }

  // 모든 도착정보 새로고침
  Future<void> refreshAllArrivalInfo() async {
    print('🔄 모든 도착정보 새로고침 시작');
    await loadAllArrivalInfo();
    print('✅ 모든 도착정보 새로고침 완료');
  }

  // 🧪 지하철 도착정보 API 테스트 - 호선별 그룹화
  Future<void> testSubwayArrivalApi() async {
    print('🚇 지하철 도착정보 API 테스트 시작 (호선별 그룹화)');
    
    // 테스트용 역명들 (주요역)
    final testStations = ['서울', '강남', '홍대입구'];
    
    for (final station in testStations) {
      print('\n📍 $station역 실시간 도착정보 테스트');
      try {
        final arrivals = await SubwayService.getRealtimeArrival(station);
        
        if (arrivals.isNotEmpty) {
          print('✅ $station역 도착정보 조회 성공: ${arrivals.length}개');
          
          // 🚇 호선별로 그룹화
          final Map<String, List<SubwayArrival>> groupedByLine = {};
          for (final arrival in arrivals) {
            final lineKey = arrival.lineDisplayName;
            if (!groupedByLine.containsKey(lineKey)) {
              groupedByLine[lineKey] = [];
            }
            groupedByLine[lineKey]!.add(arrival);
          }
          
          print('📊 호선별 분류: ${groupedByLine.keys.join(", ")}');
          
          // 호선별로 출력
          for (final lineEntry in groupedByLine.entries) {
            final lineName = lineEntry.key;
            final lineArrivals = lineEntry.value;
            
            print('\n🚊 $lineName (${lineArrivals.length}개 열차)');
            
            // 방향별로 추가 그룹화
            final Map<String, List<SubwayArrival>> groupedByDirection = {};
            for (final arrival in lineArrivals) {
              final directionKey = '${arrival.cleanTrainLineNm}';
              if (!groupedByDirection.containsKey(directionKey)) {
                groupedByDirection[directionKey] = [];
              }
              groupedByDirection[directionKey]!.add(arrival);
            }
            
            for (final dirEntry in groupedByDirection.entries) {
              final direction = dirEntry.key;
              final dirArrivals = dirEntry.value;
              
              print('   📍 $direction');
              
              for (int i = 0; i < dirArrivals.length; i++) {
                final arrival = dirArrivals[i];
                print('      ${i + 1}. ${arrival.arrivalStatusIcon} ${arrival.arrivalTimeText}');
                print('         방향: ${arrival.directionText} | 열차: ${arrival.btrainNo}');
                print('         상태: ${arrival.detailedArrivalInfo}');
                
                if (arrival.barvlDt > 0) {
                  print('         실시간: ${arrival.getUpdatedArrivalTime(0)}');
                }
                
                if (arrival.isLastTrain) {
                  print('         🚨 막차');
                }
                
                // 추가 정보들
                print('         [DEBUG] subwayId: ${arrival.subwayId}, arvlCd: ${arrival.arvlCd}');
                print('         [DEBUG] 종착역: ${arrival.bstatnNm}, 열차종류: ${arrival.btrainSttus}');
              }
            }
          }
          
        } else {
          print('❌ $station역 도착정보 없음 또는 오류');
        }
        
        // API 호출 간격 (너무 빠르게 호출하지 않도록)
        await Future.delayed(const Duration(seconds: 2));
        
      } catch (e) {
        print('❌ $station역 API 호출 오류: $e');
      }
    }
    
    print('\n🏁 지하철 도착정보 API 테스트 완료');
  }

  // 환승지들 실시간 도착정보 로딩
  Future<void> loadTransferArrivalInfo() async {
    try {
      isLoadingTransferArrival.value = true;
      transferArrivalError.value = '';
      
      List<List<SubwayArrival>> allTransferArrivals = [];
      
      for (int i = 0; i < transferStations.length; i++) {
        final transferStation = transferStations[i];
        final type = transferStation['type'] ?? 'subway';
        final stationCode = transferStation['code'] ?? '';
        final lineInfo = transferStation['lineInfo'] ?? '';
        final stationName = transferStation['name']?.toString() ?? '';
        
        print('🚦 환승지 ${i + 1} 도착정보 로딩 시작: $stationName (type: $type, code: $stationCode)');
        
        if (stationName.isNotEmpty) {
          try {
            if (type == 'bus') {
              // 버스 도착정보 로딩 (별도 저장소에 저장)
              await _loadBusArrivalInfo('transfer_${i}', transferStation);
              // 버스인 경우 지하철 도착정보는 빈 배열로 설정
              allTransferArrivals.add([]);
              print('✅ 환승지 ${i + 1} 버스 도착정보 완료');
            } else if (type == 'subway') {
              // 지하철 도착정보 로딩
              String cleanStationName = _cleanStationName(stationName);
              final allArrivals = await SubwaySearchService.getArrivalInfo(cleanStationName);
              final filteredArrivals = _filterArrivalsByLine(allArrivals, stationName);
              allTransferArrivals.add(filteredArrivals);
              print('✅ 환승지 ${i + 1} 지하철 도착정보 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
            } else {
              allTransferArrivals.add([]);
            }
          } catch (e) {
            print('❌ 환승지 ${i + 1} 도착정보 로딩 오류: $e');
            allTransferArrivals.add([]);
          }
        } else {
          allTransferArrivals.add([]);
        }
      }
      
      transferArrivalInfo.value = allTransferArrivals;
      
    } catch (e) {
      transferArrivalError.value = '환승지 도착정보 로딩 실패';
      print('❌ 환승지 도착정보 전체 로딩 오류: $e');
    } finally {
      isLoadingTransferArrival.value = false;
    }
  }

  // 도착지 실시간 도착정보 로딩
  Future<void> loadDestinationArrivalInfo() async {
    if (arrivalStation.value.isEmpty) return;
    
    // 현재 활성 경로에서 도착지 데이터 가져오기
    final savedRoutes = _storage.read<List>('saved_routes');
    Map<String, dynamic>? destinationData;
    
    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      final activeRoute = savedRoutes.firstWhere(
        (route) => (route as Map)['id'] == activeRouteId.value,
        orElse: () => savedRoutes.first,
      ) as Map<String, dynamic>;
      
      destinationData = activeRoute['arrival'] as Map<String, dynamic>?;
    }
    
    if (destinationData == null) {
      print('⚠️ 도착지 상세 데이터를 찾을 수 없습니다');
      return;
    }
    
    final type = destinationData['type'] ?? 'subway';
    final stationCode = destinationData['code'] ?? '';
    final lineInfo = destinationData['lineInfo'] ?? '';
    
    print('🚦 도착지 도착정보 로딩 시작: ${destinationData['name']} (type: $type, code: $stationCode)');
    
    try {
      isLoadingDestinationArrival.value = true;
      destinationArrivalError.value = '';
      
      if (type == 'bus') {
        await _loadBusArrivalInfo('destination', destinationData);
        // 버스인 경우 지하철 도착정보 클리어
        destinationArrivalInfo.clear();
      } else if (type == 'subway') {
        await _loadSubwayArrivalInfo('destination', destinationData);
        // 지하철 도착정보 로딩
        String cleanStationName = _cleanStationName(arrivalStation.value);
        final allArrivals = await SubwaySearchService.getArrivalInfo(cleanStationName);
        final filteredArrivals = _filterArrivalsByLine(allArrivals, arrivalStation.value);
        
        if (filteredArrivals.isNotEmpty) {
          destinationArrivalInfo.value = filteredArrivals;
          print('✅ 도착지 지하철 도착정보 로딩 성공: ${allArrivals.length}개 → 필터링 후 ${filteredArrivals.length}개');
        } else {
          destinationArrivalInfo.clear();
          destinationArrivalError.value = '도착정보가 없습니다';
          print('⚠️ 도착지 지하철 도착정보 없음 (전체 ${allArrivals.length}개 → 필터링 후 0개)');
        }
      }
      
    } catch (e) {
      destinationArrivalError.value = '도착정보 로딩 실패';
      destinationArrivalInfo.clear();
      print('❌ 도착지 도착정보 로딩 오류: $e');
    } finally {
      isLoadingDestinationArrival.value = false;
    }
  }
}