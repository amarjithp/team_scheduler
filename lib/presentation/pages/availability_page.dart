import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';
import 'package:team_scheduler/presentation/cubits/task_creation/task_creation_cubit.dart';
import 'package:team_scheduler/presentation/pages/create_task_page.dart';
import 'package:team_scheduler/presentation/widgets/add_slot_dialog.dart';

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Availability'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Create Task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (context) => TaskCreationCubit(
                      context.read<AuthRepository>(),
                      context.read<TaskRepository>(),
                    )..init(), // Initialize the cubit to fetch users
                    child: const CreateTaskPage(),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: BlocBuilder<AvailabilityCubit, AvailabilityState>(
        builder: (context, state) {
          if (state is AvailabilityLoading || state is AvailabilityInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AvailabilityError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading availability: ${state.message}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }
          if (state is AvailabilityLoaded) {
            if (state.slots.isEmpty) {
              return const Center(
                child: Text(
                  'You have no availability slots.\nAdd one to get started!',
                  textAlign: TextAlign.center,
                ),
              );
            }
            // Display the list of availability slots
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: state.slots.length,
              itemBuilder: (context, index) {
                final slot = state.slots[index];
                final dayFormatter = DateFormat('E, MMM d, yyyy');
                final timeFormatter = DateFormat('h:mm a');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(
                      dayFormatter.format(slot.startTime),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${timeFormatter.format(slot.startTime)} - ${timeFormatter.format(slot.endTime)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                      onPressed: () {
                        // Show a confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete Slot?'),
                            content: const Text('Are you sure you want to delete this availability slot?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<AvailabilityCubit>().deleteSlot(slot.id);
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          // Fallback for any other unhandled state
          return const Center(child: Text('An unexpected error occurred.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            // Provide the existing Cubit instance to the dialog
            builder: (_) => BlocProvider.value(
              value: context.read<AvailabilityCubit>(),
              child: const AddSlotDialog(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Slot'),
      ),
    );
  }
}