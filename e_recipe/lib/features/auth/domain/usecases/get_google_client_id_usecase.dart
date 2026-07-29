import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';

class GetGoogleClientIdUseCase {
  final IAuthRepository _repository;
  GetGoogleClientIdUseCase(this._repository);
  Future<String> call() => _repository.getGoogleClientId();
}
