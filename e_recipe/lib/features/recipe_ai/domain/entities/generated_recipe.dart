import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class RecipeRecommendation {
  final RecipeEntity recipe;
  final String reason;

  const RecipeRecommendation({required this.recipe, required this.reason});
}

class RecipeAiResponse {
  final String message;
  final List<RecipeRecommendation> recommendations;

  const RecipeAiResponse({
    required this.message,
    required this.recommendations,
  });
}

class RecipeChatMessage {
  final String text;
  final bool isUser;
  final List<RecipeRecommendation> recommendations;

  const RecipeChatMessage({
    required this.text,
    required this.isUser,
    this.recommendations = const [],
  });
}
