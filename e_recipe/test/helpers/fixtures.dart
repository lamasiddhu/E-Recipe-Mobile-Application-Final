import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';

final testDate = DateTime.utc(2026, 1, 1);

const testUser = AuthEntity(
  userId: 'user-1',
  firstName: 'Siddhartha',
  lastName: 'Lama',
  email: 'user@example.com',
  phone: '9800000000',
  password: 'Password1!',
);

final testRecipe = RecipeEntity(
  id: '507f1f77bcf86cd799439011',
  title: 'Spicy Chicken Curry',
  description: 'A warming curry.',
  ingredients: const ['Chicken', 'Chilli'],
  instructions: const ['Cook the chicken'],
  category: 'Dinner',
  totalTime: 35,
  difficulty: 'Medium',
  image: 'https://example.com/curry.jpg',
  price: 250,
  badge: 'Normal',
  createdBy: 'admin-1',
  createdAt: testDate,
  updatedAt: testDate,
);

final testOrder = PurchaseOrderEntity(
  id: 'order-1',
  orderNumber: 'ORD-001',
  recipe: testRecipe,
  price: 250,
  purchasedAt: testDate,
  paymentMethod: 'e-Sewa',
  status: 'Completed',
);
