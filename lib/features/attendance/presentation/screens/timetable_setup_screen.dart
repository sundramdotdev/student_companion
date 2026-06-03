import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/subject.dart';
import '../../domain/entities/schedule.dart';
import '../providers/attendance_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class TimetableSetupScreen extends ConsumerStatefulWidget {
  const TimetableSetupScreen({super.key});

  @override
  ConsumerState<TimetableSetupScreen> createState() => _TimetableSetupScreenState();
}

class _TimetableSetupScreenState extends ConsumerState<TimetableSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _facultyController = TextEditingController();
  
  int _credits = 3;
  double _minAttendance = 75.0;
  
  final List<Schedule> _schedules = [];

  // Temporary schedule slot fields
  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    // Use settings default min attendance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final defaultMin = ref.read(minAttendanceProvider);
      setState(() {
        _minAttendance = defaultMin;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  void _addScheduleSlot() {
    // Check if start time is before end time
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class end time must be after start time.')),
      );
      return;
    }

    // Check for duplicates
    final exists = _schedules.any((s) =>
        s.dayOfWeek == _selectedDay &&
        s.startHour == _startTime.hour &&
        s.startMinute == _startTime.minute);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A class slot already exists at this day and time.')),
      );
      return;
    }

    setState(() {
      _schedules.add(
        Schedule(
          dayOfWeek: _selectedDay,
          startHour: _startTime.hour,
          startMinute: _startTime.minute,
          endHour: _endTime.hour,
          endMinute: _endTime.minute,
        ),
      );
    });
  }

  void _removeScheduleSlot(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // Automatically set end time to start time + 1 hour for convenience
        _endTime = TimeOfDay(
          hour: (picked.hour + 1) % 24,
          minute: picked.minute,
        );
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one class schedule slot.')),
      );
      return;
    }

    final subject = Subject(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      facultyName: _facultyController.text.trim().isEmpty ? null : _facultyController.text.trim(),
      minAttendancePercent: _minAttendance,
      creditHours: _credits,
      schedules: List.from(_schedules),
    );

    // Save subject
    await ref.read(subjectsProvider.notifier).addSubject(subject);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${subject.name} added to schedule successfully.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subject & Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSubject,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subject Details',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name (e.g. Mathematics)*',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  labelText: 'Faculty/Professor (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _credits,
                      decoration: const InputDecoration(
                        labelText: 'Credit Hours',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(6, (index) => index + 1)
                          .map((credit) => DropdownMenuItem(
                                value: credit,
                                child: Text('$credit Credits'),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _credits = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _minAttendance.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Required Attendance %',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final val = double.tryParse(value);
                        if (val == null || val < 0 || val > 100) return '0 - 100';
                        return null;
                      },
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          setState(() => _minAttendance = parsed);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Weekly Schedule Slots',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Custom Add Schedule Form Slot
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedDay,
                              decoration: const InputDecoration(
                                labelText: 'Day of Week',
                                border: OutlineInputBorder(),
                              ),
                              items: _daysOfWeek
                                  .map((day) => DropdownMenuItem(
                                        value: day,
                                        child: Text(day),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDay = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text('Starts: ${_startTime.format(context)}'),
                              onPressed: _selectStartTime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text('Ends: ${_endTime.format(context)}'),
                              onPressed: _selectEndTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Slot to Timetable'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: _addScheduleSlot,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Schedules List
              if (_schedules.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No weekly schedule slots added yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _schedules.length,
                  itemBuilder: (context, index) {
                    final slot = _schedules[index];
                    final startStr = '${slot.startHour.toString().padLeft(2, '0')}:${slot.startMinute.toString().padLeft(2, '0')}';
                    final endStr = '${slot.endHour.toString().padLeft(2, '0')}:${slot.endMinute.toString().padLeft(2, '0')}';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(slot.dayOfWeek),
                        subtitle: Text('$startStr - $endStr'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeScheduleSlot(index),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSubject,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Save Subject & Timetable', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
