import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../app/services/weather_service.dart';

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

  @override
  void onInit() {
    super.onInit();
    print('=== 홈 화면 초기화 ===');
    _loadSavedLocation();
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
}