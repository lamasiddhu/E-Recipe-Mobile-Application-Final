import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class GetOrdersUseCase {
  final IPurchaseRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<AppResult<List<PurchaseOrderEntity>>> call() =>
      _repository.getOrders();
}

class PurchaseRecipeUseCase {
  final IPurchaseRepository _repository;

  PurchaseRecipeUseCase(this._repository);

  Future<AppResult<PurchaseOrderEntity>> call(
    RecipeEntity recipe, {
    required String esewaNumber,
  }) {
    return _repository.purchase(
      recipe,
      price: RecipePrice.forRecipe(recipe),
      esewaNumber: esewaNumber,
    );
  }
}
