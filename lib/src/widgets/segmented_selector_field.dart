import 'package:flutter/material.dart';

import '../theme/bikerverse_colors.dart';

/// A segmented single-select control styled like the app's premium dark theme.
///
/// Renders an optional leading icon + label, then a row of pill segments.
/// The selected segment is filled with the primary green; the rest are
/// outlined. Wrapped in a [FormField] so it participates in step validation.
class SegmentedSelectorField extends FormField<String> {
  SegmentedSelectorField({
    super.key,
    required String label,
    required List<String> options,
    required String? value,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<String> field) {
            void update(String v) {
              field.didChange(v);
              onChanged(v);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: BikerverseColors.textMuted),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: const TextStyle(
                        color: BikerverseColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (int i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _Segment(
                          label: options[i],
                          selected: value == options[i],
                          onTap: () => update(options[i]),
                        ),
                      ),
                    ],
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(field.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BikerverseColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? BikerverseColors.accent : BikerverseColors.outline,
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: BikerverseColors.accentGlow,
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? BikerverseColors.onGreen
                : BikerverseColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
