import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
      AppSnackBar.error(context, 'Class end time must be after start time');
      return;
    }

    // Check for duplicates
    final exists = _schedules.any((s) =>
        s.dayOfWeek == _selectedDay &&
        s.startHour == _startTime.hour &&
        s.startMinute == _startTime.minute);

    if (exists) {
      AppSnackBar.error(context, 'A class slot already exists at this day and time');
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
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
      AppSnackBar.error(context, 'Please add at least one class schedule slot');
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
      AppSnackBar.success(context, '${subject.name} added successfully');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subject'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveSubject,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Save Subject'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Subject Details'),
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name *',
                        hintText: 'e.g. Data Structures',
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter subject name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _facultyController,
                      decoration: const InputDecoration(
                        labelText: 'Faculty / Professor (Optional)',
                        hintText: 'e.g. Dr. Smith',
                        prefixIcon: Icon(Icons.person_outline_rounded),
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
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                            ),
                            items: List.generate(6, (index) => index + 1)
                                .map((credit) => DropdownMenuItem(
                                      value: credit,
                                      child: Text('$credit'),
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
                              labelText: 'Required %',
                              prefixIcon: Icon(Icons.percent_rounded),
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(title: 'Timetable Slots'),
              AppCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day of Week',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
                            borderRadius: BorderRadius.circular(16),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                                prefixIcon: Icon(Icons.access_time_rounded),
                              ),
                              child: Text(_startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
                            borderRadius: BorderRadius.circular(16),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                                prefixIcon: Icon(Icons.access_time_filled_rounded),
                              ),
                              child: Text(_endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Slot to Timetable'),
                        onPressed: _addScheduleSlot,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Schedules List
              if (_schedules.isEmpty)
                const EmptyState(
                  icon: Icons.schedule_rounded,
                  title: 'No classes added',
                  description: 'Add slots above to populate your timetable.',
                )
              else
                ..._schedules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final slot = entry.value;
                  final startStr =
                      '${slot.startHour.toString().padLeft(2, '0')}:${slot.startMinute.toString().padLeft(2, '0')}';
                  final endStr =
                      '${slot.endHour.toString().padLeft(2, '0')}:${slot.endMinute.toString().padLeft(2, '0')}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.schedule_rounded, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.dayOfWeek,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$startStr - $endStr',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                            onPressed: () => _removeScheduleSlot(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
