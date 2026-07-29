import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/core/services/biometrics/biometric_service.dart';
import 'package:e_recipe/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:e_recipe/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_recipe/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:e_recipe/features/auth/presentation/pages/signup_screen.dart';
import 'package:e_recipe/features/dashboard/presentation/pages/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'login_screen_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
