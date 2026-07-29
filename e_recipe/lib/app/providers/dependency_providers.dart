import 'package:e_recipe/core/api/api_client.dart';
import 'package:e_recipe/core/services/hive/hive_service.dart';
import 'package:e_recipe/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:e_recipe/features/admin/domain/repositories/admin_repository.dart';
import 'package:e_recipe/features/admin/domain/usecases/admin_usecases.dart';
import 'package:e_recipe/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/auth_datasource.dart';
import 'package:e_recipe/features/auth/data/datasources/remote/password_recovery_datasource.dart';
import 'package:e_recipe/features/auth/data/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/repositories/auth_repository.dart';
import 'package:e_recipe/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/get_google_client_id_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:e_recipe/features/auth/domain/usecases/register_usecase.dart';
import 'package:e_recipe/features/auth/domain/repositories/password_recovery_repository.dart';
import 'package:e_recipe/features/auth/domain/usecases/password_recovery_usecases.dart';
import 'package:e_recipe/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:e_recipe/features/favorites/data/repositories/saved_recipes_repository_impl.dart';
import 'package:e_recipe/features/favorites/domain/repositories/saved_recipes_repository.dart';
import 'package:e_recipe/features/favorites/domain/usecases/saved_recipe_usecases.dart';
import 'package:e_recipe/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:e_recipe/features/profile/data/repositories/profile_extras_repository_impl.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_extras_repository.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_extras_usecases.dart';
import 'package:e_recipe/features/profile/domain/repositories/profile_repository.dart';
import 'package:e_recipe/features/profile/domain/usecases/profile_usecases.dart';
import 'package:e_recipe/features/purchase/data/datasources/purchase_local_datasource.dart';
import 'package:e_recipe/features/purchase/data/datasources/purchase_remote_datasource.dart';
import 'package:e_recipe/features/purchase/data/repositories/purchase_repository_impl.dart';
import 'package:e_recipe/features/purchase/domain/repositories/purchase_repository.dart';
import 'package:e_recipe/features/purchase/domain/usecases/purchase_usecases.dart';
import 'package:e_recipe/features/recipe/data/datasources/remote/recipe_remote_datasource.dart';
import 'package:e_recipe/features/recipe/data/repositories/recipe_repository_impl.dart';
import 'package:e_recipe/features/recipe/domain/repositories/recipe_repository.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipe_by_id_usecase.dart';
import 'package:e_recipe/features/recipe/domain/usecases/get_recipes_usecase.dart';
import 'package:e_recipe/features/recipe_ai/data/datasources/recipe_ai_remote_datasource.dart';
import 'package:e_recipe/features/recipe_ai/data/repositories/recipe_ai_repository_impl.dart';
import 'package:e_recipe/features/recipe_ai/domain/repositories/recipe_ai_repository.dart';
import 'package:e_recipe/features/recipe_ai/domain/usecases/generate_recipe_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<IAuthDatasource>(
  (ref) => AuthRemoteDatasource(ref.read(apiClientProvider)),
);
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>(
  (ref) => AuthLocalDatasource(ref.read(hiveServiceProvider)),
);
final passwordRecoveryRepositoryProvider = Provider<PasswordRecoveryRepository>(
  (ref) => PasswordRecoveryDatasource(ref.read(apiClientProvider)),
);
final passwordRecoveryUseCasesProvider = Provider<PasswordRecoveryUseCases>(
  (ref) =>
      PasswordRecoveryUseCases(ref.read(passwordRecoveryRepositoryProvider)),
);
final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDatasourceProvider)),
);
final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);
final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.read(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);
final getCurrentUseCaseProvider = Provider<GetCurrentUseCase>(
  (ref) => GetCurrentUseCase(ref.read(authRepositoryProvider)),
);
final googleLoginUseCaseProvider = Provider<GoogleLoginUseCase>(
  (ref) => GoogleLoginUseCase(ref.read(authRepositoryProvider)),
);
final getGoogleClientIdUseCaseProvider = Provider<GetGoogleClientIdUseCase>(
  (ref) => GetGoogleClientIdUseCase(ref.read(authRepositoryProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRemoteDatasource(ref.read(apiClientProvider)),
);
final adminUseCasesProvider = Provider<AdminUseCases>(
  (ref) => AdminUseCases(ref.read(adminRepositoryProvider)),
);
final savedRecipesRepositoryProvider = Provider<SavedRecipesRepository>(
  (_) => SavedRecipesRepositoryImpl(),
);
final savedRecipeUseCasesProvider = Provider<SavedRecipeUseCases>(
  (ref) => SavedRecipeUseCases(ref.read(savedRecipesRepositoryProvider)),
);

final profileRemoteDatasourceProvider = Provider<IProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(ref.read(apiClientProvider)),
);
final profileRepositoryProvider = Provider<IProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.read(profileRemoteDatasourceProvider)),
);
final getProfileUseCaseProvider = Provider<GetProfileUseCase>(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.read(profileRepositoryProvider)),
);
final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>(
  (ref) => UploadAvatarUseCase(ref.read(profileRepositoryProvider)),
);
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>(
  (ref) => ChangePasswordUseCase(ref.read(profileRepositoryProvider)),
);
final profileExtrasRepositoryProvider = Provider<ProfileExtrasRepository>(
  (ref) => ProfileExtrasRepositoryImpl(ref.read(apiClientProvider)),
);
final profileExtrasUseCasesProvider = Provider<ProfileExtrasUseCases>(
  (ref) => ProfileExtrasUseCases(ref.read(profileExtrasRepositoryProvider)),
);

