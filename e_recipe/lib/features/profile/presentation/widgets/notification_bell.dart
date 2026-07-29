import 'dart:async';

import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/profile/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationBell extends ConsumerStatefulWidget {
  final Color color;

  const NotificationBell({super.key, required this.color});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  int _unread = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final data = await ref
          .read(profileExtrasUseCasesProvider)
          .notifications();
      final unread = data.where((item) => item['read'] != true).length;
      if (mounted) setState(() => _unread = unread);
    } catch (_) {
      // Keep the last count when the network is temporarily unavailable.
    }
  }

  Future<void> _open() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: _open,
      icon: Badge(
        isLabelVisible: _unread > 0,
        label: Text(_unread > 99 ? '99+' : '$_unread'),
        child: Icon(Icons.notifications_outlined, color: widget.color),
      ),
    );
  }
}
