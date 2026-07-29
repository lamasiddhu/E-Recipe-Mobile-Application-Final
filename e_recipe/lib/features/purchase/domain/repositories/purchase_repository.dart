import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

abstract interface class IPurchaseRepository {
  Future<AppResult<List<PurchaseOrderEntity>>> getOrders();

  Future<AppResult<PurchaseOrderEntity>> purchase(
    RecipeEntity recipe, {
    required int price,
    required String esewaNumber,
  });
}
