import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String category;
  final int? prepTime;
  final int? cookTime;
  final int totalTime;
  final String difficulty;
  final String image;
  final String videoUrl;
  final int price;
  final String badge;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
    this.prepTime,
    this.cookTime,
    required this.totalTime,
    required this.difficulty,
    required this.image,
    this.videoUrl = '',
    this.price = 0,
    this.badge = 'Free',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      instructions: List<String>.from(json['instructions'] as List? ?? []),
      category: json['category'] as String,
      prepTime: json['prepTime'] as int?,
      cookTime: json['cookTime'] as int?,
      totalTime: json['totalTime'] as int,
      difficulty: json['difficulty'] as String,
      image: ApiEndpoints.mediaUrl(json['image'] as String? ?? ''),
      videoUrl: json['videoUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      badge: json['badge'] as String? ?? 'Free',
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  RecipeEntity toEntity() {
    return RecipeEntity(
      id: id,
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      category: category,
      prepTime: prepTime,
      cookTime: cookTime,
      totalTime: totalTime,
      difficulty: difficulty,
      image: image,
      videoUrl: videoUrl,
      price: price,
      badge: badge,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
