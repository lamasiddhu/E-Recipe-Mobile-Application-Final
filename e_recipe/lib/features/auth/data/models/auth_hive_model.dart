import 'package:e_recipe/core/constants/hive_table_constant.dart';
import 'package:e_recipe/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String password;

  AuthHiveModel({
    String? userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  }) : userId = userId ?? const Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      phone: entity.phone,
      email: entity.email.toLowerCase(),
      password: entity.password,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
    );
  }
}
