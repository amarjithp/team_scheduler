import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> _pickDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStartTime) _startTime = selected; else _endTime = selected;
    });
  }

  void _saveSlot() {
    if (_startTime == null || _endTime == null || !_endTime!.isAfter(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid time range.')),
      );
      return;
    }
    context.read<AvailabilityCubit>().addSlot(startTime: _startTime!, endTime: _endTime!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('E, MMM d, yyyy  h:mm a');
    return AlertDialog(
      title: const Text('Add New Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime != null ? formatter.format(_startTime!) : 'Not set'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDateTime(true),
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime != null ? formatter.format(_endTime!) : 'Not set'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDateTime(false),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _saveSlot, child: const Text('Save')),
      ],
    );
  }
}