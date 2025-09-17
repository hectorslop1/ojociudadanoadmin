import 'dart:math';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';

/// Servicio para asignar técnicos a reportes de manera inteligente
class TechnicianAssignmentService {
  /// Sugiere el mejor técnico para un reporte basado en varios factores
  /// Devuelve una lista de técnicos ordenados por idoneidad (el mejor primero)
  List<Technician> suggestTechnicians(
    Report report,
    List<Technician> availableTechnicians,
  ) {
    if (availableTechnicians.isEmpty) {
      return [];
    }

    // Calcular puntuación para cada técnico
    final scoredTechnicians = availableTechnicians.map((technician) {
      final score = _calculateAssignmentScore(report, technician);
      return (technician, score);
    }).toList();

    // Ordenar por puntuación (mayor a menor)
    scoredTechnicians.sort((a, b) => b.$2.compareTo(a.$2));

    // Devolver lista ordenada de técnicos
    return scoredTechnicians.map((t) => t.$1).toList();
  }

  /// Calcula una puntuación de idoneidad para asignar un técnico a un reporte
  /// Mayor puntuación significa mejor coincidencia
  double _calculateAssignmentScore(Report report, Technician technician) {
    double score = 0.0;

    // Factor 1: Especialidad del técnico (peso: 40%)
    score += _getSpecialtyScore(report.category, technician) * 0.4;

    // Factor 2: Carga de trabajo actual (peso: 30%)
    score += _getWorkloadScore(technician) * 0.3;

    // Factor 3: Proximidad geográfica (peso: 20%)
    score += _getProximityScore(
      report.latitude,
      report.longitude,
      technician.lastKnownLatitude,
      technician.lastKnownLongitude,
    ) * 0.2;

    // Factor 4: Historial de eficiencia (peso: 10%)
    score += _getEfficiencyScore(technician) * 0.1;

    return score;
  }

  /// Calcula puntuación basada en la especialidad del técnico
  /// Rango: 0-10 (10 es la mejor coincidencia)
  double _getSpecialtyScore(ReportCategory category, Technician technician) {
    // Verificar si la categoría está en las especialidades del técnico
    if (technician.specialties.contains(_mapCategoryToSpecialty(category))) {
      return 10.0; // Coincidencia perfecta
    }

    // Verificar si hay especialidades relacionadas
    final relatedSpecialties = _getRelatedSpecialties(category);
    for (final specialty in relatedSpecialties) {
      if (technician.specialties.contains(specialty)) {
        return 7.0; // Especialidad relacionada
      }
    }

    // Sin especialidad relevante
    return 3.0;
  }

  /// Calcula puntuación basada en la carga de trabajo actual
  /// Rango: 0-10 (10 es la menor carga de trabajo)
  double _getWorkloadScore(Technician technician) {
    // Simulación: usar el número de reportes asignados actualmente
    final assignedReports = technician.assignedReports?.length ?? 0;
    
    if (assignedReports == 0) {
      return 10.0; // Sin carga de trabajo
    } else if (assignedReports < 3) {
      return 8.0; // Carga baja
    } else if (assignedReports < 5) {
      return 5.0; // Carga media
    } else if (assignedReports < 8) {
      return 3.0; // Carga alta
    } else {
      return 1.0; // Sobrecargado
    }
  }

  /// Calcula puntuación basada en la proximidad geográfica
  /// Rango: 0-10 (10 es la mayor proximidad)
  double _getProximityScore(
    double reportLat,
    double reportLng,
    double? techLat,
    double? techLng,
  ) {
    // Si no hay ubicación conocida del técnico
    if (techLat == null || techLng == null) {
      return 5.0; // Puntuación neutral
    }

    // Calcular distancia aproximada usando la fórmula de Haversine
    final distance = _calculateDistance(reportLat, reportLng, techLat, techLng);
    
    // Convertir distancia a puntuación (menor distancia = mayor puntuación)
    if (distance < 1) {
      return 10.0; // Menos de 1 km
    } else if (distance < 3) {
      return 8.0; // 1-3 km
    } else if (distance < 5) {
      return 6.0; // 3-5 km
    } else if (distance < 10) {
      return 4.0; // 5-10 km
    } else if (distance < 20) {
      return 2.0; // 10-20 km
    } else {
      return 1.0; // Más de 20 km
    }
  }

  /// Calcula puntuación basada en la eficiencia histórica del técnico
  /// Rango: 0-10 (10 es la mayor eficiencia)
  double _getEfficiencyScore(Technician technician) {
    // Simulación: usar la calificación del técnico
    final rating = technician.rating ?? 0.0;
    
    // Convertir calificación (0-5) a puntuación (0-10)
    return rating * 2;
  }

  /// Calcula la distancia aproximada entre dos puntos geográficos en kilómetros
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // Radio de la Tierra en km
    
    // Convertir a radianes
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    // Fórmula de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Convierte grados a radianes
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Mapea una categoría de reporte a una especialidad de técnico
  String _mapCategoryToSpecialty(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 'Bacheo';
      case ReportCategory.garbageCollection:
        return 'Recolección';
      case ReportCategory.streetImprovement:
        return 'Mejoramiento de la Imagen Urbana';
    }
  }

  /// Obtiene especialidades relacionadas para una categoría
  List<String> _getRelatedSpecialties(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return ['Infraestructura', 'Construcción'];
      case ReportCategory.garbageCollection:
        return ['Limpieza', 'Servicios Públicos'];
      case ReportCategory.streetImprovement:
        return ['Mantenimiento', 'Infraestructura', 'Construcción'];
    }
  }
}
