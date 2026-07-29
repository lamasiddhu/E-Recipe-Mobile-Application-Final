import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecoveryPasswordPage extends ConsumerStatefulWidget {
  final String notificationId;
  final String token;

  const RecoveryPasswordPage({
    super.key,
    required this.notificationId,
    required this.token,
  });

  @override
  ConsumerState<RecoveryPasswordPage> createState() =>
      _RecoveryPasswordPageState();
}

class _RecoveryPasswordPageState extends ConsumerState<RecoveryPasswordPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileExtrasUseCasesProvider)
          .resetPasswordFromNotification(
            notificationId: widget.notificationId,
            token: widget.token,
            newPassword: _password.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        title: const Text('Secure Your Account'),
        backgroundColor: const Color(0xFFF7F2E9),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.password, size: 60, color: Color(0xFFB84715)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value == null || value.length < 6
                  ? 'Use at least 6 characters'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Change password'),
            ),
          ],
        ),
      ),
    );
  }
}
