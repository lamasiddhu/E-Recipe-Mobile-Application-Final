class AdminDashboardState {
  final bool loading;
  final String? error;
  final Map<String, dynamic> dashboard;
  final Map<String, dynamic> settings;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> recipes;
  final DateTime? lastUpdated;

  const AdminDashboardState({
    this.loading = true,
    this.error,
    this.dashboard = const {},
    this.settings = const {},
    this.users = const [],
    this.orders = const [],
    this.recipes = const [],
    this.lastUpdated,
  });

  AdminDashboardState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? dashboard,
    Map<String, dynamic>? settings,
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? orders,
    List<Map<String, dynamic>>? recipes,
    DateTime? lastUpdated,
  }) {
    return AdminDashboardState(
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      dashboard: dashboard ?? this.dashboard,
      settings: settings ?? this.settings,
      users: users ?? this.users,
      orders: orders ?? this.orders,
      recipes: recipes ?? this.recipes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
