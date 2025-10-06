import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_scheduler/data/models/user_model.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';
import 'package:team_scheduler/data/repositories/task_repository.dart';

part 'task_creation_state.dart';

class TaskCreationCubit extends Cubit<TaskCreationState> {
  final AuthRepository _authRepository;
  final TaskRepository _taskRepository;
  String? _currentUserId;

  TaskCreationCubit(this._authRepository, this._taskRepository) : super(const TaskCreationState());

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('user_id');
    final users = await _authRepository.getAllUsers();
    final otherUsers = users.where((user) => user.id != _currentUserId).toList();
    emit(state.copyWith(allUsers: otherUsers));
  }

  void titleChanged(String title) => emit(state.copyWith(title: title));

  void descriptionChanged(String description) => emit(state.copyWith(description: description));

  void collaboratorToggled(UserModel user) {
    final updatedSet = Set<UserModel>.from(state.selectedCollaborators);
    if (updatedSet.contains(user)) {
      updatedSet.remove(user);
    } else {
      updatedSet.add(user);
    }
    emit(state.copyWith(selectedCollaborators: updatedSet));
  }

  void durationChanged(int duration) => emit(state.copyWith(durationInMinutes: duration));

  Future<void> findSlots() async {
    if (state.durationInMinutes == null || state.selectedCollaborators.isEmpty || _currentUserId == null) return;

    emit(state.copyWith(status: SlotFindingStatus.loading));
    try {
      final collaboratorIds = state.selectedCollaborators.map((u) => u.id).toList();
    
      collaboratorIds.add(_currentUserId!);

      final slots = await _taskRepository.findCommonSlots(
        collaboratorIds: collaboratorIds,
        duration: Duration(minutes: state.durationInMinutes!),
      );
      emit(state.copyWith(status: SlotFindingStatus.success, availableSlots: slots));
    } catch (e) {
      emit(state.copyWith(status: SlotFindingStatus.failure));
    }
  }

  void selectSlot(DateTimeRange slot) => emit(state.copyWith(selectedSlot: slot));

  Future<bool> createTask() async {
    if (state.title.isEmpty || state.selectedSlot == null || _currentUserId == null) return false;

    try {
      final collaboratorIds = state.selectedCollaborators.map((u) => u.id).toList();
      collaboratorIds.add(_currentUserId!);

      await _taskRepository.createTask(
        title: state.title,
        description: state.description,
        createdBy: _currentUserId!,
        startTime: state.selectedSlot!.start,
        endTime: state.selectedSlot!.end,
        collaboratorIds: collaboratorIds,
      );
      return true;
    } catch (e) {
      print("Error creating task: $e");
      return false; 
    }
  }
}