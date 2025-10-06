import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';
import 'package:team_scheduler/data/repositories/availability_repository.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';
import 'package:team_scheduler/presentation/cubits/task_creation/task_creation_cubit.dart';
import 'package:team_scheduler/presentation/cubits/task_list/task_list_cubit.dart';
import 'package:team_scheduler/presentation/pages/availability_page.dart';
import 'package:team_scheduler/presentation/pages/create_task_page.dart';
import 'package:team_scheduler/presentation/widgets/task_card.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_available),
            tooltip: 'My Availability',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (context) => AvailabilityCubit(
                    context.read<AvailabilityRepository>(),
                  )..loadAvailability(),
                  child: const AvailabilityPage(),
                ),
              ));
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListCubit, TaskListState>(
        builder: (context, state) {
          if (state.status == TaskListStatus.loading || state.status == TaskListStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TaskListStatus.failure) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.tasks.isEmpty) {
            return const Center(child: Text('No tasks found. Create one to get started!'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<TaskListCubit>().loadTasks(),
            child: ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskCard(task: task);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        onPressed: () async {
          final result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => TaskCreationCubit(
                context.read<AuthRepository>(),
                context.read<TaskRepository>(),
              )..init(),
              child: const CreateTaskPage(),
            ),
          ));

          if (result == true && mounted) {
            context.read<TaskListCubit>().loadTasks();
          }
        },
      ),
    );
  }
}