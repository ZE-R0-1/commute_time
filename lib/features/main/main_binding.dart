import 'package:get/get.dart';

import 'presentation/controllers/main_controller.dart';
import '../home/presentation/controllers/home_controller.dart';
import '../home/presentation/controllers/weather_controller.dart';
import '../home/presentation/controllers/route_controller.dart';
import '../home/presentation/controllers/location_controller.dart';
import '../home/presentation/controllers/arrival_controller.dart';
import '../route_setup/presentation/controllers/route_setup_controller.dart';
import '../settings/presentation/controllers/settings_controller.dart';
import '../location_search/data/datasources/subway_remote_datasource.dart';
import '../location_search/data/datasources/seoul_bus_arrival_remote_datasource.dart';
import '../location_search/data/datasources/bus_arrival_remote_datasource.dart';
import '../location_search/data/repositories/subway_repository_impl.dart';
import '../location_search/data/repositories/seoul_bus_arrival_repository_impl.dart';
import '../location_search/data/repositories/bus_arrival_repository_impl.dart';
import '../location_search/domain/repositories/subway_repository.dart';
import '../location_search/domain/repositories/seoul_bus_arrival_repository.dart';
import '../location_search/domain/repositories/bus_arrival_repository.dart';
import '../location_search/domain/usecases/get_subway_arrival_usecase.dart';
import '../location_search/domain/usecases/get_seoul_bus_arrival_usecase.dart';
import '../location_search/domain/usecases/get_bus_arrival_item_usecase.dart';
import '../location_search/data/datasources/address_remote_datasource.dart';
import '../location_search/data/repositories/address_repository_impl.dart';
import '../location_search/domain/repositories/address_repository.dart';
import '../location_search/domain/usecases/search_address_usecase.dart';
import '../location_search/data/datasources/map_remote_datasource.dart';
import '../location_search/data/repositories/map_repository_impl.dart';
import '../location_search/domain/repositories/map_repository.dart';
import '../location_search/domain/usecases/search_places_usecase.dart';
import '../location_search/domain/usecases/get_address_from_coordinate_usecase.dart';
import '../location_search/domain/usecases/search_nearby_places_usecase.dart';
import '../home/data/datasources/location_remote_datasource.dart';
import '../home/data/repositories/location_repository_impl.dart';
import '../home/domain/repositories/location_repository.dart';
import '../home/domain/usecases/check_location_permission_usecase.dart';
import '../home/domain/usecases/get_current_location_usecase.dart';
import '../home/domain/usecases/get_last_known_location_usecase.dart';
import '../home/domain/usecases/calculate_location_distance_usecase.dart';
import '../home/domain/usecases/is_near_home_usecase.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Location Search 의존성 등록 (Subway Arrival)
    Get.lazyPut<SubwayRemoteDataSource>(
      () => SubwayRemoteDataSourceImpl(),
    );
    Get.lazyPut<SubwayRepository>(
      () => SubwayRepositoryImpl(
        remoteDataSource: Get.find<SubwayRemoteDataSource>(),
      ),
    );
    Get.lazyPut<GetSubwayArrivalUseCase>(
      () => GetSubwayArrivalUseCase(repository: Get.find<SubwayRepository>()),
    );

    // Location Search 의존성 등록 (Seoul Bus Arrival)
    Get.lazyPut<SeoulBusArrivalRemoteDataSource>(
      () => SeoulBusArrivalRemoteDataSourceImpl(),
    );
    Get.lazyPut<SeoulBusArrivalRepository>(
      () => SeoulBusArrivalRepositoryImpl(
        remoteDataSource: Get.find<SeoulBusArrivalRemoteDataSource>(),
      ),
    );
    Get.lazyPut<GetSeoulBusArrivalUseCase>(
      () => GetSeoulBusArrivalUseCase(repository: Get.find<SeoulBusArrivalRepository>()),
    );

    // Location Search 의존성 등록 (Bus Arrival Item)
    Get.lazyPut<BusArrivalRemoteDataSource>(
      () => BusArrivalRemoteDataSourceImpl(),
    );
    Get.lazyPut<BusArrivalRepository>(
      () => BusArrivalRepositoryImpl(
        remoteDataSource: Get.find<BusArrivalRemoteDataSource>(),
      ),
    );
    Get.lazyPut<GetBusArrivalItemUseCase>(
      () => GetBusArrivalItemUseCase(repository: Get.find<BusArrivalRepository>()),
    );

    // Location Search 의존성 등록 (Address Search)
    Get.lazyPut<AddressRemoteDataSource>(
      () => AddressRemoteDataSourceImpl(),
    );
    Get.lazyPut<AddressRepository>(
      () => AddressRepositoryImpl(
        remoteDataSource: Get.find<AddressRemoteDataSource>(),
      ),
    );
    Get.lazyPut<SearchAddressUseCase>(
      () => SearchAddressUseCase(repository: Get.find<AddressRepository>()),
    );

    // 지도 검색 의존성 등록 (Map Search)
    Get.lazyPut<MapRemoteDataSource>(
      () => MapRemoteDataSourceImpl(),
    );
    Get.lazyPut<MapRepository>(
      () => MapRepositoryImpl(
        remoteDataSource: Get.find<MapRemoteDataSource>(),
      ),
    );
    Get.lazyPut<SearchPlacesUseCase>(
      () => SearchPlacesUseCase(repository: Get.find<MapRepository>()),
    );
    Get.lazyPut<GetAddressFromCoordinateUseCase>(
      () => GetAddressFromCoordinateUseCase(repository: Get.find<MapRepository>()),
    );
    Get.lazyPut<SearchNearbyPlacesUseCase>(
      () => SearchNearbyPlacesUseCase(repository: Get.find<MapRepository>()),
    );

    // 위치 서비스 의존성 등록
    Get.lazyPut<LocationRemoteDataSource>(
      () => LocationRemoteDataSourceImpl(),
    );
    Get.lazyPut<LocationRepository>(
      () => LocationRepositoryImpl(
        remoteDataSource: Get.find<LocationRemoteDataSource>(),
      ),
    );
    Get.lazyPut<CheckLocationPermissionUseCase>(
      () => CheckLocationPermissionUseCase(repository: Get.find<LocationRepository>()),
    );
    Get.lazyPut<GetCurrentLocationUseCase>(
      () => GetCurrentLocationUseCase(repository: Get.find<LocationRepository>()),
    );
    Get.lazyPut<GetLastKnownLocationUseCase>(
      () => GetLastKnownLocationUseCase(repository: Get.find<LocationRepository>()),
    );
    Get.lazyPut<CalculateLocationDistanceUseCase>(
      () => CalculateLocationDistanceUseCase(repository: Get.find<LocationRepository>()),
    );
    Get.lazyPut<IsNearHomeUseCase>(
      () => IsNearHomeUseCase(repository: Get.find<LocationRepository>()),
    );

    // 메인 컨트롤러
    Get.put<MainController>(
      MainController(),
      permanent: true, // 앱 생명주기 동안 유지
    );

    // 홈 화면 개별 컨트롤러들 (순서대로 등록)
    Get.put<WeatherController>(
      WeatherController(),
      permanent: true,
    );

    Get.put<RouteController>(
      RouteController(),
      permanent: true,
    );

    Get.put<LocationController>(
      LocationController(),
      permanent: true,
    );

    Get.put<ArrivalController>(
      ArrivalController(
        getSubwayArrivalUseCase: Get.find<GetSubwayArrivalUseCase>(),
        getBusArrivalItemUseCase: Get.find<GetBusArrivalItemUseCase>(),
        getSeoulBusArrivalUseCase: Get.find<GetSeoulBusArrivalUseCase>(),
      ),
      permanent: true,
    );

    // 홈 화면 통합 컨트롤러
    Get.put<HomeController>(
      HomeController(),
      permanent: true,
    );

    // 경로 설정 화면 컨트롤러
    Get.lazyPut<RouteSetupController>(
          () => RouteSetupController(),
    );


    // 설정 화면 컨트롤러
    Get.lazyPut<SettingsController>(
          () => SettingsController(),
    );
  }
}