import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';

class PurchaseState {
  final bool processing;
  final List<PurchaseOrderEntity> orders;
  final String? message;

  const PurchaseState({
    this.processing = false,
    this.orders = const [],
    this.message,
  });

  Set<String> get purchasedRecipeIds =>
      orders.map((order) => order.recipe.id).toSet();

  PurchaseState copyWith({
    bool? processing,
    List<PurchaseOrderEntity>? orders,
    String? message,
    bool clearMessage = false,
  }) {
    return PurchaseState(
      processing: processing ?? this.processing,
      orders: orders ?? this.orders,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
