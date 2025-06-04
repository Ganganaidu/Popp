import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final List<String> filters;
  final Map<String, int> activeFilterCounts;

  const FilterBar({
    super.key,
    required this.filters,
    this.activeFilterCounts = const {},
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? selectedFilter;
  RangeValues budgetRange = const RangeValues(0, 20000);

  void _openFilterBottomSheet(String filterName) {
    setState(() {
      selectedFilter = filterName;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Row(
            children: [
              Container(
                width: 150,
                color: Colors.grey[200],
                child: ListView(
                  children: widget.filters.map((f) {
                    final isSelected = f == selectedFilter;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.white,
                      title: Text(f),
                      onTap: () {
                        setState(() {
                          selectedFilter = f;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: selectedFilter == 'Budget'
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Budget Range',
                      ),
                      const SizedBox(height: 20),
                      RangeSlider(
                        min: 0,
                        max: 20000,
                        divisions: 100,
                        labels: RangeLabels(
                          budgetRange.start.round().toString(),
                          budgetRange.end >= 20000
                              ? '20000+'
                              : budgetRange.end.round().toString(),
                        ),
                        values: budgetRange,
                        onChanged: (RangeValues values) {
                          setState(() {
                            // Clamp end to 20000 as max, but allow label 20000+
                            budgetRange = RangeValues(
                              values.start,
                              values.end > 20000 ? 20000 : values.end,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'From \$${budgetRange.start.round()} to ${budgetRange.end >= 20000 ? '20000+' : '\$${budgetRange.end.round()}'}',
                      ),
                    ],
                  )
                      : Center(
                    child: Text('Options for "$selectedFilter"'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String filterName) {
    final count = widget.activeFilterCounts[filterName] ?? 0;
    final hasCount = count > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: () => _openFilterBottomSheet(filterName),
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$filterName${hasCount ? ' ($count)' : ''}'),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          shape: const StadiumBorder(side: BorderSide(color: Colors.black87)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.tune),
          const SizedBox(width: 8),
          ...widget.filters.map(_buildFilterChip).toList(),
        ],
      ),
    );
  }
}
