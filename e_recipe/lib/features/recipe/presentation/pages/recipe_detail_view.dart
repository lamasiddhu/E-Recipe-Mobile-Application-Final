import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_recipe/features/favorites/presentation/view_model/saved_recipes_viewmodel.dart';
import 'package:e_recipe/features/purchase/domain/entities/purchase_order_entity.dart';
import 'package:e_recipe/features/purchase/presentation/view_model/purchase_viewmodel.dart';
import 'package:e_recipe/features/purchase/presentation/widgets/purchase_dialog.dart';
import 'package:e_recipe/features/profile/presentation/pages/pro_membership_page.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:e_recipe/features/recipe/presentation/state/recipe_detail_state.dart';
import 'package:e_recipe/features/recipe/presentation/view_model/recipe_detail_viewmodel.dart';
import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _brandColor = Color(0xFFB84715);
const _bgColor = Color(0xFFF7F2E9);

class RecipeDetailView extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailView({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends ConsumerState<RecipeDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recipeDetailViewModelProvider.notifier)
          .loadRecipe(widget.recipeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeDetailViewModelProvider);
    final isSaved =
        state.recipe != null &&
        ref.watch(
          savedRecipesViewModelProvider.select(
            (savedState) => savedState.recipeIds.contains(state.recipe!.id),
          ),
        );
    final isOwned =
        state.recipe != null &&
        ref.watch(
          purchaseViewModelProvider.select(
            (purchaseState) =>
                purchaseState.purchasedRecipeIds.contains(state.recipe!.id),
          ),
        );
    final hasPro = ref.watch(
      profileViewModelProvider.select(
        (profileState) => profileState.profile?.isPro ?? false,
      ),
    );

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        foregroundColor: _brandColor,
        actions: [
          if (state.recipe != null)
            IconButton(
              tooltip: isSaved ? 'Remove from saved' : 'Save recipe',
              onPressed: () => ref
                  .read(savedRecipesViewModelProvider.notifier)
                  .toggle(state.recipe!),
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(state, isOwned, hasPro)),
    );
  }

  Widget _buildBody(RecipeDetailState state, bool isOwned, bool hasPro) {
    if (state.status == RecipeDetailStatus.loading ||
        state.status == RecipeDetailStatus.initial) {
      return const Center(child: CircularProgressIndicator(color: _brandColor));
    }

    if (state.status == RecipeDetailStatus.error || state.recipe == null) {
      return Center(child: Text(state.message ?? 'Something went wrong.'));
    }

    final recipe = state.recipe!;
    final isFree = recipe.badge == 'Free';
    final isProRecipe = recipe.badge == 'Pro';
    final canAccess = isFree || (isOwned && (!isProRecipe || hasPro));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: recipe.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFE8D9CC),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    width: double.infinity,
                    color: const Color(0xFFE8D9CC),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: RecipeAccessBadge(badge: recipe.badge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recipe.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(recipe.description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              _badge(Icons.category, recipe.category),
              _badge(Icons.timer, '${recipe.totalTime} min'),
              _badge(Icons.bar_chart, recipe.difficulty),
            ],
          ),
          if (canAccess && recipe.videoUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openVideo(recipe.videoUrl),
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('WATCH RECIPE VIDEO'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _brandColor,
                  side: const BorderSide(color: _brandColor),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAccess
                  ? null
                  : isProRecipe && !hasPro
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProMembershipPage(),
                      ),
                    )
                  : () async {
                      final purchased = await showRecipePurchaseDialog(
                        context: context,
                        ref: ref,
                        recipe: recipe,
                      );
                      if (purchased) {
                        await ref
                            .read(recipeDetailViewModelProvider.notifier)
                            .loadRecipe(widget.recipeId);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.green.shade100,
                disabledForegroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: Icon(
                canAccess
                    ? Icons.check_circle
                    : isProRecipe
                    ? Icons.workspace_premium
                    : Icons.shopping_bag_outlined,
              ),
              label: Text(
                isOwned && isProRecipe && !hasPro
                    ? 'GET PRO TO ACCESS'
                    : isOwned
                    ? 'PURCHASED'
                    : isFree
                    ? 'FREE RECIPE'
                    : isProRecipe
                    ? hasPro
                          ? 'BUY PRO RECIPE • NPR ${RecipePrice.forRecipe(recipe)}'
                          : 'GET PRO TO PURCHASE'
                    : 'BUY RECIPE • NPR ${RecipePrice.forRecipe(recipe)}',
              ),
            ),
          ),
          if (!canAccess) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 38, color: _brandColor),
                  const SizedBox(height: 10),
                  Text(
                    isProRecipe && !hasPro
                        ? 'Pro membership required'
                        : 'Purchase to unlock the full recipe',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isProRecipe && !hasPro
                        ? 'Become a Pro member first. You can then purchase this recipe to unlock its ingredients, instructions, and video.'
                        : 'Ingredients, instructions, and the recipe video will appear only after purchase.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            const Text(
              'Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: _brandColor),
                    const SizedBox(width: 10),
                    Expanded(child: Text(ingredient)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.instructions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _brandColor,
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _brandColor),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open this recipe video.')),
        );
      }
    }
  }
}
