import 'package:equatable/equatable.dart';
import 'package:ojo_ciudadano_admin/domain/entities/delegation.dart';

abstract class DelegationsState extends Equatable {
  const DelegationsState();
  
  @override
  List<Object?> get props => [];
}

class DelegationsInitial extends DelegationsState {}

class DelegationsLoading extends DelegationsState {}

class DelegationsLoaded extends DelegationsState {
  final List<Delegation> delegations;
  final String? selectedDelegationId;
  final Delegation? selectedDelegation;
  
  const DelegationsLoaded({
    required this.delegations,
    this.selectedDelegationId,
    this.selectedDelegation,
  });
  
  @override
  List<Object?> get props => [delegations, selectedDelegationId, selectedDelegation];
  
  DelegationsLoaded copyWith({
    List<Delegation>? delegations,
    String? selectedDelegationId,
    Delegation? selectedDelegation,
  }) {
    return DelegationsLoaded(
      delegations: delegations ?? this.delegations,
      selectedDelegationId: selectedDelegationId ?? this.selectedDelegationId,
      selectedDelegation: selectedDelegation ?? this.selectedDelegation,
    );
  }
}

class DelegationsError extends DelegationsState {
  final String message;
  
  const DelegationsError({required this.message});
  
  @override
  List<Object> get props => [message];
}
