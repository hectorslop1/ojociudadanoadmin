import 'package:equatable/equatable.dart';

abstract class DelegationsEvent extends Equatable {
  const DelegationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDelegationsEvent extends DelegationsEvent {
  final bool? isActive;

  const LoadDelegationsEvent({this.isActive});

  @override
  List<Object?> get props => [isActive];
}

class SelectDelegationEvent extends DelegationsEvent {
  final String? delegationId;

  const SelectDelegationEvent({this.delegationId});

  @override
  List<Object?> get props => [delegationId];
}

class ClearSelectedDelegationEvent extends DelegationsEvent {}
