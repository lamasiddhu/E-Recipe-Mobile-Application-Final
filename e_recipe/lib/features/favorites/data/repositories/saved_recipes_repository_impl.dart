import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:e_recipe/features/favorites/domain/repositories/saved_recipes_repository.dart';
import 'package:hive/hive.dart';

class SavedRecipesRepositoryImpl implements SavedRecipesRepository {
  static const _savedIdsKey = 'saved_recipe_ids';
  Box<String> get _session => Hive.box<String>(HiveTableConstant.sessionBox);

  @override
  Set<String> getSavedIds() {
    final stored = _session.get(_savedIdsKey, defaultValue: '') ?? '';
    return stored.split(',').where((id) => id.trim().isNotEmpty).toSet();
  }

  @override
  Future<void> saveIds(Set<String> ids) =>
      _session.put(_savedIdsKey, ids.join(','));
}
