import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/features/auth/presentation/pages/login_screen.dart';
import 'package:e_recipe/features/profile/presentation/pages/change_password_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/help_support_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/pro_membership_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/settings_page.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:e_recipe/features/purchase/presentation/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

const _brandColor = Color(0xFFB84715);

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).load();
    });
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
      (_) {
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      },
    );
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final profile = state.profile;

    if (state.loading && profile == null) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator(color: _brandColor)),
      );
    }

    if (profile == null) {
      return SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message ?? 'Unable to load your profile.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(profileViewModelProvider.notifier).load(),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final hasAvatar =
        profile.profilePicture.isNotEmpty &&
        profile.profilePicture != 'default-profile.png';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(profileViewModelProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: _brandColor,
                    fontSize: 24,
                    fontFamily: 'OpenSans Bold',
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () => _open(const EditProfilePage()),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFFE8D9CC),
                    backgroundImage: hasAvatar
                        ? NetworkImage(
                            ApiEndpoints.mediaUrl(profile.profilePicture),
                          )
                        : null,
                    child: hasAvatar
                        ? null
                        : Text(
                            profile.firstName.isEmpty
                                ? '?'
                                : profile.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              color: _brandColor,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      profile.bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4D6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.isPro ? 'PRO MEMBER' : 'FREE MEMBER',
                      style: const TextStyle(
                        color: _brandColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _tile(
              icon: Icons.phone_outlined,
              title: 'Phone number',
              subtitle: profile.phone.isEmpty
                  ? 'Add phone number'
                  : profile.phone,
              onTap: () => _open(const EditProfilePage()),
            ),
            _tile(
              icon: Icons.workspace_premium_outlined,
              title: 'E-Recipe Pro',
              subtitle: profile.isPro
                  ? 'Your Pro membership is active'
                  : 'Unlock every recipe and Pro feature',
              onTap: () => _open(const ProMembershipPage()),
            ),
            _tile(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              subtitle: 'View recipe purchases and payment history',
              onTap: () => _open(const OrdersPage()),
            ),
            _tile(
              icon: Icons.lock_outline,
              title: 'Change password',
              subtitle: 'Update your account password',
              onTap: () => _open(const ChangePasswordPage()),
            ),
            _tile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Notifications and app preferences',
              onTap: () => _open(const SettingsPage()),
            ),
            _tile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and contact support',
              onTap: () => _open(const HelpSupportPage()),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _loggingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: _brandColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
