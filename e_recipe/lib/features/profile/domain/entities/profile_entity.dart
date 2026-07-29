class ProfileEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String bio;
  final String profilePicture;
  final String role;
  final bool isPro;

  const ProfileEntity({
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

  String get displayName => '$firstName $lastName'.trim();
}
