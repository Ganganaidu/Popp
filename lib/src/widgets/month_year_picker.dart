import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';

class MonthYearPicker extends StatelessWidget {
  final String label;
  final String hint;
  final bool enable;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const MonthYearPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.enable,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Future<void> _selectMonthYear(BuildContext context) async {
    final now = DateTime.now();
    int tempSelectedYear = selectedDate?.year ?? now.year;
    int tempSelectedMonth = selectedDate?.month ?? now.month;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Month and Year'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: tempSelectedYear,
                    items: [for (int y = now.year; y >= 1990; y--) y]
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempSelectedYear = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<int>(
                    value: tempSelectedMonth,
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(
                                '${month.toString().padLeft(2, '0')} - ${_monthName(month)}',
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempSelectedMonth = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                        context, DateTime(tempSelectedYear, tempSelectedMonth));
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        onDateSelected(result);
      }
    });
  }

  static String _monthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Conditionally allow tap
      onTap: enable ? () => _selectMonthYear(context) : null,
      child: InputDecorator(
        decoration: context.inputDecoration(label, hint, enable: enable),
        child: Text(
          selectedDate != null
              ? "${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}"
              : 'Tap to select',
          style: TextStyle(fontSize: 16, color: enable ? null : Colors.grey),
        ),
      ),
    );
  }
}
