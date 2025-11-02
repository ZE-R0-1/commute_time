import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../clients/weather_api_client.dart';
import '../clients/kakao_api_client.dart';
import '../clients/bus_api_client.dart';
import '../clients/subway_api_client.dart';
import '../clients/location_api_client.dart';

/// API 제공자 (GetxController 기반)
/// 모든 API 클라이언트를 관리하고 상태를 제공합니다.
class ApiProvider extends GetxController {
  // API 클라이언트들
  late WeatherApiClient weatherClient;
  late KakaoApiClient kakaoClient;
  late BusApiClient busClient;
  late SubwayApiClient subwayClient;
  late LocationApiClient locationClient;

  // 공통 HTTP 클라이언트
  final http.Client httpClient = http.Client();

  // 로딩 상태
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeClients();
    print('✅ ApiProvider 초기화 완료');
  }

  /// API 클라이언트 초기화
  void _initializeClients() {
    weatherClient = WeatherApiClient(httpClient: httpClient);
    kakaoClient = KakaoApiClient(httpClient: httpClient);
    busClient = BusApiClient(httpClient: httpClient);
    subwayClient = SubwayApiClient(httpClient: httpClient);
    locationClient = LocationApiClient(httpClient: httpClient);

    print('📦 초기화된 API 클라이언트:');
    print('   - WeatherApiClient');
    print('   - KakaoApiClient');
    print('   - BusApiClient');
    print('   - SubwayApiClient');
    print('   - LocationApiClient');
  }

  /// API 호출 실행 헬퍼 메서드
  /// 공통 로딩 상태 및 에러 처리 로직 제공
  Future<T> executeApiCall<T>({
    required Future<T> Function() apiCall,
    bool updateLoading = true,
  }) async {
    try {
      if (updateLoading) {
        isLoading.value = true;
        hasError.value = false;
        errorMessage.value = '';
      }

      final result = await apiCall();
      return result;
    } catch (e) {
      if (updateLoading) {
        hasError.value = true;
        errorMessage.value = e.toString();
      }
      print('❌ API 호출 오류: $e');
      rethrow;
    } finally {
      if (updateLoading) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    httpClient.close();
    super.onClose();
  }
}