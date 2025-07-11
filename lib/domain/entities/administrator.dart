import 'package:equatable/equatable.dart';

enum AdministratorRole {
  superAdmin,
  admin,
  supervisor
}

class Administrator extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final AdministratorRole role;
  final bool isDarkThemeEnabled;
  final DateTime lastLogin;

  const Administrator({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.role,
    required this.isDarkThemeEnabled,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    profileImageUrl,
    role,
    isDarkThemeEnabled,
    lastLogin,
  ];

  Administrator copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    AdministratorRole? role,
    bool? isDarkThemeEnabled,
    DateTime? lastLogin,
  }) {
    return Administrator(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      isDarkThemeEnabled: isDarkThemeEnabled ?? this.isDarkThemeEnabled,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
