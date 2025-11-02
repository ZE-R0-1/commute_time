import 'package:dartz/dartz.dart';
import '../../../../core/base/usecase.dart';
import '../../../../core/failure/failure.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

// 날씨 예보 조회 UseCase
class GetWeatherForecastUseCase
    extends UseCase<List<WeatherForecastEntity>, GetWeatherForecastParams> {
  final WeatherRepository repository;

  GetWeatherForecastUseCase({required this.repository});

  @override
  Future<Either<Failure, List<WeatherForecastEntity>>> call(
    GetWeatherForecastParams params,
  ) async {
    return await repository.getWeatherForecast(
      params.latitude,
      params.longitude,
    );
  }
}

class GetWeatherForecastParams {
  final double latitude;
  final double longitude;

  GetWeatherForecastParams({
    required this.latitude,
    required this.longitude,
  });
}

// 오늘의 비 예보 분석 UseCase
class AnalyzeTodayRainForecastUseCase
    extends UseCase<RainForecastEntity?, AnalyzeTodayRainForecastParams> {
  final WeatherRepository repository;

  AnalyzeTodayRainForecastUseCase({required this.repository});

  @override
  Future<Either<Failure, RainForecastEntity?>> call(
    AnalyzeTodayRainForecastParams params,
  ) async {
    return await repository.analyzeTodayRainForecast(
      params.latitude,
      params.longitude,
    );
  }
}

class AnalyzeTodayRainForecastParams {
  final double latitude;
  final double longitude;

  AnalyzeTodayRainForecastParams({
    required this.latitude,
    required this.longitude,
  });
}

// 현재 날씨 조회 UseCase
class GetCurrentWeatherUseCase
    extends UseCase<WeatherEntity?, GetCurrentWeatherParams> {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase({required this.repository});

  @override
  Future<Either<Failure, WeatherEntity?>> call(
    GetCurrentWeatherParams params,
  ) async {
    return await repository.getCurrentWeather(
      params.latitude,
      params.longitude,
    );
  }
}

class GetCurrentWeatherParams {
  final double latitude;
  final double longitude;

  GetCurrentWeatherParams({
    required this.latitude,
    required this.longitude,
  });
}