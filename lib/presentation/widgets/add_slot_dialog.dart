import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:team_scheduler/presentation/cubits/availability/availability_cubit.dart';

class AddSlotDialog extends StatefulWidget {
  const AddSlotDialog({super.key});
  @override
  State<AddSlotDialog> createState() => _AddSlotDialogState();
}

class _AddSlotDialogState extends State<AddSlotDialog> {
  DateTime? _startTime;
  DateTime? _endTime;
  String? _errorText;

  Future<void> _pickDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStartTime) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
      // Clear error when a date is picked
      _errorText = null;
    });
  }

  void _saveSlot() {
    if (_startTime == null || _endTime == null || !_endTime!.isAfter(_startTime!)) {
      setState(() {
        _errorText = 'Please select a valid time range.';
      });
      return;
    }
    context.read<AvailabilityCubit>().addSlot(startTime: _startTime!, endTime: _endTime!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFE0218A);
    final dialogTheme = Theme.of(context).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        onPrimary: Colors.white,
        surface: Color(0xFF27274D),
        onSurface: Colors.white,
      ),
      dialogBackgroundColor: const Color(0xFF27274D),
    );

    return Theme(
      data: dialogTheme,
      child: AlertDialog(
        backgroundColor: const Color(0xFF27274D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add New Slot', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimePickerTile(
              label: 'Start Time',
              time: _startTime,
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 16),
            _TimePickerTile(
              label: 'End Time',
              time: _endTime,
              onTap: () => _pickDateTime(false),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: GoogleFonts.inter(color: Colors.redAccent.shade100, fontSize: 12),
              ),
            ]
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _saveSlot,
            child: Text('Save', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Helper widget for a styled time picker list tile
class _TimePickerTile extends StatelessWidget {
  final String label;
  final DateTime? time;
  final VoidCallback onTap;

  const _TimePickerTile({required this.label, this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('E, MMM d  h:mm a');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  time != null ? formatter.format(time!) : 'Not set',
                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Icon(Icons.calendar_month_outlined, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}