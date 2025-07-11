import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';

class AdministratorModel extends Administrator {
  const AdministratorModel({
    required super.id,
    required super.name,
    required super.email,
    super.profileImageUrl,
    required super.role,
    required super.isDarkThemeEnabled,
    required super.lastLogin,
  });

  factory AdministratorModel.fromJson(Map<String, dynamic> json) {
    return AdministratorModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
      role: _roleFromString(json['role']),
      isDarkThemeEnabled: json['is_dark_theme_enabled'],
      lastLogin: DateTime.parse(json['last_login']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'role': _roleToString(role),
      'is_dark_theme_enabled': isDarkThemeEnabled,
      'last_login': lastLogin.toIso8601String(),
    };
  }

  static AdministratorRole _roleFromString(String role) {
    switch (role) {
      case 'super_admin':
        return AdministratorRole.superAdmin;
      case 'admin':
        return AdministratorRole.admin;
      case 'supervisor':
        return AdministratorRole.supervisor;
      default:
        return AdministratorRole.admin;
    }
  }

  static String _roleToString(AdministratorRole role) {
    switch (role) {
      case AdministratorRole.superAdmin:
        return 'super_admin';
      case AdministratorRole.admin:
        return 'admin';
      case AdministratorRole.supervisor:
        return 'supervisor';
    }
  }
}
