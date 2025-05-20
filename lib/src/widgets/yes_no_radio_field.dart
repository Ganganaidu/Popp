import 'package:flutter/material.dart';

class YesNoRadioField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final List<String> options; // Add this line

  const YesNoRadioField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.options = const ['YES', 'NO'], // Provide a default value
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            children: options.map((option) { // Use the options list here
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(option, style: const TextStyle(fontSize: 15)),
                  value: option,
                  groupValue: value,
                  onChanged: onChanged,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}