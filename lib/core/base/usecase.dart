import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../failure/failure.dart';

/// UseCase 기본 추상 클래스
/// [Type]: 성공 시 반환 타입
/// [Params]: 입력 파라미터 타입
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// 파라미터 없는 UseCase용 클래스
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}