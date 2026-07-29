import 'package:dio/dio.dart';
import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/features/purchase/data/models/purchase_order_model.dart';

abstract interface class IPurchaseRemoteDatasource {
  Future<List<PurchaseOrderModel>> getOrders();
  Future<PurchaseOrderModel> purchase(
    String recipeId, {
    required String esewaNumber,
    required int amount,
  });
}

class PurchaseRemoteDatasource implements IPurchaseRemoteDatasource {
  final ApiClient _apiClient;

  PurchaseRemoteDatasource(this._apiClient);

  @override
  Future<List<PurchaseOrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myOrders);
      final data = response.data['data'] as List<dynamic>;
      return data
          .map(
            (item) => PurchaseOrderModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw _toException(error, 'Unable to load your orders.');
    }
  }

  @override
  Future<PurchaseOrderModel> purchase(
    String recipeId, {
    required String esewaNumber,
    required int amount,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.orders,
        data: {
          'recipeId': recipeId,
          'esewaNumber': esewaNumber,
          'amount': amount,
        },
      );
      return PurchaseOrderModel.fromJson(
        Map<String, dynamic>.from(response.data['data'] as Map),
      );
    } on DioException catch (error) {
      throw _toException(error, 'Unable to complete your purchase.');
    }
  }

  ApiException _toException(DioException error, String fallback) {
    final data = error.response?.data;
    final rawMessage = data is Map<String, dynamic> ? data['message'] : null;
    final message = rawMessage is List
        ? rawMessage.map((value) => value.toString()).join('\n')
        : rawMessage?.toString();
    return ApiException(
      statusCode: error.response?.statusCode,
      message: message == null || message.isEmpty ? fallback : message,
    );
  }
}
