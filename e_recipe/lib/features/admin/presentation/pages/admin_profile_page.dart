import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/features/auth/presentation/pages/login_screen.dart';
import 'package:e_recipe/features/profile/presentation/pages/change_password_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

class AdminProfilePage extends ConsumerStatefulWidget {
  const AdminProfilePage({super.key});

  @override
  ConsumerState<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends ConsumerState<AdminProfilePage> {
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(profileViewModelProvider.notifier).load(),
    );
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    final result = await ref.read(logoutUseCaseProvider)();
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final profile = state.profile;
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFC84616),
      ),
      body: profile == null
          ? Center(
              child: state.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () =>
                          ref.read(profileViewModelProvider.notifier).load(),
                      child: const Text('Load profile'),
                    ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFFFE4D8),
                        backgroundImage:
                            profile.profilePicture.isNotEmpty &&
                                profile.profilePicture != 'default-profile.png'
                            ? NetworkImage(
                                ApiEndpoints.mediaUrl(profile.profilePicture),
                              )
                            : null,
                        child:
                            profile.profilePicture.isEmpty ||
                                profile.profilePicture == 'default-profile.png'
                            ? Text(
                                profile.firstName.isEmpty
                                    ? 'A'
                                    : profile.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  color: Color(0xFFC84616),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 9),
                      const Chip(
                        avatar: Icon(Icons.admin_panel_settings, size: 17),
                        label: Text('ADMINISTRATOR'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  tileColor: Colors.white,
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profile and picture'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),
                const SizedBox(height: 9),
                ListTile(
                  tileColor: Colors.white,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _loggingOut ? null : _logout,
                  icon: _loggingOut
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout),
                  label: const Text('Log out of Admin'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
    );
  }
}
