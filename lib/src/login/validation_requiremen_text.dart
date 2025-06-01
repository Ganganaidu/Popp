import 'package:flutter/material.dart';

class ValidationRequirementText extends StatelessWidget {
  final String text;
  final bool isValid;

  const ValidationRequirementText({
    super.key,
    required this.text,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0), // Slightly more padding
      child: Row(
        children: [
          Icon(
            isValid
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded, // Changed icons
            color: isValid ? Colors.green.shade700 : Colors.grey.shade600,
            size: 18, // Slightly larger icon
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
