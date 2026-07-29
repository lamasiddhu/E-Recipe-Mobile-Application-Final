import 'dart:convert';

import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:e_recipe/features/purchase/data/models/purchase_order_model.dart';
import 'package:hive/hive.dart';

abstract interface class IPurchaseLocalDatasource {
  List<PurchaseOrderModel> getOrders();
  Future<void> saveOrder(PurchaseOrderModel order);
  Future<void> replaceOrders(List<PurchaseOrderModel> orders);
}

class PurchaseLocalDatasource implements IPurchaseLocalDatasource {
  static const _ordersKey = 'recipe_purchase_orders';

  Box<String> get _box => Hive.box<String>(HiveTableConstant.sessionBox);

  @override
  List<PurchaseOrderModel> getOrders() {
    final encoded = _box.get(_ordersKey);
    if (encoded == null || encoded.isEmpty) return const [];
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map(
          (item) => PurchaseOrderModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveOrder(PurchaseOrderModel order) async {
    final orders = getOrders();
    if (orders.any((item) => item.recipe.id == order.recipe.id)) return;
    orders.insert(0, order);
    await _box.put(
      _ordersKey,
      jsonEncode(orders.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> replaceOrders(List<PurchaseOrderModel> orders) async {
    await _box.put(
      _ordersKey,
      jsonEncode(orders.map((item) => item.toJson()).toList()),
    );
  }
}
