import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';
import 'package:team_scheduler/presentation/widgets/add_slot_dialog.dart';

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Availability')),
      body: BlocBuilder<AvailabilityCubit, AvailabilityState>(
        builder: (context, state) {
          if (state is AvailabilityLoading || state is AvailabilityInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AvailabilityError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is AvailabilityLoaded) {
            if (state.slots.isEmpty) {
              return const Center(
                child: Text('You have no availability slots.\nAdd one to get started!', textAlign: TextAlign.center),
              );
            }
            return ListView.builder(
              itemCount: state.slots.length,
              itemBuilder: (context, index) {
                final slot = state.slots[index];
                final dayFormatter = DateFormat('E, MMM d');
                final timeFormatter = DateFormat('h:mm a');
                return ListTile(
                  title: Text(dayFormatter.format(slot.startTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${timeFormatter.format(slot.startTime)} - ${timeFormatter.format(slot.endTime)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => context.read<AvailabilityCubit>().deleteSlot(slot.id),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<AvailabilityCubit>(),
            child: const AddSlotDialog(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}