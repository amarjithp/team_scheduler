part of 'task_list_cubit.dart';

enum TaskListStatus { initial, loading, success, failure }

class TaskListState extends Equatable {
  final TaskListStatus status;
  final List<TaskModel> tasks;
  final UserModel? currentUser;
  final String errorMessage;

  const TaskListState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.currentUser,
    this.errorMessage = '',
  });

  TaskListState copyWith({
    TaskListStatus? status,
    List<TaskModel>? tasks,
    UserModel? currentUser,
    String? errorMessage,
  }) {
    return TaskListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, currentUser, errorMessage];
}