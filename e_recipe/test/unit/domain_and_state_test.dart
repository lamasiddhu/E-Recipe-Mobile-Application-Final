import 'package:e_recipe/core/error/app_result.dart';
import 'package:e_recipe/core/error/failures.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:e_recipe/features/auth/presentation/state/auth_state.dart';
import 'package:e_recipe/features/favorites/presentation/state/saved_recipes_state.dart';
import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:e_recipe/features/profile/presentation/state/profile_state.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/presentation/state/purchase_state.dart';
import 'package:e_recipe/features/recipe/domain/entities/recipe_entity.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('AppResult', () {
    test('success fold calls success branch', () {
      const result = ResultSuccess(7);
      expect(result.fold((_) => -1, (value) => value), 7);
    });
    test('failure fold calls failure branch', () {
      const result = ResultFailure<int>(ApiFailure(message: 'failed'));
      expect(result.fold((failure) => failure.message, (_) => ''), 'failed');
    });
    test('API failure preserves status code', () {
      const failure = ApiFailure(statusCode: 403, message: 'Forbidden');
      expect(failure.statusCode, 403);
    });
    test('local failure preserves custom message', () {
      const failure = LocalDatabaseFailure(message: 'Offline');
      expect(failure.message, 'Offline');
    });
  });

  group('Domain entities', () {
    test('auth display name joins names', () {
      expect(testUser.displayName, 'Siddhartha Lama');
    });
    test('auth display name trims an empty last name', () {
      const user = AuthEntity(
        firstName: 'Sita',
        lastName: '',
        email: '',
        phone: '',
        password: '',
      );
      expect(user.displayName, 'Sita');
    });
    test('profile display name joins names', () {
      const profile = ProfileEntity(
        id: '1',
        firstName: 'Sita',
        lastName: 'Rai',
        email: 'sita@example.com',
        phone: '9800000000',
        bio: '',
        profilePicture: '',
        role: 'user',
        isPro: false,
      );
      expect(profile.displayName, 'Sita Rai');
    });
    test('recipe price uses the stored database value', () {
      expect(RecipePrice.forRecipe(testRecipe), 250);
    });
    test('free recipe can have zero price', () {
      final free = _recipe(price: 0, badge: 'Free');
      expect(RecipePrice.forRecipe(free), 0);
    });
    test('Pro recipe retains its badge', () {
      final pro = _recipe(price: 500, badge: 'Pro');
      expect(pro.badge, 'Pro');
    });
  });

  group('AuthState', () {
    test('defaults to initial', () {
      expect(const AuthState().status, AuthStatus.initial);
    });
    test('copy changes status', () {
      expect(
        const AuthState().copyWith(status: AuthStatus.loading).status,
        AuthStatus.loading,
      );
    });
    test('copy stores user', () {
      expect(const AuthState().copyWith(user: testUser).user, testUser);
    });
    test('clearMessage removes message', () {
      expect(
        const AuthState(message: 'error').copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });

  group('RecipeListState', () {
    test('defaults to All category', () {
      expect(const RecipeListState().category, 'All');
    });
    test('copy updates recipes', () {
      expect(
        const RecipeListState().copyWith(recipes: [testRecipe]).recipes,
        hasLength(1),
      );
    });
    test('copy updates search', () {
      expect(const RecipeListState().copyWith(search: 'dal').search, 'dal');
    });
    test('copy updates difficulty', () {
      expect(
        const RecipeListState().copyWith(difficulty: 'Hard').difficulty,
        'Hard',
      );
    });
    test('clearDifficulty removes selected difficulty', () {
      expect(
        const RecipeListState(
          difficulty: 'Easy',
        ).copyWith(clearDifficulty: true).difficulty,
        isNull,
      );
    });
    test('clearMessage removes recipe error', () {
      expect(
        const RecipeListState(
          message: 'error',
        ).copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });

  group('PurchaseState', () {
    test('defaults to not processing', () {
      expect(const PurchaseState().processing, isFalse);
    });
    test('returns purchased recipe IDs', () {
      expect(PurchaseState(orders: [testOrder]).purchasedRecipeIds, {
        testRecipe.id,
      });
    });
    test('copy updates processing', () {
      expect(const PurchaseState().copyWith(processing: true).processing, isTrue);
    });
    test('clearMessage removes purchase error', () {
      expect(
        const PurchaseState(
          message: 'error',
        ).copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });

  group('SavedRecipesState', () {
    test('defaults to no saved IDs', () {
      expect(const SavedRecipesState().recipeIds, isEmpty);
    });
    test('copy stores recipe IDs', () {
      expect(
        const SavedRecipesState().copyWith(recipeIds: {'one'}).recipeIds,
        contains('one'),
      );
    });
    test('copy stores loaded recipes', () {
      expect(
        const SavedRecipesState().copyWith(recipes: [testRecipe]).recipes,
        hasLength(1),
      );
    });
    test('clearMessage removes saved recipe error', () {
      expect(
        const SavedRecipesState(
          message: 'error',
        ).copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });

  group('ProfileState', () {
    test('defaults to not loading', () {
      expect(const ProfileState().loading, isFalse);
    });
    test('copy updates saving', () {
      expect(const ProfileState().copyWith(saving: true).saving, isTrue);
    });
    test('clearMessage removes profile error', () {
      expect(
        const ProfileState(
          message: 'error',
        ).copyWith(clearMessage: true).message,
        isNull,
      );
    });
  });
}

RecipeEntity _recipe({required int price, required String badge}) {
  return RecipeEntity(
    id: 'id-$badge',
    title: badge,
    description: '',
    ingredients: const [],
    instructions: const [],
    category: 'Dinner',
    totalTime: 10,
    difficulty: 'Easy',
    image: '',
    price: price,
    badge: badge,
    createdBy: 'admin',
    createdAt: testDate,
    updatedAt: testDate,
  );
}
