import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/core/utils/demo_data.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/services/report_priority_service.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/assign_report_to_technician_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/get_reports_usecase.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/update_report_priority_usecase.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/reports/reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReportsUseCase getReportsUseCase;
  final AssignReportToTechnicianUseCase assignReportToTechnicianUseCase;
  final UpdateReportPriorityUseCase? updateReportPriorityUseCase;
  final ReportPriorityService priorityService;

  ReportsBloc({
    required this.getReportsUseCase,
    required this.assignReportToTechnicianUseCase,
    this.updateReportPriorityUseCase,
    ReportPriorityService? priorityService,
  }) : priorityService = priorityService ?? ReportPriorityService(),
       super(ReportsInitial()) {
    on<LoadReportsEvent>(_onLoadReports);
    on<LoadReportDetailsEvent>(_onLoadReportDetails);
    on<AssignReportEvent>(_onAssignReport);
    on<UpdateReportStatusEvent>(_onUpdateReportStatus);
    on<AddResolutionNotesEvent>(_onAddResolutionNotes);
    on<LoadReportStatisticsEvent>(_onLoadReportStatistics);
    on<UpdateReportPriorityEvent>(_onUpdateReportPriority);
    on<UpdateAllReportPrioritiesEvent>(_onUpdateAllReportPriorities);
    on<FilterReportsByPriorityEvent>(_onFilterReportsByPriority);
  }

  Future<void> _onLoadReports(
    LoadReportsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Usar datos de demostración en lugar de llamar al caso de uso
      final demoReports = DemoData.getDemoReports();
      
      // Aplicar filtros si es necesario
      final filteredReports = demoReports.where((report) {
        // Filtrar por estado si se especificó
        if (event.status != null && report.status != event.status) {
          return false;
        }
        
        // Filtrar por categoría si se especificó
        if (event.category != null && report.category != event.category) {
          return false;
        }
        
        // Filtrar por delegación si se especificó
        if (event.delegationId != null && report.delegation?.id != event.delegationId) {
          return false;
        }
        
        // Filtrar por prioridad mínima si se especificó
        if (event.minPriority != null && (report.priority ?? 0) < event.minPriority!) {
          return false;
        }
        
        return true;
      }).toList();
      
      emit(
        ReportsLoaded(
          reports: filteredReports,
          filterStatus: event.status,
          filterCategory: event.category,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
          filterDelegationId: event.delegationId,
          filterMinPriority: event.minPriority,
        ),
      );
    } catch (e) {
      emit(ReportsError(message: 'Error al cargar los reportes: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReportDetails(
    LoadReportDetailsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    // Guardamos el estado actual para preservar la lista de reportes
    final currentState = state;
    
    emit(ReportsLoading());
    
    try {
      // Buscar el reporte en los datos de demostración
      final demoReports = DemoData.getDemoReports();
      final report = demoReports.firstWhere(
        (r) => r.id == event.reportId,
        orElse: () => throw Exception('Reporte no encontrado'),
      );
      
      // Emitir el estado con los detalles del reporte
      // Preservamos la lista de reportes anterior si existe
      if (currentState is ReportsLoaded) {
        emit(ReportDetailsLoaded(
          report: report,
          previousReports: currentState.reports,
          filterStatus: currentState.filterStatus,
          filterCategory: currentState.filterCategory,
          filterStartDate: currentState.filterStartDate,
          filterEndDate: currentState.filterEndDate,
          filterDelegationId: currentState.filterDelegationId,
          filterMinPriority: currentState.filterMinPriority,
        ));
      } else {
        emit(ReportDetailsLoaded(report: report));
      }
    } catch (e) {
      emit(ReportsError(message: 'No se pudo cargar el reporte: ${e.toString()}'));
    }
  }

  Future<void> _onAssignReport(
    AssignReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    final result = await assignReportToTechnicianUseCase(
      AssignReportParams(
        reportId: event.reportId,
        technicianId: event.technicianId,
      ),
    );
    
    result.fold(
      (failure) => emit(ReportsError(message: failure.message)),
      (report) => emit(ReportAssigned(report: report)),
    );
  }

  Future<void> _onUpdateReportStatus(
    UpdateReportStatusEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Buscar el reporte en los datos de demostración
      final demoReports = DemoData.getDemoReports();
      final reportIndex = demoReports.indexWhere((r) => r.id == event.reportId);
      
      if (reportIndex == -1) {
        throw Exception('Reporte no encontrado');
      }
      
      // Actualizar el estado del reporte
      final updatedReport = demoReports[reportIndex].copyWith(status: event.status);
      demoReports[reportIndex] = updatedReport;
      
      // Emitir el estado con el reporte actualizado
      emit(ReportDetailsLoaded(report: updatedReport));
    } catch (e) {
      emit(ReportsError(message: 'No se pudo actualizar el estado del reporte: ${e.toString()}'));
    }
  }

  Future<void> _onAddResolutionNotes(
    AddResolutionNotesEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Buscar el reporte en los datos de demostración
      final demoReports = DemoData.getDemoReports();
      final reportIndex = demoReports.indexWhere((r) => r.id == event.reportId);
      
      if (reportIndex == -1) {
        throw Exception('Reporte no encontrado');
      }
      
      // Actualizar las notas de resolución del reporte
      final updatedReport = demoReports[reportIndex].copyWith(resolutionNotes: event.notes);
      demoReports[reportIndex] = updatedReport;
      
      // Emitir el estado con el reporte actualizado
      emit(ReportDetailsLoaded(report: updatedReport));
    } catch (e) {
      emit(ReportsError(message: 'No se pudieron agregar las notas de resolución: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReportPriority(
    UpdateReportPriorityEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Si tenemos el caso de uso real, lo usamos
      if (updateReportPriorityUseCase != null) {
        final result = await updateReportPriorityUseCase!(reportId: event.reportId, priority: event.priority);
        
        result.fold(
          (failure) => emit(ReportsError(message: failure.message)),
          (report) => emit(ReportPriorityUpdated(report: report)),
        );
      } else {
        // Implementación simulada usando datos de demostración
        final demoReports = DemoData.getDemoReports();
        final reportIndex = demoReports.indexWhere((r) => r.id == event.reportId);
        
        if (reportIndex == -1) {
          throw Exception('Reporte no encontrado');
        }
        
        // Calcular la prioridad si no se proporciona
        final priority = event.priority ?? priorityService.calculatePriority(demoReports[reportIndex]);
        
        // Actualizar la prioridad del reporte
        final updatedReport = demoReports[reportIndex].copyWith(priority: priority);
        demoReports[reportIndex] = updatedReport;
        
        // Emitir el estado con el reporte actualizado
        emit(ReportPriorityUpdated(report: updatedReport));
      }
    } catch (e) {
      emit(ReportsError(message: 'No se pudo actualizar la prioridad del reporte: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAllReportPriorities(
    UpdateAllReportPrioritiesEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Si tenemos el caso de uso real, lo usamos
      if (updateReportPriorityUseCase != null) {
        final result = await updateReportPriorityUseCase!.updateAllReportsPriorities();
        
        result.fold(
          (failure) => emit(ReportsError(message: failure.message)),
          (reports) => emit(AllReportPrioritiesUpdated(reports: reports)),
        );
      } else {
        // Implementación simulada usando datos de demostración
        final demoReports = DemoData.getDemoReports();
        final updatedReports = <Report>[];
        
        for (int i = 0; i < demoReports.length; i++) {
          final report = demoReports[i];
          final priority = priorityService.calculatePriority(report);
          final updatedReport = report.copyWith(priority: priority);
          demoReports[i] = updatedReport;
          updatedReports.add(updatedReport);
        }
        
        // Emitir el estado con los reportes actualizados
        emit(AllReportPrioritiesUpdated(reports: updatedReports));
      }
    } catch (e) {
      emit(ReportsError(message: 'No se pudieron actualizar las prioridades de los reportes: ${e.toString()}'));
    }
  }

  Future<void> _onFilterReportsByPriority(
    FilterReportsByPriorityEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is ReportsLoaded) {
      final filteredReports = currentState.reports
          .where((report) => (report.priority ?? 0) >= event.minPriority)
          .toList();
      
      emit(ReportsLoaded(
        reports: filteredReports,
        filterStatus: currentState.filterStatus,
        filterCategory: currentState.filterCategory,
        filterStartDate: currentState.filterStartDate,
        filterEndDate: currentState.filterEndDate,
        filterDelegationId: currentState.filterDelegationId,
        filterMinPriority: event.minPriority,
      ));
    } else {
      // Si no estamos en el estado ReportsLoaded, cargar todos los reportes y filtrar
      add(LoadReportsEvent(minPriority: event.minPriority));
    }
  }

  Future<void> _onLoadReportStatistics(
    LoadReportStatisticsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(ReportsLoading());
    
    try {
      // Obtener todos los reportes para mostrar en el mapa
      final allReports = DemoData.getDemoReports();
      
      // Filtrar por delegación si se especificó
      final filteredReports = event.delegationId != null
          ? allReports.where((r) => r.delegation?.id == event.delegationId).toList()
          : allReports;
      
      // Calcular estadísticas basadas en los reportes
      final Map<ReportCategory, int> reportsByCategory = {};
      final Map<ReportStatus, int> reportsByStatus = {};
      double totalResolutionTime = 0;
      int resolvedCount = 0;
      
      // Inicializar mapas con valores cero para todas las categorías y estados
      for (final category in ReportCategory.values) {
        reportsByCategory[category] = 0;
      }
      
      for (final status in ReportStatus.values) {
        reportsByStatus[status] = 0;
      }
      
      // Contar reportes por categoría y estado
      for (final report in filteredReports) {
        // Incrementar contador por categoría
        reportsByCategory[report.category] = (reportsByCategory[report.category] ?? 0) + 1;
        
        // Incrementar contador por estado
        reportsByStatus[report.status] = (reportsByStatus[report.status] ?? 0) + 1;
        
        // Calcular tiempo de resolución para reportes resueltos
        if (report.status == ReportStatus.resolved && report.resolvedAt != null) {
          final resolutionTime = report.resolvedAt!.difference(report.createdAt).inHours;
          totalResolutionTime += resolutionTime;
          resolvedCount++;
        }
      }
      
      // Calcular tiempo promedio de resolución
      final averageResolutionTime = resolvedCount > 0 ? (totalResolutionTime / resolvedCount).toDouble() : 0.0;
      
      // Calcular métricas de rendimiento adicionales
      final pendingReports = filteredReports.where((r) => r.status == ReportStatus.pending).length;
      final totalReports = filteredReports.length;
      final resolutionRate = totalReports > 0 ? resolvedCount / totalReports : 0.0;
      
      // Calcular tiempo promedio de respuesta inicial (desde creación hasta asignación)
      double avgResponseTime = 0;
      final assignedReports = filteredReports.where((r) => r.assignedAt != null).toList();
      if (assignedReports.isNotEmpty) {
        double totalResponseHours = 0;
        for (final report in assignedReports) {
          final duration = report.assignedAt!.difference(report.createdAt).inHours;
          totalResponseHours += duration;
        }
        avgResponseTime = totalResponseHours / assignedReports.length;
      }
      
      emit(ReportStatisticsLoaded(
        reportsByCategory: reportsByCategory,
        reportsByStatus: reportsByStatus,
        averageResolutionTime: averageResolutionTime,
        allReports: allReports,
        filteredReports: filteredReports,
        delegationId: event.delegationId,
        performanceMetrics: {
          'averageResponseTime': avgResponseTime,
          'resolutionRate': resolutionRate,
          'pendingRate': totalReports > 0 ? pendingReports / totalReports : 0.0,
          'satisfactionRating': 4.2, // Valor simulado
        },
      ));
    } catch (e) {
      emit(ReportsError(message: 'Error al cargar las estadísticas: ${e.toString()}'));
    }
  }
}
