import 'package:flutter/material.dart';

class CustomMonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomMonthYearPickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomMonthYearPickerDialog> createState() =>
      _CustomMonthYearPickerDialogState();
}

class _CustomMonthYearPickerDialogState
    extends State<CustomMonthYearPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  static const List<String> monthNames = [
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
    'December',
  ];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
  }

  void _previousYear() {
    if (selectedYear > widget.firstDate.year) {
      setState(() => selectedYear--);
    }
  }

  void _nextYear() {
    if (selectedYear < widget.lastDate.year) {
      setState(() => selectedYear++);
    }
  }

  void _selectMonth(int month) {
    final selectedDate = DateTime(selectedYear, month);
    Navigator.of(context).pop(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'SELECT MONTH/YEAR',
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 24),

            // Month and Year display
            Text(
              '${monthNames[selectedMonth - 1]} $selectedYear',
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 32),

            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedYear',
                  style: theme.textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousYear,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextYear,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Month grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth;
                  final monthName =
                      monthNames[month - 1].substring(0, 3).toUpperCase();

                  return Material(
                    child: InkWell(
                      onTap: () => _selectMonth(month),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            monthName,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _selectMonth(selectedMonth),
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
