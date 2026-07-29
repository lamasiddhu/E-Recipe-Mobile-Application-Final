import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static const _enabledKey = 'setting_biometric_enabled';
  static const _biometricTokenKey = 'biometric_auth_token';
  final LocalAuthentication _auth = LocalAuthentication();

  Box<String> get _session => Hive.box<String>(HiveTableConstant.sessionBox);

  bool get isEnabled => _session.get(_enabledKey) == 'true';
  bool get hasSavedSession =>
      (_session.get(_biometricTokenKey) ?? '').isNotEmpty;

  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    if (enabled) {
      if (!await isAvailable()) return false;
      if (!await authenticate(
        'Confirm your fingerprint to enable biometric authentication',
      )) {
        return false;
      }
    }
    await _session.put(_enabledKey, enabled.toString());
    if (enabled) {
      final currentToken = _session.get(HiveTableConstant.authTokenKey);
      if (currentToken != null && currentToken.isNotEmpty) {
        await _session.put(_biometricTokenKey, currentToken);
      }
    } else {
      await _session.delete(_biometricTokenKey);
    }
    return true;
  }

  Future<bool> restoreSession() async {
    final token = _session.get(_biometricTokenKey);
    if (token == null || token.isEmpty) return false;
    await _session.put(HiveTableConstant.authTokenKey, token);
    return true;
  }

  Future<void> rememberCurrentSession() async {
    if (!isEnabled) return;
    final token = _session.get(HiveTableConstant.authTokenKey);
    if (token != null && token.isNotEmpty) {
      await _session.put(_biometricTokenKey, token);
    }
  }

  Future<void> clearSavedSession() => _session.delete(_biometricTokenKey);
}
