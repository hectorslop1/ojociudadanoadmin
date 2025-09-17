import 'package:ojo_ciudadano_admin/domain/entities/report.dart';

/// Servicio para calcular la prioridad de los reportes
class ReportPriorityService {
  /// Calcula la prioridad de un reporte basado en varios factores
  /// Devuelve un valor entre 1 (baja) y 5 (alta)
  int calculatePriority(Report report) {
    int priorityScore = 0;
    
    // Factor 1: Categoría del reporte
    priorityScore += _getCategoryPriorityScore(report.category);
    
    // Factor 2: Tiempo transcurrido desde la creación
    priorityScore += _getAgePriorityScore(report.createdAt);
    
    // Factor 3: Ubicación (zonas prioritarias)
    // Esto requeriría datos adicionales sobre zonas prioritarias
    // Por ahora, usamos un valor aleatorio basado en la ubicación
    priorityScore += _getLocationPriorityScore(report.latitude, report.longitude);
    
    // Normalizar el puntaje a una escala de 1-5
    return _normalizePriorityScore(priorityScore);
  }
  
  /// Calcula la prioridad basada en la categoría del reporte
  int _getCategoryPriorityScore(ReportCategory category) {
    switch (category) {
      case ReportCategory.roadRepair:
        return 5; // Alta prioridad
      
      case ReportCategory.streetImprovement:
        return 4; // Media-alta prioridad
      
      case ReportCategory.garbageCollection:
        return 3; // Media prioridad
    }
  }
  
  /// Calcula la prioridad basada en la antigüedad del reporte
  int _getAgePriorityScore(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 30) {
      return 5; // Muy antiguo
    } else if (difference.inDays > 14) {
      return 4; // Antiguo
    } else if (difference.inDays > 7) {
      return 3; // Moderado
    } else if (difference.inDays > 3) {
      return 2; // Reciente
    } else {
      return 1; // Muy reciente
    }
  }
  
  /// Calcula la prioridad basada en la ubicación del reporte
  /// En una implementación real, esto verificaría zonas prioritarias
  int _getLocationPriorityScore(double latitude, double longitude) {
    // Simulación: usar los últimos dígitos de lat/long para generar un valor
    final latLastDigit = (latitude * 1000).toInt() % 10;
    final longLastDigit = (longitude * 1000).toInt() % 10;
    
    // Combinar para obtener un valor entre 0-9
    final combinedValue = (latLastDigit + longLastDigit) % 5;
    
    // Convertir a escala 1-5
    return combinedValue + 1;
  }
  
  /// Normaliza el puntaje de prioridad a una escala de 1-5
  int _normalizePriorityScore(int rawScore) {
    // El puntaje máximo posible es 15 (5+5+5)
    // El puntaje mínimo posible es 3 (1+1+1)
    
    if (rawScore >= 13) {
      return 5; // Prioridad muy alta
    } else if (rawScore >= 10) {
      return 4; // Prioridad alta
    } else if (rawScore >= 7) {
      return 3; // Prioridad media
    } else if (rawScore >= 5) {
      return 2; // Prioridad baja
    } else {
      return 1; // Prioridad muy baja
    }
  }
}
