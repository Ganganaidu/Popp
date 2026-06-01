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
  final Color? fillColor;
  final Icon? prefixIcon;
  final TextStyle? style;
  final Color? dropdownColor;
  final InputDecoration? decoration;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.hint,
    this.enabled = true,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.fillColor,
    this.prefixIcon,
    this.style,
    this.dropdownColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: value,
      decoration: decoration ??
          context.inputDecoration(label, hint, enable: enabled).copyWith(
                fillColor: fillColor,
                filled: fillColor != null,
                prefixIcon: prefixIcon,
              ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      style: style,
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: dropdownColor,
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
      ),
    );
  }
}
