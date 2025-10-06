import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final dayFormatter = DateFormat('E, MMM d');
    final timeFormatter = DateFormat('h:mm a');
    final collaboratorNames = task.collaborators.map((u) => u.name).join(', ');
    final duration = task.endTime.difference(task.startTime).inMinutes;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.titleLarge),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const Divider(height: 24),
            InfoRow(icon: Icons.calendar_today, text: dayFormatter.format(task.startTime)),
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.access_time,
              text: '${timeFormatter.format(task.startTime)} - ${timeFormatter.format(task.endTime)} ($duration mins)',
            ),
            const SizedBox(height: 8),
            InfoRow(icon: Icons.people_outline, text: collaboratorNames),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}