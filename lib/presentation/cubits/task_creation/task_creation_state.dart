part of 'task_creation_cubit.dart';

enum SlotFindingStatus { initial, loading, success, failure }

class TaskCreationState extends Equatable {
  final String title;
  final List<UserModel> allUsers;
  final Set<UserModel> selectedCollaborators;
  final int? durationInMinutes;
  final SlotFindingStatus status;
  final List<DateTimeRange> availableSlots;
  final DateTimeRange? selectedSlot;

  const TaskCreationState({
    this.title = '',
    this.allUsers = const [],
    this.selectedCollaborators = const {},
    this.durationInMinutes,
    this.status = SlotFindingStatus.initial,
    this.availableSlots = const [],
    this.selectedSlot,
  });

  TaskCreationState copyWith({
    String? title,
    List<UserModel>? allUsers,
    Set<UserModel>? selectedCollaborators,
    int? durationInMinutes,
    SlotFindingStatus? status,
    List<DateTimeRange>? availableSlots,
    DateTimeRange? selectedSlot,
  }) {
    return TaskCreationState(
      title: title ?? this.title,
      allUsers: allUsers ?? this.allUsers,
      selectedCollaborators: selectedCollaborators ?? this.selectedCollaborators,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      status: status ?? this.status,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedSlot: selectedSlot ?? this.selectedSlot,
    );
  }

  @override
  List<Object?> get props => [title, allUsers, selectedCollaborators, durationInMinutes, status, availableSlots, selectedSlot];
}