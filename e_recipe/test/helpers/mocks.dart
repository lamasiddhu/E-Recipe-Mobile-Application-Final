import 'package:e_recipe/features/admin/domain/usecases/admin_usecases.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_recipe/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:e_recipe/features/favorites/domain/usecases/saved_recipe_usecases.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_extras_usecases.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_usecases.dart';
import 'package:e_recipe/features/purchase/domain/usecases/purchase_usecases.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetRecipesUseCase extends Mock implements GetRecipesUseCase {}

class MockGetRecipeByIdUseCase extends Mock implements GetRecipeByIdUseCase {}

class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockSavedRecipeUseCases extends Mock implements SavedRecipeUseCases {}

class MockAdminUseCases extends Mock implements AdminUseCases {}

class MockProfileExtrasUseCases extends Mock implements ProfileExtrasUseCases {}

/// AuthViewModel instantiates BiometricService() directly as a field
/// initializer (not through a Riverpod provider), so it can't be mocked by
/// overriding a provider. This subclass neutralizes only that one call —
/// every other method (login, register, ...) keeps the real implementation,
/// reading from whichever use case providers the test overrides.
class FakeAuthViewModel extends AuthViewModel {
  @override
  Future<void> checkBiometricAvailability() async {}
}
