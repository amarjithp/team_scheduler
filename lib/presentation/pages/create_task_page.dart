import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/presentation/cubits/task_creation/task_creation_cubit.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});
  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  int _currentStep = 0;
  final List<int> _durations = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Task')),
      body: BlocConsumer<TaskCreationCubit, TaskCreationState>(
        listener: (context, state) {
          // Can show snackbars on success/failure here
        },
        builder: (context, state) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 2) {
                context.read<TaskCreationCubit>().findSlots();
              }
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                // This is the final step: "Create Task"
                context.read<TaskCreationCubit>().createTask();
                Navigator.of(context).pop(); // Go back after creation
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
            steps: [
              Step(
                title: const Text('Task Details'),
                content: TextField(
                  onChanged: (value) => context.read<TaskCreationCubit>().titleChanged(value),
                  decoration: const InputDecoration(labelText: 'Task Title'),
                ),
                isActive: _currentStep >= 0,
              ),
              Step(
                title: const Text('Collaborators'),
                content: SizedBox(
                  height: 200, // Constrain height for the list
                  child: ListView.builder(
                    itemCount: state.allUsers.length,
                    itemBuilder: (ctx, index) {
                      final user = state.allUsers[index];
                      return CheckboxListTile(
                        title: Text(user.name),
                        value: state.selectedCollaborators.contains(user),
                        onChanged: (_) => context.read<TaskCreationCubit>().collaboratorToggled(user),
                      );
                    },
                  ),
                ),
                isActive: _currentStep >= 1,
              ),
              Step(
                title: const Text('Duration'),
                content: DropdownButtonFormField<int>(
                  hint: const Text('Select Duration (minutes)'),
                  value: state.durationInMinutes,
                  items: _durations
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d minutes')))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                       context.read<TaskCreationCubit>().durationChanged(value);
                    }
                  },
                ),
                isActive: _currentStep >= 2,
              ),
              Step(
                title: const Text('Available Slots'),
                content: _buildSlotList(state),
                isActive: _currentStep >= 3,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlotList(TaskCreationState state) {
    switch (state.status) {
      case SlotFindingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SlotFindingStatus.failure:
        return const Text('Failed to find slots. Please try again.');
      case SlotFindingStatus.success:
        if (state.availableSlots.isEmpty) {
          return const Text('No common slots found for the selected team and duration.');
        }
        return SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: state.availableSlots.length,
            itemBuilder: (ctx, index) {
              final slot = state.availableSlots[index];
              final formatter = DateFormat('E, MMM d  h:mm a');
              final isSelected = state.selectedSlot == slot;
              return ListTile(
                title: Text(formatter.format(slot.start)),
                tileColor: isSelected ? Theme.of(context).primaryColorLight : null,
                onTap: () => context.read<TaskCreationCubit>().selectSlot(slot),
              );
            },
          ),
        );
      default:
        return const Text('Select collaborators and duration to find slots.');
    }
  }
}