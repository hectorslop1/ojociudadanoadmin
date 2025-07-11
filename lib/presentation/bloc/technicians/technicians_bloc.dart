import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/entities/technician.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/domain/repositories/technician_repository.dart';

// Eventos
abstract class TechniciansEvent {}

class GetTechniciansEvent extends TechniciansEvent {
  final ReportCategory? specialty;
  final bool? isActive;
  
  GetTechniciansEvent({this.specialty, this.isActive});
}

class GetTechnicianByIdEvent extends TechniciansEvent {
  final String id;
  
  GetTechnicianByIdEvent(this.id);
}

// Estados
abstract class TechniciansState {}

class TechniciansInitial extends TechniciansState {}

class TechniciansLoading extends TechniciansState {}

class TechniciansLoaded extends TechniciansState {
  final List<Technician> technicians;
  
  TechniciansLoaded(this.technicians);
}

class TechnicianLoaded extends TechniciansState {
  final Technician technician;
  
  TechnicianLoaded(this.technician);
}

class TechniciansError extends TechniciansState {
  final String message;
  
  TechniciansError(this.message);
}

// Bloc
class TechniciansBloc extends Bloc<TechniciansEvent, TechniciansState> {
  final TechnicianRepository _technicianRepository;
  
  TechniciansBloc(this._technicianRepository) : super(TechniciansInitial()) {
    on<GetTechniciansEvent>(_onGetTechnicians);
    on<GetTechnicianByIdEvent>(_onGetTechnicianById);
  }
  
  Future<void> _onGetTechnicians(
    GetTechniciansEvent event,
    Emitter<TechniciansState> emit,
  ) async {
    emit(TechniciansLoading());
    final result = await _technicianRepository.getTechnicians(
      specialty: event.specialty,
      isActive: event.isActive,
    );
    
    result.fold(
      (failure) => emit(TechniciansError(failure.message)),
      (technicians) => emit(TechniciansLoaded(technicians)),
    );
  }
  
  Future<void> _onGetTechnicianById(
    GetTechnicianByIdEvent event,
    Emitter<TechniciansState> emit,
  ) async {
    emit(TechniciansLoading());
    final result = await _technicianRepository.getTechnicianById(event.id);
    
    result.fold(
      (failure) => emit(TechniciansError(failure.message)),
      (technician) => emit(TechnicianLoaded(technician)),
    );
  }
}
