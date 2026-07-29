import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';

class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String bio;
  final String profilePicture;
  final String role;
  final bool isPro;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.bio,
    required this.profilePicture,
    required this.role,
    required this.isPro,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      profilePicture: json['profilePicture']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      isPro: json['isPro'] == true,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      bio: bio,
      profilePicture: profilePicture,
      role: role,
      isPro: isPro,
    );
  }
}
