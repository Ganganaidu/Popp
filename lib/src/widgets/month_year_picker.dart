import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart'; // Import your build_extensions
import 'package:intl/intl.dart'; // Add this for date formatting

class MonthYearPicker extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final bool enable;
  final FormFieldValidator<DateTime?>? validator;

  const MonthYearPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedDate,
    required this.onDateSelected,
    this.enable = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date for display
    final String formattedDate = selectedDate != null
        ? DateFormat('MM/dd/yyyy').format(selectedDate!) // Format as desired
        : hint;

    return InkWell(
      onTap: enable
          ? () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                // Use selectedDate if available, else current date
                firstDate: DateTime(1900),
                // Adjust as per your requirement
                lastDate: DateTime(2100), // Adjust as per your requirement
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            }
          : null,
      child: InputDecorator(
        decoration: context
            .inputDecoration(
              label,
              formattedDate,
              enable: enable,
            )
            .copyWith(
              errorText: validator != null && validator!(selectedDate) != null
                  ? validator!(selectedDate)
                  : null,
            ),
        child: Text(
          formattedDate,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: enable ? null : Colors.grey[600],
              ),
        ),
      ),
    );
  }
}
