import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/build_extensions.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String labelDesc;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.labelDesc,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: context.inputDecoration(label, labelDesc),
      value: value,
      items: options
          .map((option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
