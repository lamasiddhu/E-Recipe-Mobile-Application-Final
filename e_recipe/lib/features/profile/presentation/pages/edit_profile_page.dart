import 'dart:io';

import 'package:e_recipe/core/api/api_endpoints.dart';
import 'package:e_recipe/features/profile/presentation/view_model/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_recipe/core/services/permissions/app_permission_service.dart';
import 'package:permission_handler/permission_handler.dart';

const _brandColor = Color(0xFFB84715);

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _bio;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileViewModelProvider).profile!;
    _firstName = TextEditingController(text: profile.firstName);
    _lastName = TextEditingController(text: profile.lastName);
    _phone = TextEditingController(text: profile.phone);
    _bio = TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final status = source == ImageSource.camera
        ? await AppPermissionService.requestCamera()
        : await AppPermissionService.requestGallery();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        _show('Permission is disabled. Enable it from app settings.');
        await openAppSettings();
      } else {
        _show(
          source == ImageSource.camera
              ? 'Camera permission is needed to take a photo.'
              : 'Photo permission is needed to choose a picture.',
        );
      }
      return;
    }
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _chooseImageSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Change profile picture',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(profileViewModelProvider.notifier);
    final updateResult = await notifier.update(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: _phone.text.trim(),
      bio: _bio.text.trim(),
    );
    var successful = false;
    updateResult.fold(
      (failure) => _show(failure.message),
      (_) => successful = true,
    );
    if (!successful || !mounted) return;

    if (_selectedImage != null) {
      final uploadResult = await notifier.uploadAvatar(_selectedImage!.path);
      uploadResult.fold((failure) {
        successful = false;
        _show(failure.message);
      }, (_) => successful = true);
    }

    if (successful && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.pop(context);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileViewModelProvider);
    final profile = state.profile!;
    final hasRemoteImage =
        profile.profilePicture.isNotEmpty &&
        profile.profilePicture != 'default-profile.png';

    ImageProvider? avatar;
    if (_selectedImage != null) {
      avatar = FileImage(File(_selectedImage!.path));
    } else if (hasRemoteImage) {
      avatar = NetworkImage(ApiEndpoints.mediaUrl(profile.profilePicture));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: _brandColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFE8D9CC),
                          backgroundImage: avatar,
                          child: avatar == null
                              ? const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: _brandColor,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            onPressed: _chooseImageSource,
                            style: IconButton.styleFrom(
                              backgroundColor: _brandColor,
                            ),
                            icon: const Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _chooseImageSource,
                      child: const Text('Change profile picture'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Personal details',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).cardColor,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _field(
                      _firstName,
                      'First name',
                      icon: Icons.person_outline,
                    ),
                    _field(_lastName, 'Last name', icon: Icons.person_outline),
                    _field(
                      _phone,
                      'Phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return 'Phone number is required';
                        if (!RegExp(r'^\+?\d{7,15}$').hasMatch(phone)) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _bio,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 240,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration(
                        'Bio',
                        icon: Icons.edit_note_outlined,
                        hint: 'Tell people a little about yourself',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: state.saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: keyboardType == TextInputType.phone
            ? TextCapitalization.none
            : TextCapitalization.words,
        decoration: _decoration(label, icon: icon),
        validator:
            validator ??
            (value) => value == null || value.trim().isEmpty
                ? '$label is required'
                : null,
      ),
    );
  }

  InputDecoration _decoration(
    String label, {
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4DED7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE4DED7)),
      ),
    );
  }
}
