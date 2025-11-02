import 'package:get/get.dart';
import '../../../../core/di/inject_provider.dart';
import '../../../../core/models/weather_info.dart';
import '../../../../core/models/weather_forecast.dart';
import '../../../../core/models/rain_forecast_info.dart';
import '../../domain/usecases/weather_usecases.dart';
import '../../domain/entities/weather_entity.dart';

/// 날씨 관련 Controller
class WeatherController extends GetxController {
  // 날씨 정보
  final Rx<WeatherInfo?> currentWeather = Rx<WeatherInfo?>(null);
  final RxList<WeatherForecast> weatherForecast = <WeatherForecast>[].obs;
  final Rx<RainForecastInfo?> rainForecast = Rx<RainForecastInfo?>(null);

  // 로딩 상태
  final RxBool isWeatherLoading = false.obs;
  final RxString weatherError = ''.obs;
  final RxString loadingMessage = '날씨 정보를 불러오는 중...'.obs;

  // 날씨 데이터 가져오기 (Clean Architecture 기반)
  Future<void> fetchWeatherData(double lat, double lon) async {
    try {
      print('🌐 날씨 API 호출 시작: $lat, $lon');

      // UseCase 주입 받기
      final getWeatherForecastUseCase = inject<GetWeatherForecastUseCase>();
      final analyzeTodayRainForecastUseCase = inject<AnalyzeTodayRainForecastUseCase>();

      // 1. 날씨 예보 조회
      final forecastResult = await getWeatherForecastUseCase(
        GetWeatherForecastParams(latitude: lat, longitude: lon),
      );

      forecastResult.fold(
        (failure) {
          print('❌ 날씨 예보 조회 실패: ${failure.message}');
          weatherError.value = failure.message;
          throw Exception(failure.message);
        },
        (forecastEntities) {
          print('✅ 날씨 예보 조회 성공: ${forecastEntities.length}개');

          // Entity를 화면에서 사용하는 WeatherForecast로 변환
          final forecasts = forecastEntities.map((entity) {
            return WeatherForecast(
              dateTime: entity.dateTime,
              temperature: entity.temperature,
              humidity: entity.humidity,
              precipitation: entity.precipitation,
              skyCondition: entity.skyCondition.toString().split('.').last,
              precipitationType: entity.precipitationType.toString().split('.').last,
            );
          }).toList();

          weatherForecast.value = forecasts;

          // 현재 시간과 가장 가까운 예보 데이터를 현재 날씨로 사용
          final now = DateTime.now();
          final currentForecast = forecasts
              .where((f) => f.dateTime.isAtSameMomentAs(now) || f.dateTime.isAfter(now))
              .firstOrNull;

          if (currentForecast != null) {
            currentWeather.value = WeatherInfo(
              temperature: currentForecast.temperature,
              humidity: currentForecast.humidity,
              precipitation: currentForecast.precipitation,
              skyCondition: currentForecast.skyCondition,
              precipitationType: currentForecast.precipitationType,
            );
            print('✅ 현재 날씨 설정: ${currentForecast.temperature}°C');
          }
        },
      );

      // 2. 비 예보 분석
      final rainResult = await analyzeTodayRainForecastUseCase(
        AnalyzeTodayRainForecastParams(latitude: lat, longitude: lon),
      );

      rainResult.fold(
        (failure) {
          print('⚠️ 비 예보 분석 실패: ${failure.message}');
        },
        (rainEntity) {
          if (rainEntity != null) {
            // Entity를 화면에서 사용하는 RainForecastInfo로 변환
            rainForecast.value = RainForecastInfo(
              willRain: rainEntity.willRain,
              startTime: rainEntity.startTime,
              endTime: rainEntity.endTime,
              message: rainEntity.message,
              advice: rainEntity.advice,
            );
            print('✅ 비 예보: ${rainEntity.message}');
          } else {
            print('ℹ️ 오늘은 비 소식이 없습니다');
          }
        },
      );

    } catch (e) {
      print('❌ 날씨 API 호출 오류: $e');
      weatherError.value = '날씨 정보를 불러올 수 없습니다';
      throw e;
    }
  }

  // 예보용 날씨 아이콘 가져오기
  String getWeatherIconForForecast(WeatherForecast forecast) {
    // 강수 형태 우선 확인
    if (forecast.precipitationType == 'rain' || forecast.precipitationType == 'rainDrop') {
      return '🌧️';
    } else if (forecast.precipitationType == 'snow' || forecast.precipitationType == 'snowDrop') {
      return '🌨️';
    } else if (forecast.precipitationType == 'rainSnow' || forecast.precipitationType == 'rainSnowDrop') {
      return '🌦️';
    }

    // 하늘 상태로 구분
    switch (forecast.skyCondition) {
      case 'clear':
        return '☀️';
      case 'partlyCloudy':
        return '⛅';
      case 'cloudy':
        return '☁️';
      default:
        return '🌤️';
    }
  }

  // 날씨 아이콘 가져오기
  String getWeatherIcon(WeatherInfo? weather) {
    if (weather == null) return '🌤️';

    // 강수 형태 우선 확인
    if (weather.precipitationType == 'rain' || weather.precipitationType == 'rainDrop') {
      return '🌧️';
    } else if (weather.precipitationType == 'snow' || weather.precipitationType == 'snowDrop') {
      return '🌨️';
    } else if (weather.precipitationType == 'rainSnow' || weather.precipitationType == 'rainSnowDrop') {
      return '🌦️';
    }

    // 하늘 상태로 구분
    switch (weather.skyCondition) {
      case 'clear':
        return '☀️';
      case 'partlyCloudy':
        return '⛅';
      case 'cloudy':
        return '☁️';
      default:
        return '🌤️';
    }
  }

  // 날씨 상태 텍스트
  String getWeatherStatusText(WeatherInfo? weather) {
    if (weather == null) return '날씨 정보 없음';

    String status = '날씨';

    // 강수 형태 확인
    if (weather.precipitationType != 'none') {
      switch (weather.precipitationType) {
        case 'rain':
        case 'rainDrop':
          status = '비';
          break;
        case 'snow':
        case 'snowDrop':
          status = '눈';
          break;
        case 'rainSnow':
        case 'rainSnowDrop':
          status = '비/눈';
          break;
        default:
          break;
      }
    }

    return status;
  }
}