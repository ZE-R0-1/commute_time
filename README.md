# 출퇴근타임 (Commute Time)

> 스마트한 출퇴근 경로 관리를 위한 Flutter 앱

[![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=flat&logo=dart&logoColor=white)](https://dart.dev)
[![GetX](https://img.shields.io/badge/GetX-4.6+-9C27B0?style=flat&logo=flutter&logoColor=white)](https://pub.dev/packages/get)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-green?style=flat&logo=architecture&logoColor=white)](https://resocoder.com/clean-architecture-tdd)

---

## 📱 스크린샷

<table>
  <tr>
    <td><img src="assets/screenshot/1.png" alt="온보딩 화면" /></td>
    <td><img src="assets/screenshot/2.png" alt="홈 화면" /></td>
    <td><img src="assets/screenshot/3.png" alt="경로 추가" /></td>
  </tr>
  <tr>
    <td><img src="assets/screenshot/4.png" alt="경로 설정" /></td>
    <td><img src="assets/screenshot/5.png" alt="출발지 설정" /></td>
  </tr>
</table>

---

## 🎯 프로젝트 소개

**출퇴근타임**은 서울과 경기도 지역의 대중교통(지하철, 버스)을 이용하는 직장인과 학생들을 위한 **실시간 출퇴근 경로 관리 앱**입니다.

사용자의 출발지, 도착지, 환승지를 저장하고 **매일 아침 그 경로의 실시간 교통 정보(지하철 도착시간, 버스 도착 예정시간)를 자동으로 표시**합니다. 뿐만 아니라 **현재 위치 기반 날씨 정보와 강수 예보**도 함께 제공하여 출근 준비를 더욱 스마트하게 할 수 있습니다.

### 🌟 주요 특징

- **실시간 교통 정보** - 지하철/버스 도착정보를 1초 단위로 실시간 갱신
- **지능형 경로 관리** - 출발지, 환승지, 도착지를 포함한 출퇴근 경로 저장 및 관리
- **날씨 연동** - 기상청 API 기반 현재 날씨, 시간별 예보, 강수 분석
- **개인화 설정** - 근무시간, 알림 설정, 테마 커스터마이징

---

## 🏗️ 아키텍처 개요

### Clean Architecture + GetX 패턴

본 프로젝트는 **Clean Architecture** 원칙을 따르며 **GetX** 상태관리 프레임워크를 활용합니다.

```
Domain Layer (비즈니스 로직)
    ↑ ↓
Data Layer (데이터 관리)
    ↑ ↓
Presentation Layer (UI & 상태)
```

#### 계층별 책임:

| 계층 | 책임 | 주요 요소 |
|------|------|---------|
| **Domain** | 비즈니스 로직 | Entities, UseCases, Repositories (interface) |
| **Data** | 데이터 관리 | Models (DTO), RemoteDataSource, Repositories (impl) |
| **Presentation** | UI 및 상태 | Controllers (GetX), Widgets, Bindings |

#### 의존성 흐름:
```
UI (Widgets)
  ↓
Controllers (GetX State Management)
  ↓
UseCases (Business Logic)
  ↓
Repositories (Data Abstraction)
  ↓
DataSources (Remote/Local)
  ↓
APIs & Local Storage
```

---

## 📊 주요 기능 상세

### 🏠 홈 화면 (실시간 경로 정보)

**핵심 기능:**
- **실시간 도착정보 표시**
  - 출발지, 환승지, 도착지의 실시간 도착정보
  - 지하철: 호선별, 방면별 필터링
  - 버스: 서울/경기도 버스 통합 도착정보
  - 자동 갱신 (새로고침 버튼 또는 경로 변경 시)

- **날씨 정보**
  - 현재 위치 기반 날씨 (기온, 습도, 강수량)
  - 12시간 시간별 날씨 예보
  - 강수 시간대 분석 및 우산 알림

- **경로 카드**
  - 활성 경로 한눈에 확인
  - 경로명, 출발지, 도착지 표시
  - 경로 변경 버튼

**기술 구현:**
- `HomeController`: 홈 화면 조율 및 상태관리
- `WeatherController`: 날씨 데이터 관리
- `RouteController`: 경로 데이터 관리
- `LocationController`: GPS 및 위치 권한 관리
- `ArrivalController`: 실시간 도착정보 관리

---

### 🛣️ 경로 설정 (CRUD 기능)

**핵핵심 기능:**
- **경로 추가/수정/삭제**
  - 여러 개의 출퇴근 경로 저장 (집↔회사, 집↔학교 등)
  - 경로별 이름 지정 가능
  - 활성 경로 선택

- **출발지/도착지 검색**
  - 카카오 로컬 API 기반 통합 장소 검색
  - 지하철역과 버스 정류장 동시 검색
  - 검색 결과에서 교통수단 선택 (지하철/버스)

- **환승지 추가**
  - 최대 여러 개의 환승 정류장 설정
  - 호선 및 방면 선택
  - 환승지별 도착정보 표시

**데이터 구조:**
```dart
{
  'id': 'route_001',
  'name': '집-회사',
  'departure': {
    'name': '강남역',
    'type': 'subway',
    'lineInfo': '2호선',
    'code': '1002',
    'cityCode': '...',  // 서울 버스용
    'routeId': '...',   // 경기도 버스용
    'staOrder': 1       // 경기도 버스용
  },
  'arrival': { ... },
  'transfers': [ ... ]
}
```

**기술 구현:**
- `RouteSetupController`: 경로 CRUD 관리
- GetStorage: 경로 데이터 영속성

---

### 🔍 위치 검색 (Location Search)

**핵심 기능:**
- **통합 장소 검색**
  - 카카오 로컬 API를 통한 주소/장소 검색
  - 지하철역 검색 (서울 1~9호선, 신분당선 등)
  - 버스 정류장 검색 (서울/경기도)
  - 검색 결과에서 실시간 도착정보 조회

- **카카오맵 통합**
  - 네이티브 카카오맵 표시
  - 위치 마커 표시
  - 맵에서 위치 선택

- **스마트 검색**
  - 카테고리별 필터링 (지하철/버스)
  - 거리순 정렬
  - 실시간 입력 기반 검색 (디바운싱 적용)

**기술 구현:**
- `LocationSearchController`: 검색 상태 및 로직
- Kakao Local API: 장소 검색
- Kakao Map Plugin: 네이티브 맵 연동

---

### 🌤️ 날씨 정보 (Weather Integration)

**핵심 기능:**
- **기상청 API 기반 날씨**
  - 현재 날씨 (기온, 습도, 강수량, 하늘상태)
  - 12시간 시간별 예보
  - 격자 좌표 변환 (위도/경도 → 기상청 격자)

- **강수 분석**
  - 오늘의 강수 시간대 분석
  - 강수 강도 분류 (약/중/강)
  - 출근/퇴근 시간 강수 예보 알림

- **위치 기반 갱신**
  - GPS를 통한 자동 위치 감지
  - 저장된 위치 기반 날씨 (GPS 불가 시)
  - 수동 새로고침 기능

**기술 구현:**
- `WeatherController`: 날씨 상태관리
- `WeatherRemoteDataSource`: KMA API 통신
- `GetWeatherForecastUseCase`: 비즈니스 로직
- Geolocator: GPS 위치 서비스
- Geocoding: 좌표↔주소 변환

---

### ⚙️ 설정 (Settings)

**핵심 기능:**
- **근무시간 설정** - 출근/퇴근 시간 관리
- **알림 설정** - 출발 시간, 날씨 변화, 교통 장애 알림
- **테마 설정** - 라이트/다크 모드
- **앱 정보** - 버전, 라이선스 정보

---

### 🎬 온보딩 (First-time Setup)

**핵심 기능:**
- **다단계 설정 마법사**
  1. 경로 설정 (출발지, 도착지, 환승지)
  2. 근무시간 설정
  3. 알림 권한 요청
  4. 설정 완료

- **초기 데이터 저장**
  - 첫 경로 저장
  - 기본 설정 초기화
  - GetStorage에 데이터 영속화

**기술 구현:**
- `OnboardingController`: 온보딩 상태관리
- Multi-step form with validation

---

## 🔗 API 통합 (8개 API)

### 1️⃣ 기상청 API (Weather)
- **엔드포인트**: `/getVilageFcst`, `/getUltraSrtNcst`
- **기능**: 단기예보, 초단기실황
- **구현**: `WeatherApiClient`, `WeatherRemoteDataSource`

```dart
// 격자 좌표 변환
double latitude = 37.4979;
double longitude = 127.0276;
// ↓ 변환
int gridX = 127, gridY = 60;  // 기상청 격자좌표
```

---

### 2️⃣ 카카오 로컬 API (Kakao Local)
- **엔드포인트**: `/search/keyword.json`, `/search/address.json`, `/geo/coord2address.json`
- **기능**: 장소/주소 검색, 역지오코딩
- **구현**: `KakaoApiClient`, `MapRemoteDataSource`

```dart
// 키워드로 장소 검색
GET /search/keyword.json?query=강남역&radius=1000
// 반환: [{ name, addressName, latitude, longitude, distance }]
```

---

### 3️⃣ 카카오맵 플러그인 (Kakao Maps)
- **기능**: 네이티브 맵 표시, 마커 관리, 위치 추적
- **구현**: `LocationSearchController`, `KakaoMapController`

---

### 4️⃣ 서울 지하철 API (Seoul Subway)
- **엔드포인트**: `/api/subway/{API_KEY}/json/realtimeStationArrival/{stationName}`
- **기능**: 역별 실시간 도착정보
- **구현**: `SubwayApiClient`, `SubwayRemoteDataSource`

```dart
// 강남역 도착정보
GET /realtimeStationArrival/0/10/강남
// 반환: [{
//   subwayLine,    // 호선
//   destination,   // 방면
//   remainTime,    // 도착까지 시간
//   trainPosition  // 열차 위치
// }]
```

**지원 호선:**
- 서울 1~9호선
- 신분당선, 분당선, 경의중앙선, 공항철도, 경춘선 등

---

### 5️⃣ 서울 버스 도착정보 API (Seoul Bus)
- **엔드포인트**: `/getCrdntPrxmtSttnList`, `/getArrInfoByStId`
- **기능**: 좌표 기반 정류장 검색, 도착정보 조회
- **구현**: `BusApiClient`, `SeoulBusArrivalRemoteDataSource`

```dart
// 좌표 기반 주변 정류장 검색
GET /getCrdntPrxmtSttnList?tmX=127.0276&tmY=37.4979&radius=500

// 정류장별 도착정보
GET /getArrInfoByStId?stId=12345
```

**버스 유형:**
- 간선버스, 지선버스, 광역버스, 순환버스

---

### 6️⃣ 경기도 버스 API v2 (Gyeonggi Bus)
- **엔드포인트**: `/getBusStationAroundListv2`, `/getBusArrivalListv2`, `/getBusArrivalItemv2`
- **기능**: 고정밀 정류장 검색, 도착정보 조회
- **구현**: `BusApiClient`, `BusArrivalRemoteDataSource`

```dart
// 좌표 기반 주변 정류장 (500m 반경)
GET /getBusStationAroundListv2?tmX=127.0276&tmY=37.4979

// 정류장의 버스 도착정보
GET /getBusArrivalListv2?stationId=123456&routeId=999999&staOrder=1
```

**버스 유형:**
- 일반버스, 좌석버스, 직행좌석버스, 광역급행버스

**주요 특징:**
- `routeId` + `staOrder`로 정확한 도착정보 조회
- cityCode 기반 도시 식별
- 고정밀 GPS 기반 검색

---

### 7️⃣ Geolocator 플러그인 (GPS)
- **기능**: 현재 위치 획득, 위치 권한 관리
- **구현**: `LocationRemoteDataSource`, `LocationController`

```dart
// 현재 위치 획득
final position = await Geolocator.getCurrentPosition();
// { latitude, longitude, accuracy, altitude }
```

---

### 8️⃣ Geocoding 플러그인 (Address Conversion)
- **기능**: 주소↔좌표 변환
- **구현**: `LocationRemoteDataSource` utilities

```dart
// 좌표 → 주소
List<Placemark> placemarks = await placemarkFromCoordinates(37.4979, 127.0276);
// → "서울시 강남구 강남동 ..."

// 주소 → 좌표
List<Location> locations = await locationFromAddress("강남역");
// → { latitude: 37.4979, longitude: 127.0276 }
```

---

## 🛠️ 기술 스택

### 코어 프레임워크

| 기술 | 버전 | 용도 |
|------|------|------|
| **Flutter** | 3.29+ | 크로스플랫폼 모바일 앱 개발 |
| **Dart** | 3.0+ | 프로그래밍 언어 |

### 상태관리 & 의존성 주입

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **get** | 4.6.6 | 상태관리, 라우팅, 의존성 주입 |
| **get_it** | 8.2.0 | Service Locator (Clean Architecture 지원) |
| **get_storage** | 2.1.1 | 로컬 데이터 영속화 |

### API & 네트워킹

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **http** | 1.1.0 | HTTP 클라이언트 |
| **flutter_dotenv** | 5.1.0 | 환경변수 관리 (API 키) |

### 위치 & 맵

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **geolocator** | 10.1.0 | GPS 위치 서비스 |
| **geocoding** | 2.1.1 | 주소↔좌표 변환 |
| **kakao_map_plugin** | 0.3.7 | 카카오맵 네이티브 플러그인 |
| **permission_handler** | 11.3.1 | 권한 요청 관리 |

### UI/UX

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **flutter_screenutil** | 5.9.0 | 반응형 디자인 (스케일링) |
| **lottie** | 2.7.0 | 벡터 애니메이션 |
| **cupertino_icons** | 1.0.2 | iOS 스타일 아이콘 |

### 데이터 & 함수형 프로그래밍

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **dartz** | 0.10.1 | 함수형 프로그래밍 (Either 타입) |
| **equatable** | 2.0.7 | 엔티티 값 비교 |
| **json_annotation** | 4.9.0 | JSON 직렬화 메타데이터 |
| **intl** | 0.18.1 | 국제화 (다국어 지원) |

### 개발 도구

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **build_runner** | 2.4.0 | 코드 생성 |
| **json_serializable** | 6.8.0 | JSON 직렬화 자동화 |
| **flutter_lints** | 2.0.0 | 린트 규칙 |

---

## 📁 프로젝트 구조

### 구조

```
lib/
├── core/                           # 교차 계층 공통 로직 ()
│   ├── api/
│   │   ├── base/
│   │   │   └── api_client.dart     # 기본 HTTP 클라이언트 (에러 처리)
│   │   ├── clients/                # API 클라이언트 (5개)
│   │   │   ├── weather_api_client.dart
│   │   │   ├── subway_api_client.dart
│   │   │   ├── bus_api_client.dart
│   │   │   ├── kakao_api_client.dart
│   │   │   └── location_api_client.dart
│   │   ├── constants/              # API 엔드포인트 & 상수
│   │   ├── exceptions/             # API 예외 정의
│   │   └── services/
│   │       └── api_provider.dart   # GetX 기반 API 조율
│   ├── base/
│   │   └── usecase.dart            # 추상 UseCase<Type, Params>
│   ├── di/
│   │   └── inject_provider.dart    # GetIt + inject<T>() 헬퍼
│   ├── design_system/
│   │   └── widgets/                # 재사용 가능한 위젯
│   │       └── app_header_widget.dart
│   ├── exception/                  # AppException 계층 구조
│   ├── failure/                    # 실패 결과 타입
│   ├── models/                     # 공유 UI 모델
│   │   ├── location_info.dart      # 위치 정보 모델
│   │   ├── weather_info.dart       # 날씨 정보 모델
│   │   ├── weather_forecast.dart   # 예보 모델
│   │   └── rain_forecast_info.dart # 강수 분석 모델
│   ├── routes/                     # 네비게이션 설정
│   ├── theme/                      # Material Design 3 테마
│   └── utils/                      # 유틸리티 함수
│       ├── subway_utils.dart       # 호선 색상 매핑
│       └── bus_type_utils.dart     # 버스 타입 분류
│
├── features/
│   ├── home/                       # 홈 화면 (실시간 정보)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── weather_remote_datasource.dart
│   │   │   │   └── location_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── weather_response.dart
│   │   │   │   ├── weather_forecast_response.dart
│   │   │   │   └── ...
│   │   │   └── repositories/
│   │   │       ├── weather_repository_impl.dart
│   │   │       └── location_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── weather_entity.dart
│   │   │   │   ├── weather_forecast_entity.dart
│   │   │   │   └── ...
│   │   │   ├── repositories/
│   │   │   │   ├── weather_repository.dart
│   │   │   │   └── location_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_weather_forecast_usecase.dart
│   │   │       └── get_current_location_usecase.dart
│   │   ├── presentation/
│   │   │   ├── controllers/
│   │   │   │   ├── home_controller.dart (조율 컨트롤러)
│   │   │   │   ├── weather_controller.dart
│   │   │   │   ├── route_controller.dart
│   │   │   │   ├── location_controller.dart
│   │   │   │   └── arrival_controller.dart
│   │   │   └── views/
│   │   │       ├── home_screen.dart
│   │   │       └── components/
│   │   │           ├── arrival/
│   │   │           ├── weather/
│   │   │           ├── route/
│   │   │           └── header/
│   │   └── home_binding.dart
│   │
│   ├── location_search/            # 위치 검색
│   │   ├── data/
│   │   │   ├── datasources/ (7개)
│   │   │   ├── models/
│   │   │   └── repositories/ (6개)
│   │   ├── domain/
│   │   │   ├── entities/ (9개)
│   │   │   ├── repositories/ (6개)
│   │   │   └── usecases/ (8개)
│   │   ├── presentation/
│   │   │   ├── controllers/
│   │   │   │   ├── location_search_controller.dart
│   │   │   │   └── search_result_controller.dart
│   │   │   └── views/
│   │   │       ├── location_search_screen.dart
│   │   │       ├── search_result_screen.dart
│   │   │       ├── components/
│   │   │       └── dialogs/
│   │   └── location_search_binding.dart
│   │
│   ├── route_setup/                # 경로 설정
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── route_setup_controller.dart
│   │       └── views/
│   │           ├── route_setup_screen.dart
│   │           └── components/
│   │               ├── route_list/
│   │               ├── dialogs/
│   │               └── common/
│   │
│   ├── settings/                   # 설정
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── settings_controller.dart
│   │       └── views/
│   │           ├── settings_screen.dart
│   │           └── components/
│   │               ├── worktime/
│   │               ├── notification/
│   │               └── app_settings/
│   │
│   ├── onboarding/                 # 온보딩
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── onboarding_controller.dart
│   │       └── views/
│   │           ├── onboarding_screen.dart
│   │           ├── steps/           # 4개 단계별 위젯
│   │           ├── components/
│   │           └── dialogs/
│   │
│   ├── splash/                     # 스플래시
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── splash_controller.dart
│   │       └── views/
│   │           ├── splash_screen.dart
│   │           └── components/
│   │
│   └── main/                       # 탭 네비게이션
│       └── presentation/
│           ├── controllers/
│           │   └── main_controller.dart
│           └── views/
│               └── main_screen.dart
│
└── main.dart                       # 앱 진입점
```

## 🧠 상태관리 & 컨트롤러 구조

### GetX 상태관리 패턴

#### 반응형 변수 사용

```dart
class WeatherController extends GetxController {
  // 반응형 상태
  final Rx<WeatherInfo?> currentWeather = Rx<WeatherInfo?>(null);
  final RxList<WeatherForecast> weatherForecast = <WeatherForecast>[].obs;
  final RxBool isWeatherLoading = false.obs;
  final RxString weatherError = ''.obs;

  // UI에서 사용
  void fetchWeatherData(double lat, double lon) async {
    isWeatherLoading.value = true;
    try {
      // ... UseCase 호출
      currentWeather.value = result;
    } finally {
      isWeatherLoading.value = false;
    }
  }
}
```

#### 반응형 위젯 (Obx)

```dart
// 자동으로 업데이트되는 위젯
Obx(() => Text(
  '현재 온도: ${weatherController.currentWeather.value?.temperature}°C',
))
```

### 주요 컨트롤러 역할

| 컨트롤러 | 책임 | 상태 변수 |
|---------|------|---------|
| **HomeController** | 화면 조율 및 라이프사이클 | 없음 (sub-controller 조율) |
| **WeatherController** | 날씨 데이터 관리 | currentWeather, weatherForecast, rainForecast |
| **RouteController** | 경로 데이터 관리 | routesList, activeRouteId, hasRouteData |
| **LocationController** | GPS 및 권한 관리 | savedCoordinates, isLocationLoading |
| **ArrivalController** | 실시간 도착정보 | departureArrivalInfo, transferArrivalInfo, ... |
| **RouteSetupController** | 경로 CRUD | routesList, editingRouteId |
| **LocationSearchController** | 검색 및 맵 | searchQuery, searchResults, mapController |
| **SettingsController** | 사용자 설정 | workTime, notificationSettings |
| **OnboardingController** | 초기 설정 | currentStep, setupData |
| **SplashController** | 앱 초기화 | isFirstTime, isLoading |
| **MainController** | 탭 네비게이션 | currentIndex, pageController |

### 의존성 주입 (DI) 패턴

```dart
// 바인딩에서 의존성 등록
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // UseCase 등록
    Get.put<GetWeatherForecastUseCase>(
      GetWeatherForecastUseCase(Get.find<WeatherRepository>()),
    );

    // Controller 등록
    Get.put<WeatherController>(
      WeatherController(
        getWeatherForecastUseCase: Get.find<GetWeatherForecastUseCase>(),
      ),
      permanent: true,
    );
  }
}

// Controller에서 사용
class WeatherController extends GetxController {
  final GetWeatherForecastUseCase _getWeatherForecastUseCase;

  Future<void> fetchWeatherData(double lat, double lon) async {
    final result = await _getWeatherForecastUseCase(
      WeatherParams(latitude: lat, longitude: lon),
    );
    result.fold(
      (failure) => weatherError.value = failure.message,
      (entity) => currentWeather.value = WeatherInfo.fromEntity(entity),
    );
  }
}
```

---

## 🔄 데이터 흐름 예시: 날씨 조회

```
1. UI에서 좌표 요청
   ↓
2. WeatherController.fetchWeatherData(37.4979, 127.0276) 호출
   ↓
3. GetWeatherForecastUseCase 실행
   ↓
4. WeatherRepository.getWeatherForecast() 호출
   ↓
5. WeatherRemoteDataSource.getWeatherForecast() 호출
   ↓
6. WeatherApiClient.getWeatherForecast() 호출
   ↓
7. HTTP GET 요청 (기상청 API)
   ↓
8. JSON 응답 파싱 → WeatherResponse 모델
   ↓
9. WeatherResponse → WeatherEntity 변환
   ↓
10. Either<Failure, List<WeatherEntity>> 반환
    ↓
11. Controller에서 fold() 처리
    - 실패 시: weatherError.value = failure.message
    - 성공 시: currentWeather.value = entity 변환
    ↓
12. Obx() 위젯 자동 업데이트
    ↓
13. UI 화면 갱신
```

---

## 🎨 디자인 시스템

### Material Design 3

- **색상 시스템**: 동적 색상 지원
- **타이포그래피**: 사이즈별 텍스트 스타일
- **컴포넌트**: Material 위젯 활용

### 호선별 색상 코드

```dart
// 지하철 호선별 색상
const subwayColors = {
  '1002': Color(0xFF0052CC),  // 1호선 - 파란색
  '1003': Color(0xFFOA7623),  // 2호선 - 녹색
  '1005': Color(0xFFC60C30),  // 5호선 - 빨간색
  // ...
};
```

### 버스 타입별 분류

```dart
// 버스 유형별 구분
enum BusType {
  trunkLine,    // 간선버스 (파란색)
  feederLine,   // 지선버스 (초록색)
  wideArea,     // 광역버스 (빨간색)
  circulating,  // 순환버스 (황색)
}

---

## 📝 주요 구현 기술

### 실시간 도착정보 표시

- **지하철**: 호선별/방면별 필터링, 실시간 1초 갱신
- **버스**: 서울/경기도 구분, 정류장별 도착정보
- **자동 갱신**: 경로 변경 시 자동으로 도착정보 재로드
- **시각적 표시**: 호선 색상 코드, 아이콘, 남은 시간

### 경로 저장 시스템

- **구조화된 데이터**: Map 형태로 출발지/도착지/환승지 정보 저장
- **메타데이터 포함**: 교통수단 타입, 노선 정보, 정류장 코드
- **로컬 영속화**: GetStorage를 통한 캐싱

### 날씨 정보

- **기상청 격자 변환**: 위도/경도를 기상청 격자 좌표로 정확히 변환
- **강수 분석**: 오늘의 강수 시간대 분석 및 알림 제공
- **위치 기반**: GPS 또는 저장된 위치 기반 날씨 조회

### 스마트 검색

- **디바운싱**: 입력 중 불필요한 API 호출 방지 (300ms)
- **카테고리 필터링**: 지하철/버스 선택식 검색
- **거리순 정렬**: 현재 위치 기반 가까운 정류장 우선
- **실시간 마커**: 맵에서 실시간 마커 업데이트

```

### 주요 컨트롤러

- `HomeController`: 홈 화면 라이프사이클 관리
- `RouteSetupController`: 경로 CRUD 작업
- `LocationSearchController`: 장소 검색
- `ArrivalController`: 실시간 도착정보 로딩

---

## 📄 라이선스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.

---

## 🔗 API 제공처

- **공공데이터포털** - 기상청, 서울시, 경기도 공공 API
- **카카오 개발자센터** - 카카오 로컬, 카카오맵 API
- **Google Play Services** - GPS 및 위치 서비스
