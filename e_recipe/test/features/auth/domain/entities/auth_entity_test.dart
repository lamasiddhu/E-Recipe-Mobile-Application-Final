import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('AuthEntity', () {
    test('display name joins names', () {
      expect(testUser.displayName, 'Siddhartha Lama');
    });
    test('display name trims an empty last name', () {
      const user = AuthEntity(
        firstName: 'Sita',
        lastName: '',
        email: '',
        phone: '',
        password: '',
      );
      expect(user.displayName, 'Sita');
    });
  });
}
