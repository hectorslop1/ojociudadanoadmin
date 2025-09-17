import 'dart:math';

import 'package:ojo_ciudadano_admin/domain/entities/citizen.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';

/// Clase que proporciona datos de demostración para la aplicación
class DemoData {
  /// Lista de URLs de imágenes de demostración
  static final List<String> demoImageUrls = [
    // URLs estáticas de imágenes confiables
    'https://picsum.photos/id/237/800/600', // Bache 1
    'https://picsum.photos/id/238/800/600', // Bache 2
    'https://picsum.photos/id/239/800/600', // Basura 1
    'https://picsum.photos/id/240/800/600', // Basura 2
    'https://picsum.photos/id/241/800/600', // Agua 1
    'https://picsum.photos/id/242/800/600', // Agua 2
    'https://picsum.photos/id/243/800/600', // Alumbrado 1
    'https://picsum.photos/id/244/800/600', // Alumbrado 2
    'https://picsum.photos/id/248/800/600', // Vehículo 1
    'https://picsum.photos/id/249/800/600', // Vehículo 2
    'https://picsum.photos/id/250/800/600', // Ruido 1
    'https://picsum.photos/id/251/800/600', // Animal 1
    'https://picsum.photos/id/252/800/600', // Inseguridad 1
    'https://picsum.photos/id/253/800/600', // Señal Alto 1
    'https://picsum.photos/id/254/800/600', // Semáforo 1
  ];

  /// Lista de URLs de videos de demostración
  static final List<String> demoVideoUrls = [
    // Videos de muestra de Google
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
  ];

