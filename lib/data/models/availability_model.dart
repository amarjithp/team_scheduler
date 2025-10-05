import 'package:equatable/equatable.dart';

class AvailabilityModel extends Equatable {
  final int id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;

  const AvailabilityModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilityModel.fromMap(Map<String, dynamic> map) {
    return AvailabilityModel(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
    );
  }

  @override
  List<Object> get props => [id, userId, startTime, endTime];
}