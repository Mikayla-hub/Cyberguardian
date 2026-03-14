import 'package:phishguard_ai/features/auth/domain/entities/user.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.role,
    super.avatarUrl,
    super.biometricEnabled,
    required super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.employee,
      ),
      avatarUrl: json['avatar_url'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'role': role.name,
        'avatar_url': avatarUrl,
        'biometric_enabled': biometricEnabled,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
      };
}
