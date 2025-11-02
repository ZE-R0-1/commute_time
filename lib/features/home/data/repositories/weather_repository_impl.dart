import 'package:dartz/dartz.dart';
import '../../../../core/exception/exceptions.dart';
import '../../domain/entities/weather_entity.dart';
import '../../../../core/failure/failure.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

// Weather Repository 구현체
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WeatherForecastEntity>>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final forecasts = await remoteDataSource.getWeatherForecast(
        latitude,
        longitude,
      );

      return Right(forecasts.map((e) => e.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(
        message: e.message,
        code: e.code,
      ));
    } on AppException catch (e) {
      return Left(GeneralFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(GeneralFailure(
        message: '날씨 예보 조회 중 알 수 없는 오류가 발생했습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, RainForecastEntity?>> analyzeTodayRainForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final forecasts = await remoteDataSource.getWeatherForecast(
        latitude,
        longitude,
      );

      final entities = forecasts.map((e) => e.toEntity()).toList();
      final rainForecast = _analyzeTodayRainForecast(entities);

      return Right(rainForecast);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } on AppException catch (e) {
      return Left(GeneralFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(GeneralFailure(
        message: '비 예보 분석 중 오류가 발생했습니다',
      ));
    }
  }

  @override
  Future<Either<Failure, WeatherEntity?>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final weather = await remoteDataSource.getCurrentWeather(
        latitude,
        longitude,
      );

      return Right(weather?.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(
        message: e.message,
        code: e.code,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        code: e.code,
      ));
    } on AppException catch (e) {
      return Left(GeneralFailure(
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      return Left(GeneralFailure(
        message: '현재 날씨 조회 중 오류가 발생했습니다',
      ));
    }
  }

  // 오늘의 비 예보 분석 (기존 로직 포팅)
  RainForecastEntity? _analyzeTodayRainForecast(
    List<WeatherForecastEntity> forecasts,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 오늘 예보만 필터링
    final todayForecasts = forecasts
        .where((forecast) =>
            forecast.dateTime.year == today.year &&
            forecast.dateTime.month == today.month &&
            forecast.dateTime.day == today.day &&
            forecast.dateTime.isAfter(now))
        .toList();

    if (todayForecasts.isEmpty) {
      return null;
    }

    // 비가 오는 시간대 찾기
    List<WeatherForecastEntity> rainForecasts = todayForecasts
        .where((forecast) =>
            forecast.precipitationType == PrecipitationType.rain ||
            forecast.precipitationType == PrecipitationType.rainDrop ||
            forecast.precipitationType == PrecipitationType.rainSnow ||
            forecast.precipitationType == PrecipitationType.rainSnowDrop)
        .toList();

    if (rainForecasts.isEmpty) {
      return RainForecastEntity(
        willRain: false,
        message: '오늘은 비 소식이 없어요',
        advice: '쾌적한 하루 되세요!',
      );
    }

    // 첫 번째 비 시작 시간
    final firstRain = rainForecasts.first;
    final startTime = firstRain.dateTime;

    // 비가 끝나는 시간
    DateTime? endTime;
    for (int i = 0; i < todayForecasts.length - 1; i++) {
      final current = todayForecasts[i];
      final next = todayForecasts[i + 1];

      if (_isRaining(current) && !_isRaining(next)) {
        endTime = next.dateTime;
        break;
      }
    }

    return RainForecastEntity(
      willRain: true,
      startTime: startTime,
      endTime: endTime,
      message: _generateRainMessage(startTime, endTime, now),
      advice: _generateRainAdvice(startTime, now),
      intensity: _getRainIntensity(rainForecasts),
    );
  }

  // 비 오는지 확인
  bool _isRaining(WeatherForecastEntity forecast) {
    return forecast.precipitationType == PrecipitationType.rain ||
        forecast.precipitationType == PrecipitationType.rainDrop ||
        forecast.precipitationType == PrecipitationType.rainSnow ||
        forecast.precipitationType == PrecipitationType.rainSnowDrop;
  }

  // 비 예보 메시지 생성
  String _generateRainMessage(
    DateTime startTime,
    DateTime? endTime,
    DateTime now,
  ) {
    final hour = startTime.hour;
    final minute = startTime.minute;

    String timeMessage;
    if (hour < 12) {
      timeMessage = '오전 ${hour}시';
    } else if (hour == 12) {
      timeMessage = '정오';
    } else if (hour < 18) {
      timeMessage = '오후 ${hour - 12}시';
    } else {
      timeMessage = '저녁 ${hour - 12}시';
    }

    if (minute > 0) {
      timeMessage += ' ${minute}분';
    }

    String durationMessage = '';
    if (endTime != null) {
      final duration = endTime.difference(startTime).inHours;
      if (duration > 0) {
        durationMessage = ' (약 ${duration}시간)';
      }
    }

    return '🌧️ ${timeMessage}부터 비 예보$durationMessage';
  }

  // 비 예보 조언 생성
  String _generateRainAdvice(DateTime startTime, DateTime now) {
    final hoursUntilRain = startTime.difference(now).inHours;

    if (hoursUntilRain <= 1) {
      return '곧 비가 시작돼요! 우산을 미리 준비하세요';
    } else if (hoursUntilRain <= 3) {
      return '우산을 챙기시고 일찍 출발하는 것을 권장드려요';
    } else if (hoursUntilRain <= 6) {
      return '오늘은 우산을 꼭 챙겨주세요';
    } else {
      return '나중에 비가 올 예정이니 우산을 준비해두세요';
    }
  }

  // 비 강도 분석
  RainIntensity _getRainIntensity(List<WeatherForecastEntity> rainForecasts) {
    final hasHeavyRain = rainForecasts.any((forecast) =>
        forecast.precipitation != '0' &&
        forecast.precipitation.contains('mm') &&
        double.tryParse(forecast.precipitation.replaceAll('mm', '')) != null &&
        double.parse(forecast.precipitation.replaceAll('mm', '')) > 5.0);

    if (hasHeavyRain) {
      return RainIntensity.heavy;
    } else {
      return RainIntensity.light;
    }
  }
}