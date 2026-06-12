import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:e_recipe/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init('${directory.path}/${HiveTableConstant.dbName}');
    _registerAdapters();
    await openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    if (!Hive.isBoxOpen(HiveTableConstant.userBox)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.userBox);
    }
    if (!Hive.isBoxOpen(HiveTableConstant.sessionBox)) {
      await Hive.openBox<String>(HiveTableConstant.sessionBox);
    }
  }

  Future<void> close() => Hive.close();

  Box<AuthHiveModel> get _users =>
      Hive.box<AuthHiveModel>(HiveTableConstant.userBox);

  Box<String> get _session => Hive.box<String>(HiveTableConstant.sessionBox);

  Future<AuthHiveModel> saveUser(AuthHiveModel user) async {
    final normalizedEmail = user.email.toLowerCase();
    if (isEmailTaken(normalizedEmail)) {
      throw StateError('An account with this email already exists.');
    }

    await _users.put(user.userId, user);
    await _session.put(HiveTableConstant.activeUserKey, user.userId);
    return user;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final normalizedEmail = email.toLowerCase();
    for (final user in _users.values) {
      if (user.email.toLowerCase() == normalizedEmail &&
          user.password == password) {
        await _session.put(HiveTableConstant.activeUserKey, user.userId);
        return user;
      }
    }
    return null;
  }

  AuthHiveModel? getCurrentUser() {
    final activeUserId = _session.get(HiveTableConstant.activeUserKey);
    if (activeUserId == null) return null;
    return _users.get(activeUserId);
  }

  Future<void> logoutUser() async {
    await _session.delete(HiveTableConstant.activeUserKey);
  }

  bool isEmailTaken(String email) {
    final normalizedEmail = email.toLowerCase();
    return _users.values.any((user) => user.email.toLowerCase() == normalizedEmail);
  }
}
