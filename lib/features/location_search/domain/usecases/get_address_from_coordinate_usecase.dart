import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import '../repositories/map_repository.dart';

/// 좌표로 주소 검색 UseCase
class GetAddressFromCoordinateUseCase {
  final MapRepository repository;

  GetAddressFromCoordinateUseCase({required this.repository});

  Future<String?> call(LatLng coordinate) {
    return repository.getAddressFromCoordinate(coordinate);
  }
}