import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/subway_remote_datasource.dart';
import 'data/datasources/map_remote_datasource.dart';
import 'data/datasources/gyeonggi_bus_remote_datasource.dart';
import 'data/datasources/seoul_bus_remote_datasource.dart';
import 'data/datasources/bus_arrival_remote_datasource.dart';
import 'data/datasources/seoul_bus_arrival_remote_datasource.dart';
import 'data/repositories/subway_repository_impl.dart';
import 'data/repositories/map_repository_impl.dart';
import 'data/repositories/bus_repository_impl.dart';
import 'data/repositories/bus_arrival_repository_impl.dart';
import 'data/repositories/seoul_bus_arrival_repository_impl.dart';
import 'domain/repositories/subway_repository.dart';
import 'domain/repositories/map_repository.dart';
import 'domain/repositories/bus_repository.dart';
import 'domain/repositories/bus_arrival_repository.dart';
import 'domain/repositories/seoul_bus_arrival_repository.dart';
import 'domain/usecases/search_subway_stations_usecase.dart';
import 'domain/usecases/get_subway_arrival_usecase.dart';
import 'domain/usecases/search_places_usecase.dart';
import 'domain/usecases/search_nearby_bus_stops_usecase.dart';
import 'domain/usecases/get_bus_arrival_info_usecase.dart';
import 'domain/usecases/get_bus_arrival_item_usecase.dart';
import 'domain/usecases/get_seoul_bus_arrival_usecase.dart';
import 'presentation/controllers/location_search_controller.dart';

class LocationSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<SubwayRemoteDataSource>(
      () => SubwayRemoteDataSourceImpl(),
    );

    Get.lazyPut<MapRemoteDataSource>(
      () => MapRemoteDataSourceImpl(),
    );

    Get.lazyPut<GyeonggiBusRemoteDataSource>(
      () => GyeonggiBusRemoteDataSourceImpl(),
    );

    Get.lazyPut<SeoulBusRemoteDataSource>(
      () => SeoulBusRemoteDataSourceImpl(),
    );

    Get.lazyPut<BusArrivalRemoteDataSource>(
      () => BusArrivalRemoteDataSourceImpl(),
    );

    Get.lazyPut<SeoulBusArrivalRemoteDataSource>(
      () => SeoulBusArrivalRemoteDataSourceImpl(),
    );

    // Repositories
    Get.lazyPut<SubwayRepository>(
      () => SubwayRepositoryImpl(
        remoteDataSource: Get.find<SubwayRemoteDataSource>(),
      ),
    );

    Get.lazyPut<MapRepository>(
      () => MapRepositoryImpl(
        remoteDataSource: Get.find<MapRemoteDataSource>(),
      ),
    );

    Get.lazyPut<BusRepository>(
      () => BusRepositoryImpl(
        gyeonggiBusRemoteDataSource: Get.find<GyeonggiBusRemoteDataSource>(),
        seoulBusRemoteDataSource: Get.find<SeoulBusRemoteDataSource>(),
      ),
    );

    Get.lazyPut<BusArrivalRepository>(
      () => BusArrivalRepositoryImpl(
        remoteDataSource: Get.find<BusArrivalRemoteDataSource>(),
      ),
    );

    Get.lazyPut<SeoulBusArrivalRepository>(
      () => SeoulBusArrivalRepositoryImpl(
        remoteDataSource: Get.find<SeoulBusArrivalRemoteDataSource>(),
      ),
    );

    // Usecases
    Get.lazyPut<SearchSubwayStationsUseCase>(
      () => SearchSubwayStationsUseCase(repository: Get.find<SubwayRepository>()),
    );

    Get.lazyPut<GetSubwayArrivalUseCase>(
      () => GetSubwayArrivalUseCase(repository: Get.find<SubwayRepository>()),
    );

    Get.lazyPut<SearchPlacesUseCase>(
      () => SearchPlacesUseCase(repository: Get.find<MapRepository>()),
    );

    Get.lazyPut<SearchNearbyBusStopsUseCase>(
      () => SearchNearbyBusStopsUseCase(repository: Get.find<BusRepository>()),
    );

    // 버스 도착정보는 여러 번 호출되므로 put() 사용 (삭제되지 않음)
    Get.put<GetBusArrivalInfoUseCase>(
      GetBusArrivalInfoUseCase(repository: Get.find<BusArrivalRepository>()),
    );

    Get.put<GetBusArrivalItemUseCase>(
      GetBusArrivalItemUseCase(repository: Get.find<BusArrivalRepository>()),
    );

    Get.put<GetSeoulBusArrivalUseCase>(
      GetSeoulBusArrivalUseCase(repository: Get.find<SeoulBusArrivalRepository>()),
    );

    // Controller
    Get.lazyPut<LocationSearchController>(
      () => LocationSearchController(
        searchSubwayStationsUseCase: Get.find<SearchSubwayStationsUseCase>(),
        getSubwayArrivalUseCase: Get.find<GetSubwayArrivalUseCase>(),
        searchPlacesUseCase: Get.find<SearchPlacesUseCase>(),
        searchNearbyBusStopsUseCase: Get.find<SearchNearbyBusStopsUseCase>(),
      ),
    );
  }
}