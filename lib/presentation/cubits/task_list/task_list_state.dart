part of 'task_list_cubit.dart';

enum TaskListStatus { initial, loading, success, failure }

class TaskListState extends Equatable {
  final TaskListStatus status;
  final List<TaskModel> tasks;
  final String errorMessage;

  const TaskListState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.errorMessage = '',
  });

  TaskListState copyWith({
    TaskListStatus? status,
    List<TaskModel>? tasks,
    String? errorMessage,
  }) {
    return TaskListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, tasks, errorMessage];
}