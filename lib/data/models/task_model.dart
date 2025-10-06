import 'package:team_scheduler/data/models/user_model.dart';

class TaskModel {
  final int id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final List<UserModel> collaborators;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.collaborators,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final collaboratorData = (map['task_collaborators'] as List)
        .map((c) => c['users']) 
        .where((userMap) => userMap != null)
        .toList();

    return TaskModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['start_time']),
      endTime: DateTime.parse(map['end_time']),
      collaborators: collaboratorData
          .map((userData) => UserModel.fromMap(userData))
          .toList(),
    );
  }
}