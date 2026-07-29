import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe/data/models/recipe_model.dart';

class RecipeAiRemoteDatasource {
  final ApiClient _apiClient;

  RecipeAiRemoteDatasource(this._apiClient);

  Future<RecipeAiResponse> generate(
    String query, {
    List<RecipeChatMessage> history = const [],
  }) async {
    try {
      final response = await _apiClient.post(
        '/recipe-ai/generate',
        data: {
          'query': query.trim(),
          'history': history
              .take(10)
              .map(
                (message) => {
                  'role': message.isUser ? 'user' : 'assistant',
                  'text': message.text,
                },
              )
              .toList(),
        },
      );
      final payload = response.data['data'] as Map<String, dynamic>;
      final data = payload['recommendations'] as List? ?? const [];
      final recommendations = data.map((item) {
        final map = item as Map<String, dynamic>;
        return RecipeRecommendation(
          recipe: RecipeModel.fromJson(
            map['recipe'] as Map<String, dynamic>,
          ).toEntity(),
          reason: map['reason']?.toString() ?? '',
        );
      }).toList();
      return RecipeAiResponse(
        message: payload['message']?.toString() ?? '',
        recommendations: recommendations,
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      final message = data is Map ? data['message'] : null;
      throw ApiException(
        statusCode: error.response?.statusCode,
        message: message?.toString() ?? 'Gemini could not generate a recipe.',
      );
    }
  }
}
