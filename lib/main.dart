import 'package:animations/animations.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ojo_ciudadano_admin/core/errors/failures.dart';
import 'package:ojo_ciudadano_admin/core/navigation/app_router.dart';
import 'package:ojo_ciudadano_admin/core/theme/app_theme.dart';
import 'package:ojo_ciudadano_admin/domain/entities/administrator.dart';
import 'package:ojo_ciudadano_admin/domain/entities/citizen.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/auth/auth_state.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/theme/theme_state.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/administrator_repository.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/delegation_repository.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/report_repository.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/technician_repository.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/theme_repository.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/login_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/get_reports_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/get_delegations_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/assign_report_to_technician_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/update_report_priority_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/suggest_technicians_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/services/report_priority_service.dart';
import 'package:ojo_ciudadano_admin/domain/services/technician_assignment_service.dart';
import 'package:ojo_ciudadano_admin/data/repositories/mock_delegation_repository.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/technicians/technicians_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/dashboard_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/login_page.dart';
import 'package:ojo_ciudadano_admin/presentation/pages/splash_page.dart';

class MockAdministratorRepository implements AdministratorRepository {
  @override
  Future<Either<Failure, Administrator>> login(String email, String password) {
    // Simulación de login exitoso
    if (email == 'admin@example.com' && password == 'password') {
      return Future.value(
        Right(
          Administrator(
            id: '1',
            name: 'Admin User',
            email: 'admin@example.com',
            role: AdministratorRole.admin,
            isDarkThemeEnabled: false,
            lastLogin: DateTime.now(),
          ),
        ),
      );
    }
    // Simulación de error de credenciales
    return Future.value(
      Left(AuthenticationFailure(message: 'Credenciales inválidas')),
    );
  }

