import 'package:e_recipe/app/theme/theme_mode_provider.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/core/services/biometrics/biometric_service.dart';

const _brandColor = Color(0xFFB84715);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late bool _recipeUpdates;
  late bool _proOffers;
  late bool _compactCards;
  late bool _biometrics;
  bool _biometricAvailable = false;

  bool _read(String key, bool fallback) {
    return ref
        .read(profileExtrasUseCasesProvider)
        .readLocalSetting(key, fallback);
  }

  @override
  void initState() {
    super.initState();
    _recipeUpdates = _read('setting_recipe_updates', true);
    _proOffers = _read('setting_pro_offers', true);
    _compactCards = _read('setting_compact_cards', false);
    _biometrics = BiometricService().isEnabled;
    if (_biometrics) {
      BiometricService().rememberCurrentSession();
    }
    _loadPreferences();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await BiometricService().isAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  Future<void> _loadPreferences() async {
    try {
      final data = await ref
          .read(profileExtrasUseCasesProvider)
          .notificationPreferences();
      if (!mounted) return;
      setState(() {
        _recipeUpdates = data['recipeUpdatesEnabled'] != false;
        _proOffers = data['proOffersEnabled'] != false;
      });
    } catch (_) {
      // Keep the last locally cached values while offline.
    }
  }

  Future<void> _saveNotificationPreferences() async {
    await Future.wait([
      _write('setting_recipe_updates', _recipeUpdates),
      _write('setting_pro_offers', _proOffers),
      ref
          .read(profileExtrasUseCasesProvider)
          .saveNotificationPreferences(
            recipeUpdates: _recipeUpdates,
            proOffers: _proOffers,
          ),
    ]);
  }

  Future<void> _write(String key, bool value) async {
    await ref.read(profileExtrasUseCasesProvider).writeLocalSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _switch(
            title: 'Recipe updates',
            subtitle: 'New recipes and category recommendations',
            value: _recipeUpdates,
            onChanged: (value) async {
              setState(() => _recipeUpdates = value);
              await _saveNotificationPreferences();
            },
          ),
          _switch(
            title: 'E-Recipe Pro offers',
            subtitle: 'Membership offers and Pro announcements',
            value: _proOffers,
            onChanged: (value) async {
              setState(() => _proOffers = value);
              await _saveNotificationPreferences();
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.brightness_6_outlined),
                  title: Text('App theme'),
                  subtitle: Text('Choose light, dark, or device theme'),
                ),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.settings_suggest_outlined),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selection) => ref
                        .read(themeModeProvider.notifier)
                        .setMode(selection.first),
                  ),
                ),
              ],
            ),
          ),
          _switch(
            title: 'Compact recipe cards',
            subtitle: 'Show more recipes on each screen',
            value: _compactCards,
            onChanged: (value) {
              setState(() => _compactCards = value);
              _write('setting_compact_cards', value);
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Security',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _switch(
            title: 'Fingerprint authentication',
            subtitle: _biometricAvailable
                ? 'Use biometrics for login and eSewa payments'
                : 'No fingerprint or biometric sensor is available',
            value: _biometrics,
            onChanged: _biometricAvailable
                ? (value) async {
                    final changed = await BiometricService().setEnabled(value);
                    if (!mounted || !context.mounted) return;
                    if (changed) {
                      setState(() => _biometrics = value);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Fingerprint verification was not completed.',
                          ),
                        ),
                      );
                    }
                  }
                : (_) {},
          ),
        ],
      ),
    );
  }

  Widget _switch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        activeThumbColor: _brandColor,
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
