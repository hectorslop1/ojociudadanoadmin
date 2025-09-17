import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_bloc.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_event.dart';
import 'package:ojo_ciudadano_admin/presentation/bloc/delegations/delegations_state.dart';

class DelegationSelector extends StatelessWidget {
  final Function(String?) onDelegationSelected;
  final bool showAllOption;

  const DelegationSelector({
    super.key,
    required this.onDelegationSelected,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DelegationsBloc, DelegationsState>(
      builder: (context, state) {
        if (state is DelegationsLoading) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        } else if (state is DelegationsLoaded) {
          final delegations = state.delegations;
          final selectedDelegationId = state.selectedDelegationId;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedDelegationId,
                hint: const Text('Seleccionar delegación'),
                icon: const Icon(Icons.location_city, size: 16),
                borderRadius: BorderRadius.circular(8),
                isExpanded: true,
                items: [
                  if (showAllOption)
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas las delegaciones'),
                    ),
                  ...delegations.map((delegation) {
                    return DropdownMenuItem<String>(
                      value: delegation.id,
                      child: Text(delegation.name),
                    );
                  }),
                ],
                onChanged: (delegationId) {
                  context.read<DelegationsBloc>().add(
                    SelectDelegationEvent(delegationId: delegationId),
                  );
                  onDelegationSelected(delegationId);
                },
              ),
            ),
          );
        } else if (state is DelegationsError) {
          return Tooltip(
            message: 'Error: ${state.message}',
            child: TextButton.icon(
              onPressed: () {
                context.read<DelegationsBloc>().add(
                  const LoadDelegationsEvent(),
                );
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reintentar'),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