  @override
  Future<Either<Failure, bool>> logout() {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, Administrator>> getCurrentAdministrator() {
    return Future.value(
      Right(
        Administrator(
          id: '1',
          name: 'Admin User',
          email: 'admin@example.com',
          role: AdministratorRole.admin,
          isDarkThemeEnabled: false,
          lastLogin: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Administrator>>> getAllAdministrators() {
    return Future.value(
      Right([
        Administrator(
          id: '1',
          name: 'Admin User',
          email: 'admin@example.com',
          role: AdministratorRole.admin,
          isDarkThemeEnabled: false,
          lastLogin: DateTime.now(),
        ),
        Administrator(
          id: '2',
          name: 'Operator User',
          email: 'operator@example.com',
          role: AdministratorRole.supervisor,
          isDarkThemeEnabled: false,
          lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]),
    );
  }

  @override
  Future<Either<Failure, Administrator>> createAdministrator(
    Administrator administrator,
    String password,
  ) {
    return Future.value(Right(administrator));
  }

  @override
  Future<Either<Failure, Administrator>> updateProfile(
    Administrator administrator,
  ) {
    return Future.value(Right(administrator));
  }

  @override
  Future<Either<Failure, bool>> changePassword(
    String currentPassword,
    String newPassword,
  ) {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, bool>> deleteAdministrator(String id) {
    return Future.value(const Right(true));
  }

  @override
  Future<Either<Failure, bool>> updateThemePreference(bool isDarkTheme) {
    return Future.value(const Right(true));
  }
}

// Implementación temporal del repositorio de reportes
class MockReportRepository implements ReportRepository {
  // Lista de reportes de ejemplo
  final List<Report> _reports = [
    Report(
      id: '1',
      title: 'Bache grande en calle principal',
      category: ReportCategory.roadRepair,
      description: 'Bache grande en la calle principal',
      latitude: 19.432608,
      longitude: -99.133209,
      address: 'Av. Insurgentes Sur 1602, CDMX',
      evidenceUrls: ['https://example.com/evidence1.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      citizen: Citizen(
        id: 'c1',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      status: ReportStatus.pending,
      assignedAt: null,
      resolvedAt: null,
      resolutionNotes: null,
    ),
    Report(
      id: '2',
      title: 'Luminaria dañada en parque',
      category: ReportCategory.streetImprovement,
      description: 'Luminaria dañada en el parque',
      latitude: 19.435608,
      longitude: -99.143209,
      address: 'Parque Chapultepec, CDMX',
      evidenceUrls: ['https://example.com/evidence2.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      citizen: Citizen(
        id: 'c2',
        name: 'María López',
        email: 'maria@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      status: ReportStatus.assigned,
      assignedAt: DateTime.now().subtract(const Duration(days: 8)),
      resolvedAt: null,
      resolutionNotes: null,
      assignedTechnician: Technician(
        id: 't1',
        name: 'Carlos Rodríguez',
        email: 'carlos@example.com',
        phone: '5551234567',
        specialties: [
          'Electricista',
          'Semáforos',
        ],
        isActive: true,
        currentWorkload: 3,
        averageResolutionTime: 2.5,
        rating: 4.8,
        lastKnownLatitude: 19.432608,
        lastKnownLongitude: -99.143209,
      ),
    ),
    Report(
      id: '3',
      title: 'Grafiti en muro escolar',
      category: ReportCategory.garbageCollection,
      description: 'Grafiti en muro escolar',
      latitude: 19.422608,
      longitude: -99.153209,
      address: 'Escuela Primaria Benito Juárez, CDMX',
      evidenceUrls: ['https://example.com/evidence4.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      citizen: Citizen(
        id: 'c3',
        name: 'Pedro Gómez',
        email: 'pedro@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      status: ReportStatus.inProgress,
      assignedAt: DateTime.now().subtract(const Duration(days: 14)),
      resolvedAt: null,
      resolutionNotes: null,
      assignedTechnician: Technician(
        id: 't3',
        name: 'Roberto Sánchez',
        email: 'roberto@example.com',
        phone: '5552468135',
        profileImageUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
        specialties: [
          'Bacheo',
          'Plomería',
        ],
        isActive: true,
        currentWorkload: 2,
        averageResolutionTime: 4.0,
        rating: 4.5,
        lastKnownLatitude: 19.422608,
        lastKnownLongitude: -99.123209,
      ),
    ),
    Report(
      id: '4',
      title: 'Semáforo intermitente en cruce',
      category: ReportCategory.roadRepair,
      description: 'Semáforo intermitente',
      latitude: 19.442608,
      longitude: -99.163209,
      address: 'Cruce Av. Reforma y Insurgentes, CDMX',
      evidenceUrls: ['https://example.com/evidence5.jpg'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      citizen: Citizen(
        id: 'c4',
        name: 'Laura Martínez',
        email: 'laura@example.com',
        registeredAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      status: ReportStatus.pending,
      assignedAt: null,
      resolvedAt: null,
      resolutionNotes: null,
    ),
  ];

  @override
  Future<Either<Failure, List<Report>>> getReports({
    ReportStatus? status,
    ReportCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? delegationId,
    int? minPriority,
  }) {
    try {
      List<Report> filteredReports = List.from(_reports);

      if (status != null) {
        filteredReports = filteredReports
            .where((r) => r.status == status)
            .toList();
      }

      if (category != null) {
        filteredReports = filteredReports
            .where((r) => r.category == category)
            .toList();
      }

      if (startDate != null) {
        filteredReports = filteredReports
            .where((r) => r.createdAt.isAfter(startDate))
            .toList();
      }

      if (endDate != null) {
        filteredReports = filteredReports
            .where((r) => r.createdAt.isBefore(endDate))
            .toList();
      }
      
      if (delegationId != null) {
        filteredReports = filteredReports
            .where((r) => r.delegation?.id == delegationId)
            .toList();
      }
      
      if (minPriority != null) {
        filteredReports = filteredReports
            .where((r) => (r.priority ?? 0) >= minPriority)
            .toList();
      }

      return Future.value(Right(filteredReports));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Report>> getReportById(String id) {
    try {
      final report = _reports.firstWhere((r) => r.id == id);
      return Future.value(Right(report));
    } catch (e) {
      return Future.value(
        const Left(NotFoundFailure(message: 'Reporte no encontrado')),
      );
    }
  }

  @override
  Future<Either<Failure, Report>> addResolutionNotes(
    String reportId,
    String notes,
  ) {
    try {
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Reporte no encontrado')),
        );
      }

      final updatedReport = Report(
        id: _reports[reportIndex].id,
        title: _reports[reportIndex].title,
        category: _reports[reportIndex].category,
        description: _reports[reportIndex].description,
        latitude: _reports[reportIndex].latitude,
        longitude: _reports[reportIndex].longitude,
        address: _reports[reportIndex].address,
        evidenceUrls: _reports[reportIndex].evidenceUrls,
        createdAt: _reports[reportIndex].createdAt,
        citizen: _reports[reportIndex].citizen,
        status: _reports[reportIndex].status,
        assignedTechnician: _reports[reportIndex].assignedTechnician,
        assignedAt: _reports[reportIndex].assignedAt,
        resolvedAt: _reports[reportIndex].resolvedAt,
        resolutionNotes: notes,
      );

      _reports[reportIndex] = updatedReport;
      return Future.value(Right(updatedReport));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Report>> assignReportToTechnician(
    String reportId,
    String technicianId,
  ) {
    try {
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Reporte no encontrado')),
        );
      }

      // Simulamos la búsqueda del técnico
      final technician = Technician(
        id: technicianId,
        name: 'Técnico Asignado',
        email: 'tecnico@example.com',
        phone: '5551234567',
        specialties: [
          'Electricista',
          'Semáforos',
        ],
        isActive: true,
        currentWorkload: 2,
        averageResolutionTime: 3.0,
        rating: 4.5,
        lastKnownLatitude: 19.432608,
        lastKnownLongitude: -99.133209,
      );

      final updatedReport = Report(
        id: _reports[reportIndex].id,
        title: _reports[reportIndex].title,
        category: _reports[reportIndex].category,
        description: _reports[reportIndex].description,
        latitude: _reports[reportIndex].latitude,
        longitude: _reports[reportIndex].longitude,
        address: _reports[reportIndex].address,
        evidenceUrls: _reports[reportIndex].evidenceUrls,
        createdAt: _reports[reportIndex].createdAt,
        citizen: _reports[reportIndex].citizen,
        status: ReportStatus.assigned,
        assignedTechnician: technician,
        assignedAt: DateTime.now(),
        resolvedAt: _reports[reportIndex].resolvedAt,
        resolutionNotes: _reports[reportIndex].resolutionNotes,
      );

      _reports[reportIndex] = updatedReport;
      return Future.value(Right(updatedReport));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Report>> updateReportStatus(
    String reportId,
    ReportStatus status,
  ) {
    try {
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Reporte no encontrado')),
        );
      }

      DateTime? resolvedAt = _reports[reportIndex].resolvedAt;
      if (status == ReportStatus.resolved) {
        resolvedAt = DateTime.now();
      }

      final updatedReport = Report(
        id: _reports[reportIndex].id,
        title: _reports[reportIndex].title,
        category: _reports[reportIndex].category,
        description: _reports[reportIndex].description,
        latitude: _reports[reportIndex].latitude,
        longitude: _reports[reportIndex].longitude,
        address: _reports[reportIndex].address,
        evidenceUrls: _reports[reportIndex].evidenceUrls,
        createdAt: _reports[reportIndex].createdAt,
        citizen: _reports[reportIndex].citizen,
        status: status,
        assignedTechnician: _reports[reportIndex].assignedTechnician,
        assignedAt: _reports[reportIndex].assignedAt,
        resolvedAt: resolvedAt,
        resolutionNotes: _reports[reportIndex].resolutionNotes,
      );

      _reports[reportIndex] = updatedReport;
      return Future.value(Right(updatedReport));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<ReportCategory, int>>> getReportCountByCategory({String? delegationId}) {
    try {
      final Map<ReportCategory, int> countByCategory = {};
      
      // Filtrar por delegación si se especifica
      final reportsToCount = delegationId != null
          ? _reports.where((r) => r.delegation?.id == delegationId).toList()
          : _reports;

      for (final report in reportsToCount) {
        countByCategory[report.category] =
            (countByCategory[report.category] ?? 0) + 1;
      }

      return Future.value(Right(countByCategory));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<ReportStatus, int>>> getReportCountByStatus({String? delegationId}) {
    try {
      final Map<ReportStatus, int> countByStatus = {};
      
      // Filtrar por delegación si se especifica
      final reportsToCount = delegationId != null
          ? _reports.where((r) => r.delegation?.id == delegationId).toList()
          : _reports;

      for (final report in reportsToCount) {
        countByStatus[report.status] = (countByStatus[report.status] ?? 0) + 1;
      }

      return Future.value(Right(countByStatus));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageResolutionTime({String? delegationId}) {
    try {
      // Filtrar por delegación si se especifica
      var filteredReports = delegationId != null
          ? _reports.where((r) => r.delegation?.id == delegationId).toList()
          : _reports;
          
      final resolvedReports = filteredReports
          .where(
            (r) =>
                r.status == ReportStatus.resolved &&
                r.assignedAt != null &&
                r.resolvedAt != null,
          )
          .toList();

      if (resolvedReports.isEmpty) {
        return Future.value(const Right(0.0));
      }

      double totalHours = 0;
      for (final report in resolvedReports) {
        final duration = report.resolvedAt!.difference(report.assignedAt!);
        totalHours += duration.inHours;
      }

      return Future.value(Right(totalHours / resolvedReports.length));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
  
  @override
  Future<Either<Failure, Report>> updateReportPriority(String reportId, int priority) {
    try {
      final reportIndex = _reports.indexWhere((r) => r.id == reportId);
      if (reportIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Reporte no encontrado')),
        );
      }
      
      // Validar que la prioridad esté entre 1 y 5
      if (priority < 1 || priority > 5) {
        return Future.value(
          Left(ValidationFailure(message: 'La prioridad debe estar entre 1 y 5')),
        );
      }

      final updatedReport = _reports[reportIndex].copyWith(priority: priority);
      _reports[reportIndex] = updatedReport;
      return Future.value(Right(updatedReport));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
  
  @override
  Future<Either<Failure, Map<String, double>>> getPerformanceMetrics({String? delegationId}) {
    try {
      // Filtrar por delegación si se especifica
      var filteredReports = delegationId != null
          ? _reports.where((r) => r.delegation?.id == delegationId).toList()
          : _reports;
      
      // Calcular métricas de rendimiento
      final totalReports = filteredReports.length;
      final resolvedReports = filteredReports.where((r) => r.status == ReportStatus.resolved).length;
      final pendingReports = filteredReports.where((r) => r.status == ReportStatus.pending).length;
      
      // Calcular tiempo promedio de respuesta inicial (desde creación hasta asignación)
      double avgResponseTime = 0;
      final assignedReports = filteredReports.where((r) => r.assignedAt != null).toList();
      if (assignedReports.isNotEmpty) {
        double totalResponseHours = 0;
        for (final report in assignedReports) {
          final duration = report.assignedAt!.difference(report.createdAt);
          totalResponseHours += duration.inHours;
        }
        avgResponseTime = totalResponseHours / assignedReports.length;
      }
      
      // Calcular tasa de resolución
      final resolutionRate = totalReports > 0 ? resolvedReports / totalReports : 0;
      
      // Calcular tiempo promedio de resolución
      double avgResolutionTime = 0;
      final completedReports = filteredReports.where(
        (r) => r.status == ReportStatus.resolved && r.assignedAt != null && r.resolvedAt != null
      ).toList();
      
      if (completedReports.isNotEmpty) {
        double totalResolutionHours = 0;
        for (final report in completedReports) {
          final duration = report.resolvedAt!.difference(report.assignedAt!);
          totalResolutionHours += duration.inHours;
        }
        avgResolutionTime = totalResolutionHours / completedReports.length;
      }
      
      return Future.value(Right({
        'averageResponseTime': avgResponseTime,
        'averageResolutionTime': avgResolutionTime,
        'resolutionRate': resolutionRate.toDouble(),
        'pendingRate': totalReports > 0 ? (pendingReports / totalReports).toDouble() : 0.0,
        'rating': 4.2, // Valor simulado
      }));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
}

// Implementación temporal del repositorio de técnicos
class MockTechnicianRepository implements TechnicianRepository {
  final List<Technician> _technicians = [
    Technician(
      id: 't1',
      name: 'Carlos Rodríguez',
      email: 'carlos@example.com',
      phone: '5551234567',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      specialties: [
        'Bacheo',
        'Electricista',
      ],
      isActive: true,
      currentWorkload: 3,
      averageResolutionTime: 24.5,
      rating: 4.8,
      lastKnownLatitude: 19.432608,
      lastKnownLongitude: -99.133209,
    ),
    Technician(
      id: 't2',
      name: 'Ana Martínez',
      email: 'ana@example.com',
      phone: '5559876543',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
      specialties: [
        'Plomería',
        'Recolección',
      ],
      isActive: true,
      currentWorkload: 2,
      averageResolutionTime: 18.2,
      rating: 4.5,
      lastKnownLatitude: 19.442608,
      lastKnownLongitude: -99.143209,
    ),
    Technician(
      id: 't3',
      name: 'Roberto Gómez',
      email: 'roberto@example.com',
      phone: '5552345678',
      profileImageUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
      specialties: [
        'Señalización',
        'Tránsito',
        'Infraestructura',
      ],
      isActive: true,
      currentWorkload: 1,
      averageResolutionTime: 12.8,
      rating: 4.2,
      lastKnownLatitude: 19.422608,
      lastKnownLongitude: -99.123209,
    ),
    Technician(
      id: 't4',
      name: 'Laura Sánchez',
      email: 'laura@example.com',
      phone: '5553456789',
      profileImageUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
      specialties: [
        'Trabajo Social',
        'Atención Ciudadana',
      ],
      isActive: false, // De vacaciones
      currentWorkload: 0,
      averageResolutionTime: 36.5,
      rating: 4.9,
      isAvailable: false,
    ),
  ];

  @override
  Future<Either<Failure, List<Technician>>> getTechnicians({
    String? specialty,
    bool? isActive,
  }) {
    try {
      List<Technician> filteredTechnicians = List.from(_technicians);

      if (specialty != null) {
        filteredTechnicians = filteredTechnicians
            .where((t) => t.specialties.contains(specialty))
            .toList();
      }

      if (isActive != null) {
        filteredTechnicians = filteredTechnicians
            .where((t) => t.isActive == isActive)
            .toList();
      }

      return Future.value(Right(filteredTechnicians));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Technician>> getTechnicianById(String id) {
    try {
      final technician = _technicians.firstWhere((tech) => tech.id == id);
      return Future.value(Right(technician));
    } catch (e) {
      return Future.value(
        const Left(NotFoundFailure(message: 'Técnico no encontrado')),
      );
    }
  }

  @override
  Future<Either<Failure, Technician>> createTechnician(Technician technician) {
    try {
      _technicians.add(technician);
      return Future.value(Right(technician));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Technician>> updateTechnician(Technician technician) {
    try {
      final index = _technicians.indexWhere((tech) => tech.id == technician.id);
      if (index != -1) {
        _technicians[index] = technician;
        return Future.value(Right(technician));
      } else {
        return Future.value(
          const Left(NotFoundFailure(message: 'Técnico no encontrado')),
        );
      }
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTechnician(String id) {
    try {
      final initialLength = _technicians.length;
      _technicians.removeWhere((tech) => tech.id == id);
      final removed = initialLength > _technicians.length;

      if (removed) {
        return Future.value(const Right(true));
      } else {
        return Future.value(
          const Left(NotFoundFailure(message: 'Técnico no encontrado')),
        );
      }
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getTechnicianReports(
    String technicianId, {
    ReportStatus? status,
  }) {
    // Simulación de reportes asignados a un técnico
    try {
      // Verificar si el técnico existe
      final technicianIndex = _technicians.indexWhere(
        (tech) => tech.id == technicianId,
      );
      if (technicianIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Técnico no encontrado')),
        );
      }

      final technician = _technicians[technicianIndex];

      // Crear un ciudadano simulado para los reportes
      final mockCitizen = Citizen(
        id: 'c1',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        phone: '5551234567',
        registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Simulamos algunos reportes para este técnico
      final reports = [
        Report(
          id: 'r1',
          title: 'Fuga de agua en calle principal',
          description: 'Hay una fuga de agua importante en la esquina',
          address: 'Calle Principal y Av. Central',
          latitude: 19.4326,
          longitude: -99.1332,
          category: ReportCategory.garbageCollection,
          status: ReportStatus.inProgress,
          citizen: mockCitizen,
          evidenceUrls: ['https://example.com/image1.jpg'],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          assignedTechnician: technician,
          assignedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Report(
          id: 'r2',
          title: 'Alumbrado dañado',
          description: 'Poste de luz no funciona desde hace una semana',
          address: 'Av. Reforma 123',
          latitude: 19.4280,
          longitude: -99.1680,
          category: ReportCategory.streetImprovement,
          status: ReportStatus.assigned,
          citizen: mockCitizen,
          evidenceUrls: ['https://example.com/image2.jpg'],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          assignedTechnician: technician,
          assignedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];

      if (status != null) {
        final filteredReports = reports
            .where((r) => r.status == status)
            .toList();
        return Future.value(Right(filteredReports));
      }

      return Future.value(Right(reports));
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getTechnicianPerformanceMetrics(
    String technicianId,
  ) {
    try {
      // Verificar si el técnico existe
      final techIndex = _technicians.indexWhere(
        (tech) => tech.id == technicianId,
      );
      if (techIndex == -1) {
        return Future.value(
          const Left(NotFoundFailure(message: 'Técnico no encontrado')),
        );
      }

      // Devolver métricas simuladas
      final tech = _technicians[techIndex];
      return Future.value(
        Right({
          'averageResolutionTime': tech.averageResolutionTime,
          'rating': tech.rating,
          'completionRate': 0.85,
          'responseTime': 1.2,
        }),
      );
    } catch (e) {
      return Future.value(Left(ServerFailure(message: e.toString())));
    }
  }
}

// Implementación temporal del repositorio de temas
class MockThemeRepository implements ThemeRepository {
  bool _isDarkTheme = false;

  @override
  Future<Either<Failure, bool>> getThemePreference() {
    return Future.value(Right(_isDarkTheme));
  }

  @override
  Future<Either<Failure, bool>> updateThemePreference(bool isDarkTheme) {
    _isDarkTheme = isDarkTheme;
    return Future.value(Right(_isDarkTheme));
  }
}

// Configuración de inyección de dependencias
void setupDependencies() {
  final getIt = GetIt.instance;

  // Repositorios
  getIt.registerLazySingleton<AdministratorRepository>(
    () => MockAdministratorRepository(),
  );
  getIt.registerLazySingleton<ReportRepository>(() => MockReportRepository());
  getIt.registerLazySingleton<TechnicianRepository>(
    () => MockTechnicianRepository(),
  );
  getIt.registerLazySingleton<ThemeRepository>(() => MockThemeRepository());
  getIt.registerLazySingleton<DelegationRepository>(
    () => MockDelegationRepository(),
  );
  
  // Servicios
  getIt.registerLazySingleton(() => ReportPriorityService());
  getIt.registerLazySingleton(() => TechnicianAssignmentService());

  // Casos de uso
  getIt.registerLazySingleton(
    () => LoginUseCase(getIt<AdministratorRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => AssignReportToTechnicianUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetDelegationsUseCase(getIt<DelegationRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateReportPriorityUseCase(
      getIt<ReportRepository>(),
      getIt<ReportPriorityService>(),
    ),
  );
  getIt.registerLazySingleton(
    () => SuggestTechniciansUseCase(
      reportRepository: getIt<ReportRepository>(),
      technicianRepository: getIt<TechnicianRepository>(),
      assignmentService: getIt<TechnicianAssignmentService>(),
    ),
  );

  // Blocs
  getIt.registerFactory(() => AuthBloc(loginUseCase: getIt<LoginUseCase>()));
  getIt.registerFactory(
    () => ReportsBloc(
      getReportsUseCase: getIt<GetReportsUseCase>(),
      assignReportToTechnicianUseCase: getIt<AssignReportToTechnicianUseCase>(),
      updateReportPriorityUseCase: getIt<UpdateReportPriorityUseCase>(),
      priorityService: getIt<ReportPriorityService>(),
    ),
  );
  getIt.registerFactory(() => TechniciansBloc(getIt<TechnicianRepository>()));
  getIt.registerFactory(
    () => ThemeBloc(themeRepository: getIt<ThemeRepository>()),
  );
  getIt.registerFactory(
    () => DelegationsBloc(getDelegationsUseCase: getIt<GetDelegationsUseCase>()),
  );
}

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configurar la orientación preferida de la aplicación
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Configurar el estilo de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => GetIt.instance<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<ThemeBloc>(
          create: (_) => GetIt.instance<ThemeBloc>(),
        ),
        BlocProvider<ReportsBloc>(
          create: (_) => GetIt.instance<ReportsBloc>()..add(LoadReportsEvent()),
        ),
        BlocProvider<TechniciansBloc>(
          create: (_) => GetIt.instance<TechniciansBloc>(),
        ),
        BlocProvider<DelegationsBloc>(
          create: (_) => GetIt.instance<DelegationsBloc>()..add(const LoadDelegationsEvent(isActive: true)),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState is ThemeLoaded ? themeState.isDarkTheme : false;
          
          return MaterialApp(
            title: 'Ojo Ciudadano Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.splash,
            // Configurar transiciones de página predeterminadas
            builder: (context, child) {
              return _AnimationWrapper(child: child!);
            },
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthInitial) {
                  // Disparar evento para verificar si hay un usuario autenticado
                  context.read<AuthBloc>().add(CheckAuthStatusEvent());
                  return const SplashPage();
                } else if (authState is AuthAuthenticated) {
                  // Usuario autenticado, mostrar dashboard
                  return const DashboardPage();
                } else if (authState is AuthUnauthenticated) {
                  // Usuario no autenticado, mostrar login
                  return const LoginPage();
                } else {
                  // Estado de carga o error, mostrar splash
                  return const SplashPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/// Widget para envolver la aplicación con animaciones globales
class _AnimationWrapper extends StatelessWidget {
  final Widget child;
  
  const _AnimationWrapper({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
      child: child,
    );
  }
}
