import 'package:get/get.dart';

import 'presentation/controllers/onboarding_controller.dart';
import '../home/data/datasources/location_remote_datasource.dart';
import '../home/data/repositories/location_repository_impl.dart';
import '../home/domain/repositories/location_repository.dart';
import '../home/domain/usecases/check_location_permission_usecase.dart';
import '../home/domain/usecases/get_current_location_usecase.dart';
import '../location_search/data/datasources/address_remote_datasource.dart';
import '../location_search/data/repositories/address_repository_impl.dart';
import '../location_search/domain/repositories/address_repository.dart';
import '../location_search/domain/usecases/search_address_usecase.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // 위치 서비스 의존성
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

    // 주소 검색 의존성
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

    // 온보딩 컨트롤러
    Get.put<OnboardingController>(
      OnboardingController(),
    );
  }
}