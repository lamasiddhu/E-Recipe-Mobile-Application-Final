import 'package:e_recipe/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile display name joins names', () {
    const profile = ProfileEntity(
      id: '1',
      firstName: 'Sita',
      lastName: 'Rai',
      email: 'sita@example.com',
      phone: '9800000000',
      bio: '',
      profilePicture: '',
      role: 'user',
      isPro: false,
    );
    expect(profile.displayName, 'Sita Rai');
  });
}
