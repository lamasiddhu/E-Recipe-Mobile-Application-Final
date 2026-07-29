import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/features/auth/presentation/pages/login_screen.dart';
import 'package:e_recipe/features/auth/presentation/pages/signup_screen.dart';
import 'package:e_recipe/features/dashboard/presentation/pages/dashboard_view.dart';
import 'package:e_recipe/features/onboarding/presentation/pages/onboarding_view.dart';
import 'package:e_recipe/features/recipe/presentation/pages/recipe_detail_view.dart';
import 'package:e_recipe/features/recipe/presentation/pages/recipe_list_view.dart';
import 'package:e_recipe/features/splash/presentation/pages/splash_view.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashView());
    case AppRoutes.onboarding:
      return MaterialPageRoute(builder: (_) => const OnboardingView());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const SignupView());
    case AppRoutes.dashboard:
      return MaterialPageRoute(builder: (_) => const DashboardView());
    case AppRoutes.recipeList:
      return MaterialPageRoute(builder: (_) => const RecipeListView());
    case AppRoutes.recipeDetail:
      final recipeId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => RecipeDetailView(recipeId: recipeId),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}
