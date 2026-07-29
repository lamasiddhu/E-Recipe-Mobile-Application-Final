import 'package:e_recipe/core/error/app_result.dart';

abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<AppResult<SuccessType>> call(Params params);
}

abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<AppResult<SuccessType>> call();
}
