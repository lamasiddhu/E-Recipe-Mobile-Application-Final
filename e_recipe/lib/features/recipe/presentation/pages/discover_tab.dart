import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/core/constants/recipe_categories.dart';
import 'package:e_recipe/features/favorites/presentation/view_model/saved_recipes_viewmodel.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:e_recipe/features/purchase/presentation/widgets/purchase_dialog.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_list_state.dart';
import 'package:e_recipe/features/recipe/presentation/view_model/recipe_list_viewmodel.dart';
import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/features/recipe_ai/presentation/pages/ai_recipe_page.dart';

const _brandColor = Color(0xFFB84715);

class DiscoverTab extends ConsumerStatefulWidget {
  const DiscoverTab({super.key});

  @override
  ConsumerState<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<DiscoverTab> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverRecipeListViewModelProvider.notifier).loadRecipes();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(discoverRecipeListViewModelProvider.notifier)
          .setSearch(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverRecipeListViewModelProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text(
              'Discover',
              style: TextStyle(
                color: _brandColor,
                fontSize: 24,
                fontFamily: 'OpenSans Bold',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Search by recipe or ingredient',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _brandColor),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiRecipePage()),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Find a recipe with Gemini AI'),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: kRecipeCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = kRecipeCategories[index];
                final selected = state.category == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  selectedColor: _brandColor,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                  onSelected: (_) => ref
                      .read(discoverRecipeListViewModelProvider.notifier)
                      .setCategory(category),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              initialValue: state.difficulty ?? 'All',
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.tune),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All levels')),
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
              ],
              onChanged: (value) => ref
                  .read(discoverRecipeListViewModelProvider.notifier)
                  .setDifficulty(value == 'All' ? null : value),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _content(state)),
        ],
      ),
    );
  }

  Widget _content(RecipeListState state) {
    if (state.status == RecipeListStatus.loading && state.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _brandColor));
    }
    if (state.status == RecipeListStatus.error && state.recipes.isEmpty) {
      return Center(child: Text(state.message ?? 'Unable to load recipes.'));
    }
    if (state.recipes.isEmpty) {
      return const Center(child: Text('No recipes match your filters.'));
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(discoverRecipeListViewModelProvider.notifier).loadRecipes(),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: state.recipes.length,
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          final saved = ref.watch(
            savedRecipesViewModelProvider.select(
              (savedState) => savedState.recipeIds.contains(recipe.id),
            ),
          );
          final owned = ref.watch(
            purchaseViewModelProvider.select(
              (purchaseState) =>
                  purchaseState.purchasedRecipeIds.contains(recipe.id),
            ),
          );
          final isFree = recipe.badge == 'Free';
          final isPro = recipe.badge == 'Pro';
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.recipeDetail,
                arguments: recipe.id,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: recipe.image,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          height: 120,
                          color: const Color(0xFFE8D9CC),
                        ),
                        errorWidget: (_, _, _) => Container(
                          height: 120,
                          color: const Color(0xFFE8D9CC),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: RecipeAccessBadge(badge: recipe.badge),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () => ref
                              .read(savedRecipesViewModelProvider.notifier)
                              .toggle(recipe),
                          icon: Icon(
                            saved ? Icons.bookmark : Icons.bookmark_border,
                            color: _brandColor,
                          ),
                        ),
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${recipe.totalTime} min • ${recipe.difficulty}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                owned
                                    ? 'OWNED'
                                    : isFree
                                    ? 'FREE'
                                    : isPro
                                    ? 'PRO'
                                    : 'NPR ${RecipePrice.forRecipe(recipe)}',
                                style: const TextStyle(
                                  color: _brandColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!owned && !isFree && !isPro)
                              SizedBox(
                                height: 28,
                                child: TextButton(
                                  onPressed: () => showRecipePurchaseDialog(
                                    context: context,
                                    ref: ref,
                                    recipe: recipe,
                                  ),
                                  child: const Text('BUY'),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
