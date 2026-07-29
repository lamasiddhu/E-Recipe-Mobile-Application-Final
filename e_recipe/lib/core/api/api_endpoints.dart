class ApiEndpoints {
  // For physical device (your OPPO phone)
  static const String baseUrl = 'http://192.168.1.85:3000/api/v1';

  // For Android emulator, use:
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Auth Endpoints
  static const String register = '/users/register';
  static const String login = '/users/login';
  static const String getMe = '/users/me';
  static const String updateProfile = '/users/me';
  static const String changePassword = '/users/me/password';
  static const String uploadAvatar = '/users/me/avatar';

  static String mediaUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return '$baseUrl${path.startsWith('/') ? path : '/$path'}';
  }

  // User Endpoints
  static String user(String id) => '/users/$id';

  // Meal Endpoints
  static const String meals = '/meals';
  static String meal(String id) => '/meals/$id';

  // Workout Endpoints
  static const String workouts = '/workouts';
  static String workout(String id) => '/workouts/$id';

  // Progress Endpoints
  static const String progress = '/progress';
  static String progressEntry(String id) => '/progress/$id';

  // Recipe Endpoints
  static const String recipes = '/recipes';
  static String recipe(String id) => '/recipes/$id';

  // Order Endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';
}
