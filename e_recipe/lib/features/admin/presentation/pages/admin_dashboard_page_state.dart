part of 'admin_dashboard_page.dart';

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _tab = 0;
  String _broadcastType = 'announcement';
  final _announcementCtrl = TextEditingController();

  // Safe to call from build() and from event handlers alike: ref.read never
  // requires the build-method context that ref.watch does.
  AdminDashboardState get _adminState =>
      ref.read(adminDashboardViewModelProvider);
  AdminDashboardViewModel get _api =>
      ref.read(adminDashboardViewModelProvider.notifier);

  bool get _loading => _adminState.loading;
  String? get _error => _adminState.error;
  Map<String, dynamic> get _dashboard => _adminState.dashboard;
  Map<String, dynamic> get _settings => _adminState.settings;
  List<Map<String, dynamic>> get _users => _adminState.users;
  List<Map<String, dynamic>> get _orders => _adminState.orders;
  List<Map<String, dynamic>> get _recipes => _adminState.recipes;
  DateTime? get _lastUpdated => _adminState.lastUpdated;

  Future<void> _loadAll() => _api.loadAll();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _announcementCtrl.dispose();
    super.dispose();
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(adminDashboardViewModelProvider);
    final profile = ref.watch(profileViewModelProvider).profile;
    final hasAvatar =
        profile != null &&
        profile.profilePicture.isNotEmpty &&
        profile.profilePicture != 'default-profile.png';
    final pages = [
      _dashboardTab(),
      _ordersTab(),
      _recipesTab(),
      _usersTab(),
      _settingsTab(),
    ];
    return Scaffold(
      backgroundColor: _adminBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _adminBrand,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _adminBrand,
              child: Icon(Icons.restaurant, size: 17, color: Colors.white),
            ),
            SizedBox(width: 9),
            Text(
              'E-Recipe Admin',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
          const NotificationBell(color: _adminBrand),
          IconButton(
            tooltip: 'Admin profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProfilePage()),
            ),
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFFFE4D8),
              backgroundImage: hasAvatar
                  ? NetworkImage(ApiEndpoints.mediaUrl(profile.profilePicture))
                  : null,
              child: hasAvatar
                  ? null
                  : const Icon(Icons.person, size: 18, color: _adminBrand),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _adminBrand))
          : _error != null
          ? _errorView()
          : SafeArea(child: pages[_tab]),
      floatingActionButton: _tab == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showRecipeForm(),
              backgroundColor: _adminBrand,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add recipe'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (value) => setState(() => _tab = value),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _adminBrand,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _errorView() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.admin_panel_settings, size: 52, color: _adminBrand),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
        ],
      ),
    ),
  );

  Widget _dashboardTab() {
    final chart = (_dashboard['chart'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final maxRevenue = chart.fold<double>(
      1,
      (max, item) => (item['revenue'] as num? ?? 0).toDouble() > max
          ? (item['revenue'] as num).toDouble()
          : max,
    );
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Platform Cockpit',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Real-time overview of your culinary ecosystem.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                _lastUpdated == null
                    ? 'Connecting to live data...'
                    : 'Live • updated ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}:${_lastUpdated!.second.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.green, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _statCard(
            'Total Users',
            '${_dashboard['totalUsers'] ?? 0}',
            Icons.people,
            Colors.orange,
          ),
          _statCard(
            'Revenue',
            'NPR ${_dashboard['revenue'] ?? 0}',
            Icons.payments,
            Colors.green,
          ),
          _statCard(
            'Pending Orders',
            '${_dashboard['pendingOrders'] ?? 0}',
            Icons.receipt_long,
            Colors.red,
          ),
          _statCard(
            'Recipes',
            '${_dashboard['totalRecipes'] ?? 0}',
            Icons.menu_book,
            _adminBrand,
          ),
          const SizedBox(height: 8),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interactive Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Weekly revenue',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 210,
                  child: BarChart(
                    BarChartData(
                      maxY: maxRevenue * 1.2,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text(
                                value.toInt() < chart.length
                                    ? chart[value.toInt()]['label'].toString()
                                    : '',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      barGroups: [
                        for (var index = 0; index < chart.length; index++)
                          BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (chart[index]['revenue'] as num? ?? 0)
                                    .toDouble(),
                                color: index == DateTime.now().weekday - 1
                                    ? _adminBrand
                                    : const Color(0xFFF4D8CE),
                                width: 17,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ordersTab() => _sectionList(
    title: 'Orders',
    subtitle: '${_orders.length} customer orders',
    children: _orders.map((order) {
      final status = order['status']?.toString() ?? 'Pending';
      return _card(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFFFE8DE),
            child: Icon(Icons.receipt_long, color: _adminBrand),
          ),
          title: Text(order['customer']?.toString() ?? 'Customer'),
          subtitle: Text(
            '${order['orderNumber'] ?? ''}\n${order['item'] ?? ''}',
          ),
          isThreeLine: true,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NPR ${order['price'] ?? 0}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(status, style: const TextStyle(color: _adminBrand)),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _recipesTab() => _sectionList(
    title: 'Recipe Catalogue',
    subtitle: 'Add and manage purchasable recipes',
    children: _recipes.map((recipe) {
      return _card(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: ApiEndpoints.mediaUrl(
                recipe['image']?.toString() ?? '',
              ),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                width: 52,
                height: 52,
                color: const Color(0xFFFFE8DE),
              ),
              errorWidget: (_, _, _) => Container(
                width: 52,
                height: 52,
                color: const Color(0xFFFFE8DE),
                child: const Icon(Icons.restaurant, color: _adminBrand),
              ),
            ),
          ),
          title: Text(recipe['title']?.toString() ?? ''),
          subtitle: Text(
            '${recipe['badge'] ?? 'Free'} • NPR ${recipe['price'] ?? 0}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit recipe',
                onPressed: () => _showRecipeForm(recipe),
                icon: const Icon(Icons.edit_outlined, color: _adminBrand),
              ),
              IconButton(
                tooltip: 'Delete recipe',
                onPressed: () => _confirmDeleteRecipe(recipe),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _usersTab() => _sectionList(
    title: 'Users',
    subtitle: 'Manage access, purchases, and notifications',
    children: _users.map(_userCard).toList(),
  );

  Widget _userCard(Map<String, dynamic> user) {
    final purchases = List<String>.from(
      user['purchasedRecipeIds'] as List? ?? [],
    );
    return _card(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFE8DE),
          child: Text(
            (user['name']?.toString().isNotEmpty ?? false)
                ? user['name'].toString()[0].toUpperCase()
                : 'U',
            style: const TextStyle(color: _adminBrand),
          ),
        ),
        title: Text(user['name']?.toString() ?? 'User'),
        subtitle: Text(
          '${user['email'] ?? ''}\n${user['role'] ?? 'user'}${user['isPro'] == true ? ' • PRO' : ''}',
        ),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _action(
                user['isPro'] == true ? 'Remove Pro' : 'Give Pro',
                Icons.workspace_premium,
                () => _updateUser(user, isPro: user['isPro'] != true),
              ),
              _action(
                user['role'] == 'admin' ? 'Make User' : 'Make Admin',
                Icons.admin_panel_settings,
                () => _updateUser(
                  user,
                  role: user['role'] == 'admin' ? 'user' : 'admin',
                ),
              ),
              _action(
                'Notify',
                Icons.notifications_active,
                () => _notify(user),
              ),
              _action('Recovery', Icons.password, () => _recovery(user)),
              _action(
                'Delete',
                Icons.delete_outline,
                () => _deleteUser(user),
                danger: true,
              ),
            ],
          ),
          const Divider(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Purchased recipes (${purchases.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (purchases.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('No purchases', style: TextStyle(color: Colors.grey)),
            ),
          for (final recipeId in purchases)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_recipeTitle(recipeId)),
              trailing: TextButton(
                onPressed: () => _removePurchase(user, recipeId),
                child: const Text('Remove'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _settingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Admin Settings',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Manage platform global configurations and system integrity.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.campaign, color: _adminBrand),
                title: Text(
                  'Global Announcements',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _announcementCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type the message to broadcast to all users...',
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _broadcastType,
                decoration: const InputDecoration(
                  labelText: 'Notification category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'announcement',
                    child: Text('General announcement'),
                  ),
                  DropdownMenuItem(
                    value: 'pro_offer',
                    child: Text('E-Recipe Pro offer'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _broadcastType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final sent = await _run(
                      () => _api.broadcast(
                        _announcementCtrl.text,
                        type: _broadcastType,
                      ),
                      successMessage: 'Message sent successfully.',
                    );
                    if (sent) _announcementCtrl.clear();
                    await _loadAll();
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Broadcast Message'),
                ),
              ),
            ],
          ),
        ),
        _card(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.build, color: _adminBrand),
                title: const Text(
                  'Maintenance Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Disable user access for an update'),
                value: _settings['maintenanceMode'] == true,
                onChanged: (value) async {
                  await _run(() => _api.maintenance(value));
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cached, color: _adminBrand),
                title: const Text('System Cache'),
                subtitle: Text(
                  _settings['cacheClearedAt'] == null
                      ? 'Not cleared yet'
                      : 'Last cleared ${_settings['cacheClearedAt']}',
                ),
                trailing: OutlinedButton(
                  onPressed: () async {
                    await _run(_api.clearCache);
                    await _loadAll();
                  },
                  child: const Text('Clear Cache'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionList({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) => RefreshIndicator(
    onRefresh: _loadAll,
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        if (children.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('Nothing here yet.')),
          ),
        ...children,
        const SizedBox(height: 75),
      ],
    ),
  );

  Widget _statCard(String title, String value, IconData icon, Color color) =>
      _card(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _card({required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _action(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool danger = false,
  }) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 16),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: danger ? Colors.red : _adminBrand,
    ),
  );

  String _recipeTitle(String id) {
    final found = _recipes.where((recipe) => recipe['_id'] == id);
    return found.isEmpty ? 'Recipe $id' : found.first['title'].toString();
  }

  Future<bool> _run(
    Future<void> Function() action, {
    String successMessage = 'Saved successfully.',
  }) async {
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_message(error))));
      }
      return false;
    }
  }

  Future<void> _updateUser(
    Map<String, dynamic> user, {
    String? role,
    bool? isPro,
  }) async {
    await _run(
      () => _api.updateUser(user['id'].toString(), role: role, isPro: isPro),
    );
    await _loadAll();
  }

  Future<void> _notify(Map<String, dynamic> user) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notify ${user['name']}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (message != null && message.trim().isNotEmpty) {
      await _run(() => _api.notifyUser(user['id'].toString(), message.trim()));
    }
  }

  Future<void> _recovery(Map<String, dynamic> user) =>
      _run(() => _api.sendRecovery(user['id'].toString()));

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    if (!await _confirm('Delete ${user['name']} and their orders?')) return;
    await _run(() => _api.deleteUser(user['id'].toString()));
    await _loadAll();
  }

  Future<void> _removePurchase(
    Map<String, dynamic> user,
    String recipeId,
  ) async {
    if (!await _confirm('Remove ${_recipeTitle(recipeId)} from this user?')) {
      return;
    }
    await _run(() => _api.removePurchase(user['id'].toString(), recipeId));
    await _loadAll();
  }

  Future<void> _confirmDeleteRecipe(Map<String, dynamic> recipe) async {
    if (!await _confirm('Delete ${recipe['title']}?')) return;
    await _run(() => _api.deleteRecipe(recipe['_id'].toString()));
    await _loadAll();
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _showRecipeForm([Map<String, dynamic>? recipe]) async {
    final editing = recipe != null;
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(
      text: recipe?['title']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: recipe?['description']?.toString() ?? '',
    );
    final ingredients = TextEditingController(
      text: (recipe?['ingredients'] as List? ?? []).join('\n'),
    );
    final instructions = TextEditingController(
      text: (recipe?['instructions'] as List? ?? []).join('\n'),
    );
    final time = TextEditingController(
      text: recipe?['totalTime']?.toString() ?? '30',
    );
    final price = TextEditingController(
      text: recipe?['price']?.toString() ?? '0',
    );
    final video = TextEditingController(
      text: recipe?['videoUrl']?.toString() ?? '',
    );
    String category = recipe?['category']?.toString() ?? 'Breakfast';
    String difficulty = recipe?['difficulty']?.toString() ?? 'Easy';
    String badge = recipe?['badge']?.toString() ?? 'Free';
    String? imagePath;

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editing ? 'Edit recipe' : 'Add recipe'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _requiredField(title, 'Recipe title'),
                    _requiredField(description, 'Description', lines: 2),
                    _requiredField(
                      ingredients,
                      'Ingredients (one per line)',
                      lines: 4,
                    ),
                    _requiredField(
                      instructions,
                      'Instructions (one per line)',
                      lines: 4,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      items:
                          {
                                'Breakfast',
                                'Lunch',
                                'Dinner',
                                'Healthy',
                                'Dessert',
                                'Snack',
                                // Always include the recipe's current value,
                                // even if it predates this fixed category
                                // list, so the dropdown never crashes on
                                // data that doesn't match the known set.
                                category,
                              }
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setDialogState(() => category = value!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: difficulty,
                      items: {'Easy', 'Medium', 'Hard', difficulty}
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => difficulty = value!),
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: badge,
                      items: {'Free', 'Normal', 'Pro', badge}
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => badge = value!),
                      decoration: const InputDecoration(labelText: 'Access'),
                    ),
                    TextField(
                      controller: time,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total time (minutes)',
                      ),
                    ),
                    TextField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (NPR)',
                      ),
                    ),
                    TextField(
                      controller: video,
                      decoration: const InputDecoration(
                        labelText: 'YouTube URL (optional)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setDialogState(() => imagePath = image.path);
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        imagePath == null
                            ? 'Choose recipe image'
                            : 'Image selected',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(context, {
                  'title': title.text.trim(),
                  'description': description.text.trim(),
                  'ingredients': ingredients.text
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .toList(),
                  'instructions': instructions.text
                      .split('\n')
                      .where((line) => line.trim().isNotEmpty)
                      .toList(),
                  'category': category,
                  'difficulty': difficulty,
                  'totalTime': int.tryParse(time.text) ?? 30,
                  'price': badge == 'Free' ? 0 : int.tryParse(price.text) ?? 0,
                  'badge': badge,
                  'videoUrl': video.text.trim(),
                });
              },
              child: Text(editing ? 'Save changes' : 'Add'),
            ),
          ],
        ),
      ),
    );
    if (data != null) {
      await _run(() async {
        if (imagePath != null) {
          data['image'] = await _api.uploadRecipeImage(imagePath!);
        }
        if (editing) {
          await _api.updateRecipe(recipe['_id'].toString(), data);
        } else {
          await _api.addRecipe(data);
        }
      });
      await _loadAll();
    }
  }

  Widget _requiredField(
    TextEditingController controller,
    String label, {
    int lines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: lines,
    decoration: InputDecoration(labelText: label),
    validator: (value) =>
        value == null || value.trim().isEmpty ? 'Required' : null,
  );
}
