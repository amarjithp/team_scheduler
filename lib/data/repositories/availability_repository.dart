import 'package:team_scheduler/data/models/availability_model.dart';
import 'package:team_scheduler/main.dart';

class AvailabilityRepository {

  Future<List<AvailabilityModel>> fetchAvailability(String userId) async {
    final response = await supabase
        .from('availability')
        .select()
        .eq('user_id', userId)
        .order('start_time', ascending: true);
    return (response as List).map((data) => AvailabilityModel.fromMap(data)).toList();
  }

  Future<AvailabilityModel> addAvailability({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await supabase
        .from('availability')
        .insert({
          'user_id': userId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        })
        .select()
        .single();
    return AvailabilityModel.fromMap(response);
  }

  Future<void> deleteAvailability(int slotId) async {
    await supabase.from('availability').delete().eq('id', slotId);
  }
}