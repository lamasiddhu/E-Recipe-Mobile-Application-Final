import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/admin/domain/usecases/admin_usecases.dart';
import 'package:e_recipe/features/admin/presentation/state/admin_dashboard_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminDashboardViewModelProvider =
    NotifierProvider<AdminDashboardViewModel, AdminDashboardState>(
      AdminDashboardViewModel.new,
    );

class AdminDashboardViewModel extends Notifier<AdminDashboardState> {
  late final AdminUseCases _api;
  Timer? _liveTimer;

  @override
  AdminDashboardState build() {
    _api = ref.read(adminUseCasesProvider);
    _liveTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshLive(),
    );
    ref.onDispose(() => _liveTimer?.cancel());
    Future.microtask(loadAll);
    return const AdminDashboardState();
  }

  Future<void> _refreshLive() async {
    try {
      final dashboard = await _api.dashboard();
      state = state.copyWith(
        dashboard: dashboard,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {
      // Keep the last valid values during a temporary network interruption.
    }
  }

  Future<void> loadAll() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final results = await Future.wait([
        _api.dashboard(),
        _api.users(),
        _api.orders(),
        _api.recipes(),
        _api.settings(),
      ]);
      state = state.copyWith(
        dashboard: results[0] as Map<String, dynamic>,
        users: results[1] as List<Map<String, dynamic>>,
        orders: results[2] as List<Map<String, dynamic>>,
        recipes: results[3] as List<Map<String, dynamic>>,
        settings: results[4] as Map<String, dynamic>,
        lastUpdated: DateTime.now(),
        loading: false,
      );
    } catch (error) {
      state = state.copyWith(error: _message(error), loading: false);
    }
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return error.toString();
  }

  Future<void> updateUser(String id, {String? role, bool? isPro}) =>
      _api.updateUser(id, role: role, isPro: isPro);

  Future<void> deleteUser(String id) => _api.deleteUser(id);

  Future<void> notifyUser(String id, String message) =>
      _api.notifyUser(id, message);

  Future<void> sendRecovery(String id) => _api.sendRecovery(id);

  Future<void> removePurchase(String userId, String recipeId) =>
      _api.removePurchase(userId, recipeId);

  Future<void> deleteRecipe(String id) => _api.deleteRecipe(id);

  Future<void> addRecipe(Map<String, dynamic> recipe) =>
      _api.addRecipe(recipe);

  Future<void> updateRecipe(String id, Map<String, dynamic> recipe) =>
      _api.updateRecipe(id, recipe);

  Future<String> uploadRecipeImage(String path) =>
      _api.uploadRecipeImage(path);

  Future<void> broadcast(String message, {String type = 'announcement'}) =>
      _api.broadcast(message, type: type);

  Future<void> maintenance(bool enabled) async {
    await _api.maintenance(enabled);
    state = state.copyWith(
      settings: {...state.settings, 'maintenanceMode': enabled},
    );
  }

  Future<void> clearCache() => _api.clearCache();
}
