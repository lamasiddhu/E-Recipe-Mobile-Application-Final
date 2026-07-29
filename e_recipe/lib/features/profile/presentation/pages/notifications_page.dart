import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/profile/presentation/pages/change_password_page.dart';
import 'package:e_recipe/features/profile/presentation/pages/recovery_password_page.dart';
import 'package:e_recipe/features/recipe/presentation/pages/recipe_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ref
          .read(profileExtrasUseCasesProvider)
          .notifications();
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final id = (item['_id'] ?? item['id']).toString();
    await ref.read(profileExtrasUseCasesProvider).markNotificationRead(id);
    if (item['action'] == 'reset_password' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecoveryPasswordPage(
            notificationId: id,
            token: item['resetToken']?.toString() ?? '',
          ),
        ),
      );
    } else if (item['action'] == 'change_password' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
      );
    } else if (item['action'] == 'open_recipe' && mounted) {
      final recipeId = item['recipeId']?.toString() ?? '';
      if (recipeId.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailView(recipeId: recipeId),
          ),
        );
      }
    } else if (item['action'] == 'discover_recipes' && mounted) {
      Navigator.pop(context);
    }
    await _load();
  }

  Future<void> _markAllRead() async {
    await ref.read(profileExtrasUseCasesProvider).markAllNotificationsRead();
    await _load();
  }

  Future<void> _clearAll() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear all notifications?'),
            content: const Text(
              'They will remain cleared after you log out and sign in again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await ref.read(profileExtrasUseCasesProvider).clearNotifications();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFF7F2E9),
        foregroundColor: const Color(0xFFB84715),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'read') _markAllRead();
              if (value == 'clear') _clearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'read',
                child: ListTile(
                  leading: Icon(Icons.done_all),
                  title: Text('Mark all as read'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  title: Text('Clear all', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text('No notifications yet.'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final unread = item['read'] != true;
                  return Card(
                    color: unread ? const Color(0xFFFFF0E8) : Colors.white,
                    child: ListTile(
                      onTap: () => _open(item),
                      leading: Icon(
                        item['type'] == 'security'
                            ? Icons.password
                            : Icons.notifications,
                        color: const Color(0xFFB84715),
                      ),
                      title: Text(item['message']?.toString() ?? ''),
                      subtitle: Text(
                        item['action'] == 'change_password' ||
                                item['action'] == 'reset_password'
                            ? 'Tap to change your password'
                            : item['action'] == 'open_recipe'
                            ? 'Tap to view this recipe'
                            : item['action'] == 'discover_recipes'
                            ? 'Tap to discover recipes'
                            : 'E-Recipe notification',
                      ),
                      trailing: unread
                          ? const CircleAvatar(
                              radius: 4,
                              backgroundColor: Color(0xFFB84715),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
