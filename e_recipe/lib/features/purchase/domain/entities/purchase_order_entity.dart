import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class PurchaseOrderEntity {
  final String id;
  final String orderNumber;
  final RecipeEntity recipe;
  final int price;
  final DateTime purchasedAt;
  final String paymentMethod;
  final String status;

  const PurchaseOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.recipe,
    required this.price,
    required this.purchasedAt,
    required this.paymentMethod,
    required this.status,
  });
}

class RecipePrice {
  const RecipePrice._();

  static int forRecipe(RecipeEntity recipe) {
    return recipe.price;
  }
}
