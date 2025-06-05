import 'package:flutter/material.dart';

class RangeFilterWidget extends StatelessWidget {
  final String title;
  final double min;
  final double max;
  final RangeValues values;
  final String unit;
  final ValueChanged<RangeValues> onChanged;

  const RangeFilterWidget({
    super.key,
    required this.title,
    required this.min,
    required this.max,
    required this.values,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String endLabel =
        values.end >= max ? '${max.toInt()}+' : '${values.end.toInt()}';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        RangeSlider(
          min: min,
          max: max,
          activeColor: Theme.of(context).primaryColor,
          divisions: 100,
          labels: RangeLabels(
            '${values.start.toInt()}',
            endLabel,
          ),
          values: values,
          onChanged: (newValues) {
            final clampedEnd = newValues.end > max ? max : newValues.end;
            onChanged(RangeValues(newValues.start, clampedEnd));
          },
        ),
        const SizedBox(height: 10),
        Text('From $unit${values.start.toInt()} to $unit$endLabel'),
      ],
    );
  }
}
