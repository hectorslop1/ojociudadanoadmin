import 'package:ojo_ciudadano_admin/data/models/report_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> getReports({
    String? status,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<ReportModel> getReportById(String id);
  
  Future<ReportModel> assignReportToTechnician(String reportId, String technicianId);
  
  Future<ReportModel> updateReportStatus(String reportId, String status);
  
  Future<ReportModel> addResolutionNotes(String reportId, String notes);
  
  Future<Map<String, int>> getReportCountByCategory();
  
  Future<Map<String, int>> getReportCountByStatus();
  
  Future<double> getAverageResolutionTime();
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final SupabaseClient supabaseClient;

  ReportRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ReportModel>> getReports({
    String? status,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = supabaseClient.from('reports').select('''
        *,
        citizen:citizens(*),
        assigned_technician:technicians(*)
      ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (category != null) {
        query = query.eq('category', category);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List).map((report) => ReportModel.fromJson(report)).toList();
    } catch (e) {
      throw Exception('Error al obtener los reportes: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(String id) async {
    try {
      final response = await supabaseClient.from('reports').select('''
        *,
        citizen:citizens(*),
        assigned_technician:technicians(*)
      ''').eq('id', id).single();
      
      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener el reporte: $e');
    }
  }

  @override
  Future<ReportModel> assignReportToTechnician(String reportId, String technicianId) async {
    try {
      final now = DateTime.now().toIso8601String();
      
      final response = await supabaseClient.from('reports').update({
        'assigned_technician_id': technicianId,
        'status': 'assigned',
        'assigned_at': now,
      }).eq('id', reportId).select('''
        *,
        citizen:citizens(*),
        assigned_technician:technicians(*)
      ''').single();
      
      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al asignar el reporte al técnico: $e');
    }
  }

  @override
  Future<ReportModel> updateReportStatus(String reportId, String status) async {
    try {
      final Map<String, dynamic> updateData = {'status': status};
      
      // Si el estado es "resolved", agregar la fecha de resolución
      if (status == 'resolved') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }
      
      final response = await supabaseClient.from('reports').update(updateData)
        .eq('id', reportId).select('''
          *,
          citizen:citizens(*),
          assigned_technician:technicians(*)
        ''').single();
      
      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar el estado del reporte: $e');
    }
  }

  @override
  Future<ReportModel> addResolutionNotes(String reportId, String notes) async {
    try {
      final response = await supabaseClient.from('reports').update({
        'resolution_notes': notes,
      }).eq('id', reportId).select('''
        *,
        citizen:citizens(*),
        assigned_technician:technicians(*)
      ''').single();
      
      return ReportModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al agregar notas de resolución: $e');
    }
  }

  @override
  Future<Map<String, int>> getReportCountByCategory() async {
    try {
      final response = await supabaseClient.rpc('get_report_count_by_category');
      
      return Map<String, int>.from(response);
    } catch (e) {
      throw Exception('Error al obtener el conteo de reportes por categoría: $e');
    }
  }

  @override
  Future<Map<String, int>> getReportCountByStatus() async {
    try {
      final response = await supabaseClient.rpc('get_report_count_by_status');
      
      return Map<String, int>.from(response);
    } catch (e) {
      throw Exception('Error al obtener el conteo de reportes por estado: $e');
    }
  }

  @override
  Future<double> getAverageResolutionTime() async {
    try {
      final response = await supabaseClient.rpc('get_average_resolution_time');
      
      return response as double;
    } catch (e) {
      throw Exception('Error al obtener el tiempo promedio de resolución: $e');
    }
  }
}
