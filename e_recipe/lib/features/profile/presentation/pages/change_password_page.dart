import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _brandColor = Color(0xFFB84715);

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final result = await ref
        .read(profileViewModelProvider.notifier)
        .changePassword(
          currentPassword: _current.text,
          newPassword: _newPassword.text,
        );
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.')),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color(0xFFF7F2E9),
        foregroundColor: _brandColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _passwordField(_current, 'Current password'),
            _passwordField(_newPassword, 'New password'),
            _passwordField(
              _confirm,
              'Confirm new password',
              confirmation: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _saving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Change password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    bool confirmation = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (confirmation && value != _newPassword.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }
}
