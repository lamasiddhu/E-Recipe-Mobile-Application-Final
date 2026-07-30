part of 'dashboard_view.dart';

class _DashboardViewState extends ConsumerState<DashboardView> {
  int _selectedIndex = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppPermissionService.requestLocationOncePerSession();
      ref.read(recipeListViewModelProvider.notifier).loadRecipes();
      ref.read(savedRecipesViewModelProvider.notifier).loadSavedRecipes();
      ref.read(purchaseViewModelProvider.notifier).loadOrders();
      ref.read(profileViewModelProvider.notifier).load();
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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    const Color brandColor = Color(0xFFB84715);
    final state = ref.watch(recipeListViewModelProvider);
    final profile = ref.watch(profileViewModelProvider).profile;
    final hasAvatar =
        profile != null &&
        profile.profilePicture.isNotEmpty &&
        profile.profilePicture != 'default-profile.png';

    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'E-Recipe',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'OpenSans Bold',
                          color: brandColor,
                        ),
                      ),
                      Row(
                        children: [
                          const NotificationBell(color: brandColor),
                          GestureDetector(
                            onTap: () => setState(() => _selectedIndex = 4),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: brandColor,
                              backgroundImage: hasAvatar
                                  ? NetworkImage(
                                      ApiEndpoints.mediaUrl(
                                        profile.profilePicture,
                                      ),
                                    )
                                  : null,
                              child: hasAvatar
                                  ? null
                                  : const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // SEARCH BAR
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search recipes...',
                        hintStyle: const TextStyle(
                          fontFamily: 'OpenSans Regular',
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: Icon(Icons.tune, color: brandColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'OpenSans Regular'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CATEGORY CHIPS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final cat in kRecipeCategories) ...[
                          _buildCategoryChip(
                            label: cat,
                            selected: state.category == cat,
                            brandColor: brandColor,
                            onTap: () => ref
                                .read(recipeListViewModelProvider.notifier)
                                .setCategory(cat),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chef Specials Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Chef's Specials",
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'OpenSans Bold',
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.recipeList),
                        child: Text(
                          'VIEW ALL',
                          style: TextStyle(
                            color: brandColor,
                            fontSize: 12,
                            fontFamily: 'OpenSans SemiBold',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildRecipeSections(state, brandColor),
                  const SizedBox(height: 32),

                  // Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 220, 125, 10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-RECIPE PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'OpenSans Bold',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'GET ACCESS TO MORE RECIPES',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'OpenSans Regular',
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProMembershipPage(),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: brandColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'GET PRO',
                            style: TextStyle(fontFamily: 'OpenSans SemiBold'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const DiscoverTab(),
          const SavedTab(),
          const PurchasedTab(),
          const ProfileTab(),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: cardColor,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontFamily: 'OpenSans SemiBold'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'OpenSans Regular'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Purchased',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? brandColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontFamily: selected ? 'OpenSans Bold' : 'OpenSans Regular',
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeSections(RecipeListState state, Color brandColor) {
    if (state.status == RecipeListStatus.loading && state.recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: brandColor)),
      );
    }

    if (state.status == RecipeListStatus.error && state.recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(state.message ?? 'Something went wrong.')),
      );
    }

    if (state.recipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('No recipes found.')),
      );
    }

    final specials = state.recipes.take(3).toList();
    final trending = state.recipes.skip(3).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final recipe in specials) ...[
                  _buildChefCard(recipe: recipe, brandColor: brandColor),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ),
        if (trending.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text(
            'EASY TO COOK NOW',
            style: TextStyle(fontSize: 18, fontFamily: 'OpenSans Bold'),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < trending.length; i += 2) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTrendingCard(
                    recipe: trending[i],
                    brandColor: brandColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: i + 1 < trending.length
                      ? _buildTrendingCard(
                          recipe: trending[i + 1],
                          brandColor: brandColor,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  // Chef card with CachedNetworkImage
  Widget _buildChefCard({
    required RecipeEntity recipe,
    required Color brandColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    top: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: recipe.image,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 110,
                      width: double.infinity,
                      color: const Color(0xFFE8D9CC),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 110,
                      width: double.infinity,
                      color: const Color(0xFFE8D9CC),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 40,
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
              child: Text(
                recipe.title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'OpenSans Bold',
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Trending card with CachedNetworkImage
  Widget _buildTrendingCard({
    required RecipeEntity recipe,
    required Color brandColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeDetail,
        arguments: recipe.id,
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
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
                  child: CachedNetworkImage(
                    imageUrl: recipe.image,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 100,
                      width: double.infinity,
                      color: const Color(0xFFE0D5C8),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: double.infinity,
                      color: const Color(0xFFE0D5C8),
                      child: const Center(
                        child: Icon(
                          Icons.food_bank,
                          size: 40,
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
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'OpenSans Bold',
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
