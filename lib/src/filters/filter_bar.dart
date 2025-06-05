import 'package:flutter/material.dart';
import 'package:poppflutter/src/utils/app_loger.dart';

import '../services/models/bike_form_data.dart';
import '../widgets/checkbox_filter_widget.dart';
import '../widgets/range_widget.dart';

class FilterBar extends StatefulWidget {
  final List<String> filters;
  final Map<String, int> activeFilterCounts;
  final void Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBar({
    super.key,
    required this.filters,
    this.activeFilterCounts = const {},
    required this.onFiltersChanged,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  String? selectedFilter;

  final Map<String, RangeValues> rangeFilterValues = {
    'Budget': const RangeValues(0, 20000),
    'By KM Driven': const RangeValues(0, 200000),
  };
  String selectedBrand = 'Brand / Model';

  // Store selected brands in the state
  List<String> _selectedBrands = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.tune),
          const SizedBox(width: 8),
          ...widget.filters.map(_buildFilterChip),
        ],
      ),
    );
  }

  void _openFilterBottomSheet(String initialFilter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String currentFilter = initialFilter;
            // Use copies of the current state for temp values
            Map<String, RangeValues> tempValues =
                Map<String, RangeValues>.from(rangeFilterValues);
            List<String> selectedBrands = List<String>.from(_selectedBrands);

            return StatefulBuilder(
              builder: (context, setSheetState) {
                void resetAll() {
                  setSheetState(() {
                    tempValues = {
                      'Budget': const RangeValues(0, 20000),
                      'By KM Driven': const RangeValues(0, 200000),
                    };
                    selectedBrands = [];
                  });
                }

                void applyAll() {
                  setState(() {
                    rangeFilterValues.clear();
                    rangeFilterValues.addAll(tempValues);
                    _selectedBrands = List<String>.from(selectedBrands);
                  });
                  widget.onFiltersChanged({
                    ...tempValues,
                    'Brand / Model': selectedBrands,
                  });
                  Navigator.pop(context);
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Left filter list
                            Container(
                              width: 150,
                              color: Colors.grey[200],
                              child: ListView.separated(
                                itemCount: widget.filters.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final filterName = widget.filters[index];
                                  final isSelected =
                                      filterName == currentFilter;
                                  return ListTile(
                                    selected: isSelected,
                                    selectedTileColor: Colors.white,
                                    title: Text(filterName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.black54,
                                        )),
                                    onTap: () {
                                      setSheetState(() {
                                        currentFilter = filterName;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            // Right content
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: _buildFilterOptions(
                                  currentFilter,
                                  tempValues,
                                  (filter, val) {
                                    setSheetState(() {
                                      tempValues[filter] = val;
                                    });
                                  },
                                  selectedBrands,
                                  (brands) {
                                    setSheetState(() {
                                      selectedBrands = brands;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: resetAll,
                                child: const Text('Clear All'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: applyAll,
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOptions(
      String filterName,
      Map<String, RangeValues> tempValues,
      void Function(String, RangeValues) updateValue,
      [List<String>? selectedBrands,
      void Function(List<String>)? onBrandsChanged]) {
    AppLogger.d("filterName $filterName");
    if (tempValues.containsKey(filterName)) {
      final RangeValues values = tempValues[filterName]!;
      final double max = filterName == 'Budget' ? 20000 : 200000;
      final String unit = filterName == 'Budget' ? '\$' : 'km';

      return RangeFilterWidget(
        title: 'Select $filterName Range',
        unit: unit,
        min: 0,
        max: max,
        values: values,
        onChanged: (newValues) => updateValue(filterName, newValues),
      );
    }

    if (selectedBrand.contains(filterName.trim())) {
      AppLogger.d("selectedBrand  $filterName");
      return CheckboxFilterWidget(
        displayList: bikeBrands,
        selectedItems: selectedBrands ?? [],
        key: ValueKey(selectedBrands?.join(',')), // Add key to force rebuild
        onSelectionChanged: (updatedSet) {
          if (onBrandsChanged != null) {
            onBrandsChanged(List<String>.from(updatedSet));
          }
        },
      );
    }

    return Center(child: Text('Options for "$filterName"'));
  }

  Widget _buildFilterChip(String filterName) {
    int count = 0;
    if (filterName == 'Brand / Model') {
      count = _selectedBrands.length;
    } else if (rangeFilterValues.containsKey(filterName)) {
      final RangeValues values = rangeFilterValues[filterName]!;
      // Count as selected if not default
      if ((filterName == 'Budget' &&
              (values.start > 0 || values.end < 20000)) ||
          (filterName == 'By KM Driven' &&
              (values.start > 0 || values.end < 200000))) {
        count = 1;
      }
    }
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
          shape: StadiumBorder(
            side: BorderSide(
              color: hasCount ? Colors.orange : Colors.white70,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