  /// Obtiene un ciudadano de demostración por su ID
  static Citizen getDemoCitizen(String id) {
    final citizens = {
      'CIT-001': Citizen(
        id: 'CIT-001',
        name: 'Juan Pérez',
        email: 'juan.perez@example.com',
        phone: '6461234567',
        registeredAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      'CIT-002': Citizen(
        id: 'CIT-002',
        name: 'María González',
        email: 'maria.gonzalez@example.com',
        phone: '6469876543',
        registeredAt: DateTime.now().subtract(const Duration(days: 160)),
      ),
      'CIT-003': Citizen(
        id: 'CIT-003',
        name: 'Carlos Rodríguez',
        email: 'carlos.rodriguez@example.com',
        phone: '6465551234',
        registeredAt: DateTime.now().subtract(const Duration(days: 140)),
      ),
      'CIT-004': Citizen(
        id: 'CIT-004',
        name: 'Ana Martínez',
        email: 'ana.martinez@example.com',
        phone: '6465554321',
        registeredAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      'CIT-005': Citizen(
        id: 'CIT-005',
        name: 'Roberto Sánchez',
        email: 'roberto.sanchez@example.com',
        phone: '6467778888',
        registeredAt: DateTime.now().subtract(const Duration(days: 100)),
      ),
      'CIT-006': Citizen(
        id: 'CIT-006',
        name: 'Laura Torres',
        email: 'laura.torres@example.com',
        phone: '6468889999',
        registeredAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      'CIT-007': Citizen(
        id: 'CIT-007',
        name: 'Miguel Flores',
        email: 'miguel.flores@example.com',
        phone: '6461112222',
        registeredAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      'CIT-008': Citizen(
        id: 'CIT-008',
        name: 'Patricia Ramírez',
        email: 'patricia.ramirez@example.com',
        phone: '6462223333',
        registeredAt: DateTime.now().subtract(const Duration(days: 70)),
      ),
      'CIT-009': Citizen(
        id: 'CIT-009',
        name: 'José López',
        email: 'jose.lopez@example.com',
        phone: '6463334444',
        registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      'CIT-010': Citizen(
        id: 'CIT-010',
        name: 'Carmen Díaz',
        email: 'carmen.diaz@example.com',
        phone: '6464445555',
        registeredAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
    };
    return citizens[id]!;
  }

  /// Obtiene un técnico de demostración por su ID
  static Technician getDemoTechnician(String id) {
    final technicians = {
      'TEC-001': Technician(
        id: 'TEC-001',
        name: 'Fernando Gómez',
        email: 'fernando.gomez@example.com',
        phone: '6461234567',
        specialties: [
          'Bacheo',
          'Recolección',
        ],
        isActive: true,
        currentWorkload: 3,
        averageResolutionTime: 2.5,
        rating: 4.8,
        lastKnownLatitude: 31.871170,
        lastKnownLongitude: -116.607612,
      ),
      'TEC-002': Technician(
        id: 'TEC-002',
        name: 'Luisa Hernández',
        email: 'luisa.hernandez@example.com',
        phone: '6469876543',
        specialties: [
          'Electricista',
          'Plomería',
        ],
        isActive: true,
        currentWorkload: 2,
        averageResolutionTime: 1.8,
        rating: 4.9,
        lastKnownLatitude: 31.872170,
        lastKnownLongitude: -116.608612,
      ),
      'TEC-003': Technician(
        id: 'TEC-003',
        name: 'Ricardo Mendoza',
        email: 'ricardo.mendoza@example.com',
        phone: '6465551234',
        specialties: [
          'Señalización',
          'Tránsito',
          'Infraestructura',
        ],
        isActive: true,
        currentWorkload: 4,
        averageResolutionTime: 3.2,
        rating: 4.6,
        lastKnownLatitude: 31.873170,
        lastKnownLongitude: -116.609612,
      ),
      'TEC-004': Technician(
        id: 'TEC-004',
        name: 'Gabriela Vargas',
        email: 'gabriela.vargas@example.com',
        phone: '6465554321',
        specialties: [
          'Tránsito',
          'Inspección',
          'Seguridad',
        ],
        isActive: true,
        currentWorkload: 2,
        averageResolutionTime: 2.1,
        rating: 4.7,
        lastKnownLatitude: 31.874170,
        lastKnownLongitude: -116.610612,
      ),
    };
    return technicians[id]!;
  }

  /// Genera una lista de reportes de demostración centrados en Ensenada, Baja California
  static List<Report> getDemoReports() {
    final List<Report> reports = [];
    
    // Coordenadas centrales de Ensenada, Baja California
    final double centerLat = 31.871170072167523;
    final double centerLng = -116.6076128288358;
    
    // Función para generar coordenadas aleatorias cercanas al punto central
    double randomOffset(double center, double range) {
      return center + (2 * range * (0.5 - Random().nextDouble()));
    }
    
    // Reporte 1: Bache en la calle
    reports.add(Report(
      id: 'REP-001',
      title: 'Bache peligroso en Blvd. Costero',
      category: ReportCategory.roadRepair,
      description: 'Bache profundo que causa daños a los vehículos en el Blvd. Costero',
      latitude: randomOffset(centerLat, 0.01),
      longitude: randomOffset(centerLng, 0.01),
      address: 'Blvd. Costero 123, Zona Centro, Ensenada',
      evidenceUrls: [demoImageUrls[0], demoImageUrls[1], demoVideoUrls[0]], // Bache 1
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      citizen: getDemoCitizen('CIT-001'),
      status: ReportStatus.pending,
      priority: 4, // Alta prioridad
    ));
    
    // Reporte 2: Bache en la calle (segundo ejemplo)
    reports.add(Report(
      id: 'REP-002',
      title: 'Bache en calle Juárez',
      category: ReportCategory.roadRepair,
      description: 'Bache en calle Juárez que afecta el tráfico local',
      latitude: randomOffset(centerLat, 0.008),
      longitude: randomOffset(centerLng, 0.008),
      address: 'Calle Juárez 456, Zona Centro, Ensenada',
      evidenceUrls: [demoImageUrls[2], demoImageUrls[3], demoVideoUrls[1]], // Bache 2
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      citizen: getDemoCitizen('CIT-002'),
      status: ReportStatus.assigned,
      assignedTechnician: getDemoTechnician('TEC-001'),
      assignedAt: DateTime.now().subtract(const Duration(days: 1)),
      priority: 3, // Prioridad media-alta
    ));
    
    // Reporte 3: Basura acumulada
    reports.add(Report(
      id: 'REP-003',
      title: 'Acumulación de basura en parque Revolución',
      category: ReportCategory.garbageCollection,
      description: 'Acumulación de basura en la esquina del parque Revolución',
      latitude: randomOffset(centerLat, 0.009),
      longitude: randomOffset(centerLng, 0.009),
      address: 'Parque Revolución s/n, Zona Centro, Ensenada',
      evidenceUrls: [demoImageUrls[4], demoImageUrls[5], demoVideoUrls[2]], // Basura 1
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      citizen: getDemoCitizen('CIT-003'),
      status: ReportStatus.assigned,
      assignedTechnician: getDemoTechnician('TEC-001'),
      assignedAt: DateTime.now().subtract(const Duration(days: 2)),
      priority: 2, // Prioridad media
    ));
    
    // Reporte 4: Basura acumulada (segundo ejemplo)
    reports.add(Report(
      id: 'REP-004',
      title: 'Basura en contenedor roto',
      category: ReportCategory.garbageCollection,
      description: 'Contenedor de basura roto con basura esparcida',
      latitude: randomOffset(centerLat, 0.012),
      longitude: randomOffset(centerLng, 0.012),
      address: 'Av. Ruiz 89, Col. Moderna, Ensenada',
      evidenceUrls: [demoImageUrls[6], demoImageUrls[7], demoVideoUrls[3]], // Basura 2
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      citizen: getDemoCitizen('CIT-004'),
      status: ReportStatus.pending,
      priority: 3, // Prioridad media-alta
    ));
    
    // Reporte 5: Fuga de agua
    reports.add(Report(
      id: 'REP-005',
      title: 'Fuga de agua en la calle',
      category: ReportCategory.streetImprovement,
      description: 'Fuga de agua importante que está desperdiciando mucha agua',
      latitude: randomOffset(centerLat, 0.007),
      longitude: randomOffset(centerLng, 0.007),
      address: 'Av. Reforma 234, Col. Centro, Ensenada',
      evidenceUrls: [demoImageUrls[8], demoImageUrls[9], demoVideoUrls[4]], // Agua 1
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      citizen: getDemoCitizen('CIT-005'),
      status: ReportStatus.inProgress,
      assignedTechnician: getDemoTechnician('TEC-002'),
      assignedAt: DateTime.now().subtract(const Duration(days: 3)),
      priority: 5, // Prioridad alta
    ));
    
    // Reporte 6: Fuga de agua (segundo ejemplo)
    reports.add(Report(
      id: 'REP-006',
      title: 'Tubería rota en la acera',
      category: ReportCategory.streetImprovement,
      description: 'Tubería rota que está causando daños en la acera y la calle',
      latitude: randomOffset(centerLat, 0.006),
      longitude: randomOffset(centerLng, 0.006),
      address: 'Calle Obregón 567, Col. Moderna, Ensenada',
      evidenceUrls: [demoImageUrls[10], demoImageUrls[11], demoVideoUrls[5]], // Agua 2
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      citizen: getDemoCitizen('CIT-006'),
      status: ReportStatus.resolved,
      assignedTechnician: getDemoTechnician('TEC-002'),
      assignedAt: DateTime.now().subtract(const Duration(days: 6)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 5)),
      resolutionNotes: 'Se reparó la tubería y se restauró la acera.',
      priority: 4, // Prioridad alta
    ));
    
    // Reporte 7: Alumbrado público
    reports.add(Report(
      id: 'REP-007',
      title: 'Lámpara de alumbrado público no funciona',
      category: ReportCategory.streetImprovement,
      description: 'Lámpara de alumbrado público apagada desde hace una semana',
      latitude: randomOffset(centerLat, 0.008),
      longitude: randomOffset(centerLng, 0.008),
      address: 'Calle Miramar 123, Col. Playa Hermosa, Ensenada',
      evidenceUrls: [demoImageUrls[6], demoVideoUrls[6]], // Alumbrado 1
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      citizen: getDemoCitizen('CIT-007'),
      status: ReportStatus.resolved,
      assignedTechnician: getDemoTechnician('TEC-002'),
      assignedAt: DateTime.now().subtract(const Duration(days: 7)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 6)),
      resolutionNotes: 'Se reemplazó la lámpara y se verificó el funcionamiento.',
      priority: 2, // Prioridad media
    ));
    
    // Reporte 8: Alumbrado público (segundo ejemplo)
    reports.add(Report(
      id: 'REP-008',
      title: 'Poste de luz dañado',
      category: ReportCategory.streetImprovement,
      description: 'Poste de luz inclinado que podría caerse',
      latitude: randomOffset(centerLat, 0.009),
      longitude: randomOffset(centerLng, 0.009),
      address: 'Av. Del Mar 456, Col. Playa Hermosa, Ensenada',
      evidenceUrls: [demoImageUrls[7], demoVideoUrls[7]], // Alumbrado 2
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      citizen: getDemoCitizen('CIT-008'),
      status: ReportStatus.inProgress,
      assignedTechnician: getDemoTechnician('TEC-002'),
      assignedAt: DateTime.now().subtract(const Duration(days: 9)),
      priority: 5, // Prioridad muy alta
    ));
    
    // Reporte 9: Vehículo abandonado
    reports.add(Report(
      id: 'REP-009',
      title: 'Vehículo abandonado en zona residencial',
      category: ReportCategory.roadRepair,
      description: 'Vehículo abandonado desde hace semanas, está causando problemas de estacionamiento',
      latitude: randomOffset(centerLat, 0.01),
      longitude: randomOffset(centerLng, 0.01),
      address: 'Callejón del Puerto 15, Col. Playa de Ensenada',
      evidenceUrls: [demoImageUrls[8], demoVideoUrls[7]], // Vehículo 1
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      citizen: getDemoCitizen('CIT-009'),
      status: ReportStatus.rejected,
      assignedTechnician: getDemoTechnician('TEC-004'),
      assignedAt: DateTime.now().subtract(const Duration(days: 14)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      resolutionNotes: 'El vehículo cuenta con permisos especiales de estacionamiento en la zona.',
      priority: 1, // Prioridad baja
    ));
    
    // Reporte 10: Vehículo abandonado (segundo ejemplo)
    reports.add(Report(
      id: 'REP-010',
      title: 'Vehículo abandonado con vidrios rotos',
      category: ReportCategory.roadRepair,
      description: 'Vehículo abandonado con vidrios rotos y sin placas',
      latitude: randomOffset(centerLat, 0.011),
      longitude: randomOffset(centerLng, 0.011),
      address: 'Calle Bahía de los Ángeles 78, Col. Playa Hermosa, Ensenada',
      evidenceUrls: [demoImageUrls[9], demoVideoUrls[8]], // Vehículo 2
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      citizen: getDemoCitizen('CIT-010'),
      status: ReportStatus.inProgress,
      assignedTechnician: getDemoTechnician('TEC-004'),
      assignedAt: DateTime.now().subtract(const Duration(days: 11)),
      priority: 3, // Prioridad media-alta
    ));
    
    // Reporte 11: Ruido excesivo
    reports.add(Report(
      id: 'REP-011',
      title: 'Ruido excesivo de bar nocturno',
      category: ReportCategory.streetImprovement,
      description: 'Bar con música a alto volumen hasta altas horas de la madrugada',
      latitude: randomOffset(centerLat, 0.005),
      longitude: randomOffset(centerLng, 0.005),
      address: 'Av. López Mateos 123, Zona Turística, Ensenada',
      evidenceUrls: [demoImageUrls[10], demoVideoUrls[9]], // Ruido 1
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      citizen: getDemoCitizen('CIT-001'),
      status: ReportStatus.pending,
      priority: 2, // Prioridad media-baja
    ));
    
    // Reporte 12: Maltrato animal
    reports.add(Report(
      id: 'REP-012',
      title: 'Perro abandonado en condiciones precarias',
      category: ReportCategory.streetImprovement,
      description: 'Perro encadenado sin agua ni comida en un terreno baldío',
      latitude: randomOffset(centerLat, 0.013),
      longitude: randomOffset(centerLng, 0.013),
      address: 'Calle Diamante 456, Col. Valle Dorado, Ensenada',
      evidenceUrls: [demoImageUrls[11], demoVideoUrls[0]], // Animal 1
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      citizen: getDemoCitizen('CIT-002'),
      status: ReportStatus.assigned,
      assignedTechnician: getDemoTechnician('TEC-004'),
      assignedAt: DateTime.now().subtract(const Duration(days: 8)),
      priority: 4, // Prioridad alta
    ));
    
    // Reporte 13: Inseguridad
    reports.add(Report(
      id: 'REP-013',
      title: 'Zona oscura propensa a asaltos',
      category: ReportCategory.streetImprovement,
      description: 'Callejón sin iluminación donde han ocurrido varios asaltos',
      latitude: randomOffset(centerLat, 0.007),
      longitude: randomOffset(centerLng, 0.007),
      address: 'Callejón Escondido s/n, Col. Centro, Ensenada',
      evidenceUrls: [demoImageUrls[12], demoVideoUrls[1]], // Inseguridad 1
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
      citizen: getDemoCitizen('CIT-003'),
      status: ReportStatus.inProgress,
      assignedTechnician: getDemoTechnician('TEC-004'),
      assignedAt: DateTime.now().subtract(const Duration(days: 10)),
      priority: 5, // Prioridad muy alta
    ));
    
    // Reporte 14: Señal de alto dañada
    reports.add(Report(
      id: 'REP-014',
      title: 'Señal de alto derribada',
      category: ReportCategory.streetImprovement,
      description: 'Señal de alto derribada en intersección peligrosa',
      latitude: randomOffset(centerLat, 0.006),
      longitude: randomOffset(centerLng, 0.006),
      address: 'Esquina Av. Reforma y Calle Juárez, Col. Centro, Ensenada',
      evidenceUrls: [demoImageUrls[13], demoVideoUrls[2]], // Señal Alto 1
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      citizen: getDemoCitizen('CIT-004'),
      status: ReportStatus.assigned,
      assignedTechnician: getDemoTechnician('TEC-003'),
      assignedAt: DateTime.now().subtract(const Duration(days: 2)),
      priority: 4, // Prioridad alta
    ));
    
    // Reporte 15: Semáforo dañado
    reports.add(Report(
      id: 'REP-015',
      title: 'Semáforo intermitente',
      category: ReportCategory.streetImprovement,
      description: 'Semáforo con luz intermitente en todas las direcciones',
      latitude: randomOffset(centerLat, 0.008),
      longitude: randomOffset(centerLng, 0.008),
      address: 'Cruce Blvd. Costero y Av. Ruiz, Zona Centro, Ensenada',
      evidenceUrls: [demoImageUrls[14], demoVideoUrls[3]], // Semáforo 1
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      citizen: getDemoCitizen('CIT-005'),
      status: ReportStatus.pending,
      priority: 5, // Prioridad muy alta
    ));
    
    return reports;
  }
}
