import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// API
import '../api/services/api_provider.dart';

// Home Feature - Data Layer
import '../../features/home/data/datasources/weather_remote_datasource.dart';
import '../../features/home/data/repositories/weather_repository_impl.dart';

// Home Feature - Domain Layer
import '../../features/home/domain/repositories/weather_repository.dart';
import '../../features/home/domain/usecases/weather_usecases.dart';

// GetIt 인스턴스
final getIt = GetIt.instance;

// DI 초기화
Future<void> setupDependencies() async {
  // ===== API Provider (GetX) =====
  // ApiProvider를 GetX로 등록 (permanent: true로 앱 전체 생명주기)
  Get.put<ApiProvider>(ApiProvider(), permanent: true);

  // ===== External (외부 패키지) =====
  getIt.registerSingleton<http.Client>(
    http.Client(),
  );

  // ===== Data Layer =====
  // DataSource
  getIt.registerSingleton<WeatherRemoteDataSource>(
    WeatherRemoteDataSourceImpl(),
  );

  // Repository
  getIt.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(remoteDataSource: getIt<WeatherRemoteDataSource>()),
  );

  // ===== Domain Layer - UseCases =====
  getIt.registerSingleton<GetWeatherForecastUseCase>(
    GetWeatherForecastUseCase(repository: getIt<WeatherRepository>()),
  );

  getIt.registerSingleton<AnalyzeTodayRainForecastUseCase>(
    AnalyzeTodayRainForecastUseCase(repository: getIt<WeatherRepository>()),
  );

  getIt.registerSingleton<GetCurrentWeatherUseCase>(
    GetCurrentWeatherUseCase(repository: getIt<WeatherRepository>()),
  );

  print('✅ DI 컨테이너 초기화 완료');
  print('📦 등록된 의존성:');
  print('   - ApiProvider (GetX)');
  print('   - WeatherRemoteDataSource');
  print('   - WeatherRepository');
  print('   - GetWeatherForecastUseCase');
  print('   - AnalyzeTodayRainForecastUseCase');
  print('   - GetCurrentWeatherUseCase');
}

// 의존성 주입을 위한 inject 함수
T inject<T extends Object>() => getIt.get<T>();