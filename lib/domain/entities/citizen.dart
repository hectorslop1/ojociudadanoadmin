import 'package:equatable/equatable.dart';

class Citizen extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime registeredAt;

  const Citizen({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    profileImageUrl,
    registeredAt,
  ];

  Citizen copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? registeredAt,
  }) {
    return Citizen(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }
}