final purchaseRemoteDatasourceProvider = Provider<IPurchaseRemoteDatasource>(
  (ref) => PurchaseRemoteDatasource(ref.read(apiClientProvider)),
);
final purchaseLocalDatasourceProvider = Provider<IPurchaseLocalDatasource>(
  (_) => PurchaseLocalDatasource(),
);
final purchaseRepositoryProvider = Provider<IPurchaseRepository>(
  (ref) => PurchaseRepositoryImpl(
    ref.read(purchaseRemoteDatasourceProvider),
    ref.read(purchaseLocalDatasourceProvider),
  ),
);
final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>(
  (ref) => GetOrdersUseCase(ref.read(purchaseRepositoryProvider)),
);
final purchaseRecipeUseCaseProvider = Provider<PurchaseRecipeUseCase>(
  (ref) => PurchaseRecipeUseCase(ref.read(purchaseRepositoryProvider)),
);

final recipeRemoteDatasourceProvider = Provider<IRecipeDatasource>(
  (ref) => RecipeRemoteDatasource(ref.read(apiClientProvider)),
);
final recipeRepositoryProvider = Provider<IRecipeRepository>(
  (ref) => RecipeRepositoryImpl(ref.read(recipeRemoteDatasourceProvider)),
);
final getRecipesUseCaseProvider = Provider<GetRecipesUseCase>(
  (ref) => GetRecipesUseCase(ref.read(recipeRepositoryProvider)),
);
final getRecipeByIdUseCaseProvider = Provider<GetRecipeByIdUseCase>(
  (ref) => GetRecipeByIdUseCase(ref.read(recipeRepositoryProvider)),
);

final recipeAiRemoteDatasourceProvider = Provider<RecipeAiRemoteDatasource>(
  (ref) => RecipeAiRemoteDatasource(ref.read(apiClientProvider)),
);
final recipeAiRepositoryProvider = Provider<RecipeAiRepository>(
  (ref) => RecipeAiRepositoryImpl(ref.read(recipeAiRemoteDatasourceProvider)),
);
final generateRecipeUseCaseProvider = Provider<GenerateRecipeUseCase>(
  (ref) => GenerateRecipeUseCase(ref.read(recipeAiRepositoryProvider)),
);
