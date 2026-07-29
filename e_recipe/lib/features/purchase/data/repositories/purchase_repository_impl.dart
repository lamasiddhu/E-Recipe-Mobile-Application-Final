import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/api_exception.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/purchase/data/datasources/purchase_local_datasource.dart';
import 'package:e_recipe/features/purchase/data/datasources/purchase_remote_datasource.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

class PurchaseRepositoryImpl implements IPurchaseRepository {
  final IPurchaseRemoteDatasource _remoteDatasource;
  final IPurchaseLocalDatasource _localDatasource;

  PurchaseRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<AppResult<List<PurchaseOrderEntity>>> getOrders() async {
    try {
      final orders = await _remoteDatasource.getOrders();
      await _localDatasource.replaceOrders(orders);
      return ResultSuccess(orders.map((order) => order.toEntity()).toList());
    } on ApiException catch (error) {
      final cached = _localDatasource.getOrders();
      if (cached.isNotEmpty) {
        return ResultSuccess(cached.map((order) => order.toEntity()).toList());
      }
      return ResultFailure(
        ApiFailure(statusCode: error.statusCode, message: error.message),
      );
    }
  }

  @override
  Future<AppResult<PurchaseOrderEntity>> purchase(
    RecipeEntity recipe, {
    required int price,
    required String esewaNumber,
  }) async {
    try {
      final order = await _remoteDatasource.purchase(
        recipe.id,
        esewaNumber: esewaNumber,
        amount: price,
      );
      await _localDatasource.saveOrder(order);
      return ResultSuccess(order.toEntity());
    } on ApiException catch (error) {
      return ResultFailure(
        ApiFailure(statusCode: error.statusCode, message: error.message),
      );
    }
  }
}
