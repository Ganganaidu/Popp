import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';

// widgets/working_hours_picker.dart
class WorkingHoursPicker extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String?>? validator;
  final bool enable;
  final TextEditingController controller; // Add controller

  const WorkingHoursPicker({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.enable = true,
    required this.controller, // Require controller
  });

  @override
  State<WorkingHoursPicker> createState() => _WorkingHoursPickerState();
}

class _WorkingHoursPickerState extends State<WorkingHoursPicker> {
  // Internal state for the picker's modal
  Map<int, bool> _selectedDays = {
    // Monday = 1, Sunday = 7
    DateTime.monday: false,
    DateTime.tuesday: false,
    DateTime.wednesday: false,
    DateTime.thursday: false,
    DateTime.friday: false,
    DateTime.saturday: false,
    DateTime.sunday: false,
  };
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _parseInitialValue(widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant WorkingHoursPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _parseInitialValue(widget.initialValue);
    }
  }

  void _parseInitialValue(String? value) {
    // This is a simplified parser. For complex strings like "Mon-Fri, 9-5; Sat 10-2",
    // a more robust parser would be needed. For now, it resets state.
    if (value == null || value.isEmpty || value == widget.hint) {
      _selectedDays = {
        DateTime.monday: false,
        DateTime.tuesday: false,
        DateTime.wednesday: false,
        DateTime.thursday: false,
        DateTime.friday: false,
        DateTime.saturday: false,
        DateTime.sunday: false,
      };
      _startTime = null;
      _endTime = null;
    } else {
      // In a real app, you'd parse 'value' to populate _selectedDays, _startTime, _endTime
      // For this implementation, we assume initialValue is mostly for display after selection.
    }
  }

  String _formatWorkingHours() {
    List<String> activeDays = [];
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ]; // Map int to string
    _selectedDays.forEach((dayInt, isSelected) {
      if (isSelected) {
        activeDays.add(daysOfWeek[dayInt - 1]); // DateTime.monday is 1
      }
    });

    String daysString =
        activeDays.isEmpty ? 'No days selected' : activeDays.join(', ');

    String timeString = '';
    if (_startTime != null && _endTime != null) {
      timeString =
          '${_startTime!.format(context)} - ${_endTime!.format(context)}';
    } else if (_startTime != null) {
      timeString = 'Starts at ${_startTime!.format(context)}';
    } else if (_endTime != null) {
      timeString = 'Ends by ${_endTime!.format(context)}';
    }

    if (activeDays.isEmpty && timeString.isEmpty) {
      return widget.hint;
    } else if (timeString.isEmpty) {
      return daysString;
    } else {
      return '$daysString, $timeString';
    }
  }

  Future<void> _showWorkingHoursPicker(FormFieldState<String> field) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content to take full height
      builder: (BuildContext context) {
        return StatefulBuilder(

          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              // include both viewInsets (keyboard) and viewPadding (system UI like nav bar)
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      MediaQuery.of(context).viewPadding.bottom +
                      8.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Select Working Days:',
                        style: Theme.of(context).textTheme.titleMedium),
                    Column(
                      children: List.generate(7, (index) {
                        final dayInt = index + 1; // DateTime.monday is 1
                        final dayName = [
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday',
                          'Saturday',
                          'Sunday'
                        ][index];
                        return CheckboxListTile(
                          title: Text(dayName),
                          value: _selectedDays[dayInt] ?? false,
                          onChanged: (bool? newValue) {
                            modalSetState(() {
                              _selectedDays[dayInt] = newValue ?? false;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text('Set Working Hours:',
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (picked != null && picked != _startTime) {
                                modalSetState(() {
                                  _startTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: context.inputDecoration(
                                'Start Time',
                                _startTime?.format(context) ?? 'Select Time',
                              ),
                              child: Text(
                                _startTime?.format(context) ?? 'Select Time',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (picked != null && picked != _endTime) {
                                modalSetState(() {
                                  _endTime = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: context.inputDecoration(
                                'End Time',
                                _endTime?.format(context) ?? 'Select Time',
                              ),
                              child: Text(
                                _endTime?.format(context) ?? 'Select Time',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final formattedText = _formatWorkingHours();
                          widget.controller.text = formattedText;
                          widget.onChanged(formattedText);
                          field.didChange(formattedText); // Sync FormField value
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: widget.validator,
      initialValue: widget.controller.text,
      builder: (FormFieldState<String> field) {
        return InkWell(
          onTap: widget.enable
              ? () async {
                  await _showWorkingHoursPicker(field);
                }
              : null,
          child: InputDecorator(
            decoration: context.inputDecoration(
              widget.label,
              widget.controller.text.isEmpty ? widget.hint : widget.controller.text,
            ).copyWith(
              errorText: field.errorText,
            ),
            child: Text(
              widget.controller.text.isEmpty ? widget.hint : widget.controller.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      },
    );
  }
}
