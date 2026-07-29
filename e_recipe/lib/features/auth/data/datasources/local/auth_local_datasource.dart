import 'package:e_recipe/core/services/hive/hive_service.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource(this._hiveService);

  @override
  Future<String> getGoogleClientId() {
    throw UnsupportedError('Google sign-in requires the remote datasource.');
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return _hiveService.getCurrentUser();
  }

  @override
  Future<bool> isEmailExists(String email) async {
    return _hiveService.isEmailTaken(email);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) {
    return _hiveService.loginUser(email, password);
  }

  @override
  Future<AuthHiveModel> loginWithGoogle(String idToken) {
    throw UnsupportedError('Google sign-in requires the remote datasource.');
  }

  @override
  Future<bool> logout() async {
    await _hiveService.logoutUser();
    return true;
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    await _hiveService.saveUser(model);
    return true;
  }
}
