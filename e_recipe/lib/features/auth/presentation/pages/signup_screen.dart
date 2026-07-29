import 'package:e_recipe/features/auth/presentation/pages/login_screen.dart';
import 'package:e_recipe/features/auth/presentation/state/auth_state.dart';
import 'package:e_recipe/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'signup_screen_state.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}
