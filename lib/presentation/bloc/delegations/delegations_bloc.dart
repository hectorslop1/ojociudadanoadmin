import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/domain/usecases/get_delegations_usecase.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_state.dart';

class DelegationsBloc extends Bloc<DelegationsEvent, DelegationsState> {
  final GetDelegationsUseCase getDelegationsUseCase;

  DelegationsBloc({required this.getDelegationsUseCase})
    : super(DelegationsInitial()) {
    on<LoadDelegationsEvent>(_onLoadDelegations);
    on<SelectDelegationEvent>(_onSelectDelegation);
    on<ClearSelectedDelegationEvent>(_onClearSelectedDelegation);
  }

  Future<void> _onLoadDelegations(
    LoadDelegationsEvent event,
    Emitter<DelegationsState> emit,
  ) async {
    emit(DelegationsLoading());

    final result = await getDelegationsUseCase(isActive: event.isActive);

    result.fold(
      (failure) => emit(DelegationsError(message: failure.message)),
      (delegations) => emit(DelegationsLoaded(delegations: delegations)),
    );
  }

  Future<void> _onSelectDelegation(
    SelectDelegationEvent event,
    Emitter<DelegationsState> emit,
  ) async {
    if (state is DelegationsLoaded) {
      final currentState = state as DelegationsLoaded;

      if (event.delegationId == null) {
        emit(
          currentState.copyWith(
            selectedDelegationId: null,
            selectedDelegation: null,
          ),
        );
        return;
      }

      final selectedDelegation = currentState.delegations.firstWhere(
        (delegation) => delegation.id == event.delegationId,
        orElse: () => throw Exception('Delegación no encontrada'),
      );

      emit(
        currentState.copyWith(
          selectedDelegationId: event.delegationId,
          selectedDelegation: selectedDelegation,
        ),
      );
    }
  }

  Future<void> _onClearSelectedDelegation(
    ClearSelectedDelegationEvent event,
    Emitter<DelegationsState> emit,
  ) async {
    if (state is DelegationsLoaded) {
      final currentState = state as DelegationsLoaded;
      emit(
        currentState.copyWith(
          selectedDelegationId: null,
          selectedDelegation: null,
        ),
      );
    }
  }
}
