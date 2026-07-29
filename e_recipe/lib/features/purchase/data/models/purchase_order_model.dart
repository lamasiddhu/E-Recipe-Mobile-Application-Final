import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/recipe/data/models/recipe_model.dart';

class PurchaseOrderModel {
  final String id;
  final String orderNumber;
  final RecipeModel recipe;
  final int price;
  final DateTime purchasedAt;
  final String paymentMethod;
  final String status;

  const PurchaseOrderModel({
    required this.id,
    required this.orderNumber,
    required this.recipe,
    required this.price,
    required this.purchasedAt,
    required this.paymentMethod,
    required this.status,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber']?.toString() ?? json['id'] as String,
      recipe: RecipeModel.fromJson(
        Map<String, dynamic>.from(json['recipe'] as Map),
      ),
      price: json['price'] as int,
      purchasedAt: DateTime.parse(json['purchasedAt'] as String),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
    );
  }

  factory PurchaseOrderModel.fromEntity(PurchaseOrderEntity entity) {
    final recipe = entity.recipe;
    return PurchaseOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      recipe: RecipeModel(
        id: recipe.id,
        title: recipe.title,
        description: recipe.description,
        ingredients: recipe.ingredients,
        instructions: recipe.instructions,
        category: recipe.category,
        prepTime: recipe.prepTime,
        cookTime: recipe.cookTime,
        totalTime: recipe.totalTime,
        difficulty: recipe.difficulty,
        image: recipe.image,
        videoUrl: recipe.videoUrl,
        price: recipe.price,
        badge: recipe.badge,
        createdBy: recipe.createdBy,
        createdAt: recipe.createdAt,
        updatedAt: recipe.updatedAt,
      ),
      price: entity.price,
      purchasedAt: entity.purchasedAt,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'recipe': {
        '_id': recipe.id,
        'title': recipe.title,
        'description': recipe.description,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'category': recipe.category,
        'prepTime': recipe.prepTime,
        'cookTime': recipe.cookTime,
        'totalTime': recipe.totalTime,
        'difficulty': recipe.difficulty,
        'image': recipe.image,
        'videoUrl': recipe.videoUrl,
        'price': recipe.price,
        'badge': recipe.badge,
        'createdBy': recipe.createdBy,
        'createdAt': recipe.createdAt.toIso8601String(),
        'updatedAt': recipe.updatedAt.toIso8601String(),
      },
      'price': price,
      'purchasedAt': purchasedAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }

  PurchaseOrderEntity toEntity() {
    return PurchaseOrderEntity(
      id: id,
      orderNumber: orderNumber,
      recipe: recipe.toEntity(),
      price: price,
      purchasedAt: purchasedAt,
      paymentMethod: paymentMethod,
      status: status,
    );
  }
}
