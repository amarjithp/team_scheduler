import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const accentColor = Color(0xFFE0218A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            text: dayFormatter.format(task.startTime),
            iconColor: accentColor,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.access_time_filled_outlined,
            text: '${timeFormatter.format(task.startTime)} - ${timeFormatter.format(task.endTime)} ($duration mins)',
            iconColor: accentColor,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.people_outline,
            text: collaboratorNames,
            iconColor: accentColor,
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  const InfoRow({super.key, required this.icon, required this.text, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8)),
          ),
        ),
      ],
    );
  }
}