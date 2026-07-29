import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/domain/usecases/purchase_usecases.dart';
import 'package:e_recipe/features/purchase/presentation/state/purchase_state.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

final purchaseViewModelProvider =
    NotifierProvider<PurchaseViewModel, PurchaseState>(PurchaseViewModel.new);

class PurchaseViewModel extends Notifier<PurchaseState> {
  late final GetOrdersUseCase _getOrders;
  late final PurchaseRecipeUseCase _purchaseRecipe;

  @override
  PurchaseState build() {
    _getOrders = ref.read(getOrdersUseCaseProvider);
    _purchaseRecipe = ref.read(purchaseRecipeUseCaseProvider);
    return const PurchaseState();
  }

  Future<void> loadOrders() async {
    final result = await _getOrders();
    result.fold(
      (failure) => state = state.copyWith(message: failure.message),
      (orders) => state = state.copyWith(orders: orders, clearMessage: true),
    );
  }

  bool owns(String recipeId) =>
      state.orders.any((order) => order.recipe.id == recipeId);

  Future<AppResult<PurchaseOrderEntity>> purchase(
    RecipeEntity recipe, {
    required String esewaNumber,
  }) async {
    if (owns(recipe.id)) {
      final existing = state.orders.firstWhere(
        (order) => order.recipe.id == recipe.id,
      );
      return ResultSuccess(existing);
    }

    state = state.copyWith(processing: true, clearMessage: true);
    final result = await _purchaseRecipe(recipe, esewaNumber: esewaNumber);
    result.fold(
      (failure) =>
          state = state.copyWith(processing: false, message: failure.message),
      (order) => state = state.copyWith(
        processing: false,
        orders: [order, ...state.orders],
        clearMessage: true,
      ),
    );
    return result;
  }
}
