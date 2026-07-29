import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/recipe/data/models/recipe_model.dart';

typedef RecipeListPage = ({
  List<RecipeModel> recipes,
  int total,
  int page,
  int pages,
});

abstract interface class IRecipeDatasource {
  Future<RecipeListPage> getRecipes({
    String? category,
    String? search,
    String? difficulty,
    int? maxTime,
    int page,
    int limit,
  });

  Future<RecipeModel> getRecipeById(String id);
}

class RecipeRemoteDatasource implements IRecipeDatasource {
  final ApiClient _apiClient;

  RecipeRemoteDatasource(this._apiClient);

  @override
  Future<RecipeListPage> getRecipes({
    String? category,
    String? search,
    String? difficulty,
    int? maxTime,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.recipes,
        queryParameters: {
          if (category != null && category != 'All') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          'difficulty': ?difficulty,
          'maxTime': ?maxTime,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data'] as List;
      return (
        recipes: data
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        total: response.data['total'] as int,
        page: response.data['page'] as int,
        pages: response.data['pages'] as int,
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _extractMessage(e),
      );
    }
  }

  @override
  Future<RecipeModel> getRecipeById(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.recipe(id));
      return RecipeModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: _extractMessage(e),
      );
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    final message = data is Map ? data['message'] : null;
    if (message is String) return message;
    if (message is List && message.isNotEmpty) return message.join(', ');
    return 'Something went wrong. Please try again.';
  }
}
