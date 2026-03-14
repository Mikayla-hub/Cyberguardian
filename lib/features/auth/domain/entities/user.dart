import 'package:equatable/equatable.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.biometricEnabled = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isIT => role == UserRole.it;

  @override
  List<Object?> get props => [id, email, role];
}
