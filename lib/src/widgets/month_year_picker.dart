import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/custom_month_year_picker_dialog.dart';

class MonthYearPicker extends StatelessWidget {
  final String label;
  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final bool enable;
  final FormFieldValidator<DateTime?>? validator;
  final bool selectOnlyMonthYear;

  const MonthYearPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedDate,
    required this.onDateSelected,
    this.enable = true,
    this.validator,
    this.selectOnlyMonthYear = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- UPDATED: Conditional date formatting ---
    final String displayFormat =
        selectOnlyMonthYear ? 'MMMM yyyy' : 'MM/dd/yyyy';
    final String formattedDate = selectedDate != null
        ? DateFormat(displayFormat).format(selectedDate!)
        : ""; // Show nothing if no date is selected, hint will be in the label

    return FormField<DateTime>(
      validator: validator,
      initialValue: selectedDate,
      builder: (FormFieldState<DateTime> field) {
        return InkWell(
          onTap: enable
              ? () async {
                  // --- UPDATED: Conditional picker logic ---
                  if (selectOnlyMonthYear) {
                    // Show custom Month/Year Picker
                    final DateTime? picked = await showDialog<DateTime>(
                      context: context,
                      builder: (BuildContext context) =>
                          CustomMonthYearPickerDialog(
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ),
                    );
                    if (picked != null) {
                      AppLogger.d("picked $picked");
                      onDateSelected(picked);
                      field.didChange(picked); // Update FormField state
                    }
                  } else {
                    // Show standard Date Picker
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      AppLogger.d("picked $picked");
                      onDateSelected(picked);
                      field.didChange(picked); // Update FormField state
                    }
                  }
                }
              : null,
          child: InputDecorator(
            decoration: context
                .inputDecoration(
                  label,
                  hint, // Use the hint text in the decoration
                  enable: enable,
                  icon: Icons.calendar_today_outlined,
                )
                .copyWith(
                  errorText: field.errorText,
                ),
            child: Text(
              formattedDate.isEmpty ? hint : formattedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: formattedDate.isEmpty
                        ? Colors.grey[600]
                        : (enable ? null : Colors.grey[600]),
                  ),
            ),
          ),
        );
      },
    );
  }
}
