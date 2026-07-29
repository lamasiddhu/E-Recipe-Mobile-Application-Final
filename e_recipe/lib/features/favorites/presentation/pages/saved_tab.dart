import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/features/favorites/presentation/view_model/saved_recipes_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _brandColor = Color(0xFFB84715);

class SavedTab extends ConsumerWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedRecipesViewModelProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Saved Recipes',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'OpenSans Bold',
                color: _brandColor,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your personal cookbook, available anytime.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildContent(context, ref, state)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic state) {
    if (state.loading && state.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _brandColor));
    }

    if (state.recipes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No saved recipes yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on a recipe to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(savedRecipesViewModelProvider.notifier).loadSavedRecipes(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: state.recipes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: recipe.id,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        recipe.image,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 88,
                          height: 88,
                          color: const Color(0xFFE8D9CC),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${recipe.category} • ${recipe.totalTime} min',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe.difficulty,
                            style: const TextStyle(color: _brandColor),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove from saved',
                      onPressed: () => ref
                          .read(savedRecipesViewModelProvider.notifier)
                          .toggle(recipe),
                      icon: const Icon(Icons.bookmark, color: _brandColor),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
