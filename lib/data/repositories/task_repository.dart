import 'package:flutter/material.dart';
import 'package:team_scheduler/data/models/availability_model.dart';
import 'package:team_scheduler/main.dart';
import 'package:team_scheduler/data/models/task_model.dart';

class _TimeEvent implements Comparable<_TimeEvent> {
  final DateTime time;
  final int type;

  _TimeEvent(this.time, this.type);

  @override
  int compareTo(_TimeEvent other) {
    if (time.isAtSameMomentAs(other.time)) {
      return other.type.compareTo(type); 
    }
    return time.compareTo(other.time);
  }
}

class TaskRepository {
  Future<List<DateTimeRange>> findCommonSlots({
    required List<String> collaboratorIds,
    required Duration duration,
  }) async {
    print('🔍 Finding slots for collaborators: $collaboratorIds with duration: $duration');

    if (collaboratorIds.isEmpty) return [];

    final response = await supabase
        .from('availability')
        .select()
        .inFilter('user_id', collaboratorIds)
        .gte('start_time', DateTime.now().toIso8601String());

    final allSlots = (response as List).map((e) => AvailabilityModel.fromMap(e)).toList();
        print('✅ Fetched ${allSlots.length} availability slots from Supabase.');

    final events = <_TimeEvent>[];
    for (final slot in allSlots) {
      events.add(_TimeEvent(slot.startTime, 1));
      events.add(_TimeEvent(slot.endTime, -1));
    }
    events.sort();
     print('📅 Generated ${events.length} timeline events.');

    final commonRanges = <DateTimeRange>[];
    int availableCount = 0;
    DateTime? potentialStart;

    for (final event in events) {
      if (potentialStart != null && event.time.isAfter(potentialStart)) {
        if (availableCount == collaboratorIds.length) {
          commonRanges.add(DateTimeRange(start: potentialStart, end: event.time));
        }
      }

      availableCount += event.type;
      potentialStart = event.time;
    }
    print('🤝 Found ${commonRanges.length} common raw ranges: $commonRanges');

    final finalSlots = <DateTimeRange>[];
    for (final range in commonRanges) {
      DateTime slotStart = range.start;
      while(slotStart.add(duration).isBefore(range.end) || slotStart.add(duration).isAtSameMomentAs(range.end)) {
        finalSlots.add(DateTimeRange(start: slotStart, end: slotStart.add(duration)));
        slotStart = slotStart.add(const Duration(minutes: 15));
      }
    }
print('🏁 Returning ${finalSlots.length} final slots.');
    return finalSlots;
  }

  Future<void> createTask({
    required String title,
    required String createdBy,
    required DateTime startTime,
    required DateTime endTime,
    required List<String> collaboratorIds,
  }) async {
    final taskResponse = await supabase
      .from('tasks')
      .insert({
        'title': title,
        'created_by': createdBy,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      })
      .select('id')
      .single();

    final taskId = taskResponse['id'];
    final collaboratorMaps = collaboratorIds
      .map((userId) => {'task_id': taskId, 'user_id': userId})
      .toList();

    await supabase.from('task_collaborators').insert(collaboratorMaps);
  }
}