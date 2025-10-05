import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_scheduler/data/models/availability_model.dart';
import 'package:team_scheduler/data/repositories/availability_repository.dart';

part 'availability_state.dart';

class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository _repository;
  String? _currentUserId;

  AvailabilityCubit(this._repository) : super(AvailabilityInitial());

  Future<void> loadAvailability() async {
    try {
      emit(AvailabilityLoading());
      final prefs = await SharedPreferences.getInstance();
      _currentUserId = prefs.getString('user_id');

      if (_currentUserId == null) throw Exception('User not logged in.');

      final slots = await _repository.fetchAvailability(_currentUserId!);
      emit(AvailabilityLoaded(slots));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> addSlot({required DateTime startTime, required DateTime endTime}) async {
    try {
      if (state is AvailabilityLoaded && _currentUserId != null) {
        final newSlot = await _repository.addAvailability(
          userId: _currentUserId!,
          startTime: startTime,
          endTime: endTime,
        );

        final updatedSlots = List<AvailabilityModel>.from((state as AvailabilityLoaded).slots)..add(newSlot);
        updatedSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
        emit(AvailabilityLoaded(updatedSlots));
      }
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }

  Future<void> deleteSlot(int slotId) async {
    try {
      if (state is AvailabilityLoaded) {
        await _repository.deleteAvailability(slotId);
        final updatedSlots = (state as AvailabilityLoaded).slots.where((slot) => slot.id != slotId).toList();
        emit(AvailabilityLoaded(updatedSlots));
      }
    } catch(e) {
       emit(AvailabilityError(e.toString()));
    }
  }
}