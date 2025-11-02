import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API 상수 및 설정 모음
class ApiConstants {
  // ===== 기상청 API =====
  static const String weatherBaseUrl = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';
  static String get weatherApiKey => dotenv.get('WEATHER_API_KEY', fallback: '');

  static const String getVilageFcst = '/getVilageFcst';           // 단기예보
  static const String getUltraSrtNcst = '/getUltraSrtNcst';       // 초단기실황

  // 기상청 API 파라미터
  static const String weatherDataType = 'json';
  static const int weatherPageNo = 1;
  static const int weatherFcstNumOfRows = 300;        // 예보 조회 행 수
  static const int weatherCurrentNumOfRows = 10;      // 현재 조회 행 수

  // 기상청 예보 카테고리
  static const Map<String, String> weatherCategory = {
    'TMP': '기온',
    'REH': '습도',
    'PCP': '강수량',
    'SKY': '하늘상태',
    'PTY': '강수형태',
    'UUU': '동쪽 바람성분',
    'VVV': '북쪽 바람성분',
    'VEC': '풍향',
    'WSD': '풍속',
  };

  // ===== 카카오 API =====
  static const String kakaoBaseUrl = 'https://dapi.kakao.com/v2/local';
  static String get kakaoApiKey => dotenv.get('KAKAO_REST_API_KEY', fallback: '');

  static const String searchKeyword = '/search/keyword.json';
  static const String searchAddress = '/search/address.json';
  static const String searchCategory = '/search/category.json';
  static const String coord2Address = '/geo/coord2address.json';

  // 카카오 API 기본 파라미터
  static const int kakaoSearchSize = 10;
  static const int kakaoCategorySize = 15;
  static const int kakaoSearchRadius = 1000;        // 반경 1km
  static const String kakaoSearchSort = 'distance';  // 거리순

  // 카카오 카테고리 코드
  static const Map<String, String> kakaoCategory = {
    'SW8': '지하철역',
    'CE7': '카페',
    'FD6': '음식점',
  };

  // ===== 지하철 API (서울) =====
  static const String seoulSubwayBaseUrl = 'http://swopenAPI.seoul.go.kr/api/subway';
  static String get seoulSubwayApiKey => dotenv.get('SEOUL_SUBWAY_API_KEY', fallback: '');

  static const String getRealtimeStationArrival = '/json/realtimeStationArrival';
  static const int seoulSubwayStartIndex = 0;
  static const int seoulSubwayEndIndex = 10;

  // ===== 버스 API (서울) =====
  static const String seoulBusStationBaseUrl = 'http://apis.data.go.kr/1613000/BusSttnInfoInqireService';
  static const String seoulBusArrivalBaseUrl = 'http://ws.bus.go.kr/api/rest/arrive';
  static String get seoulBusApiKey => dotenv.get('SEOUL_BUS_API_KEY', fallback: '');

  static const String getCrdntPrxmtSttnList = '/getCrdntPrxmtSttnList';
  static const String getArrInfoByStId = '/getArrInfoByStId';

  static const int seoulBusSearchNumOfRows = 10;
  static const int seoulBusSearchPageNo = 1;
  static const String seoulBusDataType = 'json';

  // ===== 버스 API (경기도) =====
  static const String gyeonggiBusStationBaseUrl = 'https://apis.data.go.kr/6410000/busstationservice/v2';
  static const String gyeonggiBusArrivalBaseUrl = 'https://apis.data.go.kr/6410000/busarrivalservice/v2';
  static String get gyeonggiBusApiKey => dotenv.get('GYEONGGI_BUS_API_KEY', fallback: '');

  static const String getBusStationAroundListv2 = '/getBusStationAroundListv2';
  static const String getBusArrivalListv2 = '/getBusArrivalListv2';
  static const String getBusArrivalItemv2 = '/getBusArrivalItemv2';

  static const int gyeonggiBusSearchRadius = 500;    // 반경 500m
  static const String gyeonggiBusDataType = 'json';

  // ===== HTTP 설정 =====
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String contentTypeJson = 'application/json';
}