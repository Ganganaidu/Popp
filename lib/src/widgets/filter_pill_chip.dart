import 'package:flutter/material.dart';

import '../theme/bikerverse_colors.dart';

/// A single rounded filter pill, shared by the outer horizontal filter row
/// and the in-sheet tab strip inside the "Filters & Sort" bottom sheet.
///
/// [selected] renders a solid green fill (used for the active in-sheet
/// tab); otherwise it's an outlined pill that turns green-outlined once
/// [count] is greater than zero, matching the "active filter" look used
/// outside the sheet.
class FilterPillChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final bool showDropdownIcon;
  final VoidCallback onTap;

  const FilterPillChip({
    super.key,
    required this.label,
    required this.onTap,
    this.count = 0,
    this.selected = false,
    this.showDropdownIcon = false,
  });

  bool get _hasCount => count > 0;

  @override
  Widget build(BuildContext context) {
    final Color background =
        selected ? BikerverseColors.accent : BikerverseColors.cardElevated;
    final Color border = selected
        ? BikerverseColors.accent
        : (_hasCount ? BikerverseColors.accent : BikerverseColors.outline);
    final Color textColor =
        selected ? BikerverseColors.onGreen : BikerverseColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (_hasCount) ...[
              const SizedBox(width: 6),
              _CountBadge(count: count, onFilledChip: selected),
            ],
            if (showDropdownIcon) ...[
              const SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down, size: 18, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool onFilledChip;

  const _CountBadge({required this.count, required this.onFilledChip});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: onFilledChip
            ? BikerverseColors.onGreen.withOpacity(0.18)
            : BikerverseColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: onFilledChip ? BikerverseColors.onGreen : BikerverseColors.onGreen,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
