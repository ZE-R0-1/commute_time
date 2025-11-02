import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/weather_entity.dart';

// 날씨 저장소 인터페이스
abstract class WeatherRepository {
  // 날씨 예보 조회
  Future<Either<Failure, List<WeatherForecastEntity>>> getWeatherForecast(
    double latitude,
    double longitude,
  );

  // 오늘의 비 예보 분석
  Future<Either<Failure, RainForecastEntity?>> analyzeTodayRainForecast(
    double latitude,
    double longitude,
  );

  // 현재 날씨 조회
  Future<Either<Failure, WeatherEntity?>> getCurrentWeather(
    double latitude,
    double longitude,
  );
}