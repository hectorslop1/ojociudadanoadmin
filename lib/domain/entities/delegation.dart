import 'package:equatable/equatable.dart';

class Delegation extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? boundaryPolygon; // GeoJSON para representar los límites
  final bool isActive;

  const Delegation({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.boundaryPolygon,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, description, latitude, longitude, boundaryPolygon, isActive];

  Delegation copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? boundaryPolygon,
    bool? isActive,
  }) {
    return Delegation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      boundaryPolygon: boundaryPolygon ?? this.boundaryPolygon,
      isActive: isActive ?? this.isActive,
    );
  }
}
