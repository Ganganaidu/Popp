import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final bool enabled;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.hint,
    this.enabled = true,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: value,
      decoration: context.inputDecoration(label, hint, enable: enabled),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: MaterialStateProperty.all(6),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
    );
  }
}
