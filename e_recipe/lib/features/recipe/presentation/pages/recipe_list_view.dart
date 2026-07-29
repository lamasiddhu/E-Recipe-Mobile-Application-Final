import 'dart:async';

import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/core/constants/recipe_categories.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:e_recipe/features/recipe/presentation/view_model/recipe_list_viewmodel.dart';
import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _brandColor = Color(0xFFB84715);
const _bgColor = Color(0xFFF7F2E9);

class RecipeListView extends ConsumerStatefulWidget {
  const RecipeListView({super.key});

  @override
  ConsumerState<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends ConsumerState<RecipeListView> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recipeListViewModelProvider.notifier).loadRecipes();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(recipeListViewModelProvider.notifier).setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeListViewModelProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        foregroundColor: _brandColor,
        title: const Text('All Recipes'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(recipeListViewModelProvider.notifier).loadRecipes(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Search recipes or ingredients...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: kRecipeCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = kRecipeCategories[index];
                    final selected = state.category == cat;
                    return GestureDetector(
                      onTap: () => ref
                          .read(recipeListViewModelProvider.notifier)
                          .setCategory(cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? _brandColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(RecipeListState state) {
    if (state.status == RecipeListStatus.loading && state.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _brandColor));
    }

    if (state.status == RecipeListStatus.error && state.recipes.isEmpty) {
      return Center(child: Text(state.message ?? 'Something went wrong.'));
    }

    if (state.recipes.isEmpty) {
      return const Center(child: Text('No recipes found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: state.recipes.length,
      itemBuilder: (context, index) {
        final recipe = state.recipes[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.recipeDetail,
            arguments: recipe.id,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        recipe.image,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 110,
                          width: double.infinity,
                          color: const Color(0xFFE8D9CC),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 32,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: RecipeAccessBadge(badge: recipe.badge),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recipe.totalTime} min • ${recipe.difficulty}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
