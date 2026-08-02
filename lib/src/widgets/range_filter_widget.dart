import 'package:flutter/material.dart';

import '../theme/bikerverse_colors.dart';
import 'filter_pill_chip.dart';

/// A named shortcut range (e.g. "Under ₹5k") shown as a quick-pick chip
/// below the slider.
class RangeQuickPick {
  final String label;
  final RangeValues range;

  const RangeQuickPick(this.label, this.range);
}

/// A range-filter section: title/subtitle, boxed MIN/MAX value display, a
/// draggable dual-handle slider, and a row of quick-pick preset chips.
/// Reused for Budget, KM Driven, and Year (year passes whole-number bounds
/// and [showPlusAtMax]: false, since "2026+" doesn't read naturally the way
/// "₹20k+" or "200k+ km" do).
class RangeFilterWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final double min;
  final double max;
  final RangeValues values;
  final String Function(double value) formatValue;
  final bool showPlusAtMax;
  final List<RangeQuickPick> quickPicks;
  final ValueChanged<RangeValues> onChanged;
  final int? divisions;

  const RangeFilterWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.min,
    required this.max,
    required this.values,
    required this.formatValue,
    required this.onChanged,
    this.showPlusAtMax = true,
    this.quickPicks = const [],
    this.divisions,
  });

  @override
  Widget build(BuildContext context) {
    final String minLabel = formatValue(values.start);
    final String maxLabel = (showPlusAtMax && values.end >= max)
        ? '${formatValue(values.end)}+'
        : formatValue(values.end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BikerverseColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: BikerverseColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _ValueBox(label: 'MIN', value: minLabel)),
            const SizedBox(width: 12),
            Expanded(child: _ValueBox(label: 'MAX', value: maxLabel)),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: BikerverseColors.brightGreen,
            inactiveTrackColor: BikerverseColors.outline,
            thumbColor: Colors.white,
            overlayColor: BikerverseColors.accentGlow,
            valueIndicatorColor: BikerverseColors.accent,
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
            trackHeight: 4,
          ),
          child: RangeSlider(
            min: min,
            max: max,
            values: values,
            divisions: divisions,
            labels: RangeLabels(minLabel, maxLabel),
            onChanged: (newValues) {
              final clampedEnd =
                  newValues.end > max ? max : newValues.end;
              final clampedStart =
                  newValues.start < min ? min : newValues.start;
              onChanged(RangeValues(clampedStart, clampedEnd));
            },
          ),
        ),
        if (quickPicks.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickPicks.map((preset) {
              final bool isActive = values.start == preset.range.start &&
                  values.end == preset.range.end;
              return FilterPillChip(
                label: preset.label,
                selected: isActive,
                onTap: () => onChanged(preset.range),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label;
  final String value;

  const _ValueBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BikerverseColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BikerverseColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BikerverseColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: BikerverseColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
