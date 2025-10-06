import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_scheduler/data/models/task_model.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';

part 'task_list_state.dart';

class TaskListCubit extends Cubit<TaskListState> {
  final TaskRepository _taskRepository;

  TaskListCubit(this._taskRepository) : super(const TaskListState());

  Future<void> loadTasks() async {
    emit(state.copyWith(status: TaskListStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) throw Exception('User not logged in.');

      final tasks = await _taskRepository.fetchTasks(userId);
      emit(state.copyWith(status: TaskListStatus.success, tasks: tasks));
    } catch (e) {
      emit(state.copyWith(status: TaskListStatus.failure, errorMessage: e.toString()));
    }
  }
}