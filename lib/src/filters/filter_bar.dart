import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';

import '../models/pop_category.dart';
import '../utils/product_content_data.dart';
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
  int _yearFrom = DateTime.now().year - 1; // Default to 1 years ago
  int _yearTo = DateTime.now().year;

  String? _yearFromError;
  String? _yearToError;

  final Map<String, RangeValues> rangeFilterValues = {
    'Budget': const RangeValues(0, 20000),
    'By KM Driven': const RangeValues(0, 200000),
  };
  String selectedBrand = 'Brand / Model';
  String selectedState = 'By State';
  String selectedCategory = 'By Category';
  String selectedSubCategory = 'By SubCategory';
  String selectedYear = "By Year";

  List<String> _selectedBrands = [];
  List<String> _selectedStates = [];
  List<String> _selectedCategories = [];
  List<String> _selectedSubCategories = [];

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
      isDismissible: false,
      // Prevent closing by tapping outside
      enableDrag: false,
      // Prevent closing by dragging
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
            List<String> selectedStates = List<String>.from(_selectedStates);
            List<String> selectedCategories =
                List<String>.from(_selectedCategories);
            List<String> selectedSubCategories =
                List<String>.from(_selectedSubCategories);
            int tempYearFrom = _yearFrom;
            int tempYearTo = _yearTo;

            return StatefulBuilder(
              builder: (context, setSheetState) {
                void resetAll() {
                  setSheetState(() {
                    tempValues = {
                      'Budget': const RangeValues(0, 20000),
                      'By KM Driven': const RangeValues(0, 200000),
                    };
                    rangeFilterValues.clear();
                    rangeFilterValues.addAll(tempValues);
                    _selectedBrands = [];
                    _selectedStates = [];
                    _selectedCategories = [];
                    _selectedSubCategories = [];
                    _yearFrom = DateTime.now().year - 1;
                    _yearTo = DateTime.now().year;
                  });
                  widget.onFiltersChanged({
                    ...{
                      'Budget': const RangeValues(0, 20000),
                      'By KM Driven': const RangeValues(0, 200000),
                      'Brand / Model': [],
                      'By State': [],
                      'By Category': [],
                      'By SubCategory': [],
                      // Do not include 'By Year' on reset
                    }
                  });
                  Navigator.pop(context); // Close on clear all
                }

                void applyAll() {
                  setState(() {
                    rangeFilterValues.clear();
                    rangeFilterValues.addAll(tempValues);
                    _selectedBrands = List<String>.from(selectedBrands);
                    _selectedStates = List<String>.from(selectedStates);
                    _selectedCategories = List<String>.from(selectedCategories);
                    _selectedSubCategories = List<String>.from(selectedSubCategories);
                    _yearFrom = tempYearFrom;
                    _yearTo = tempYearTo;
                  });
                  final int defaultFrom = DateTime.now().year - 1;
                  final int defaultTo = DateTime.now().year;
                  final Map<String, dynamic> filterMap = {
                    ...tempValues,
                    'Brand / Model': selectedBrands,
                    'By State': selectedStates,
                    'By Category': selectedCategories,
                    'By SubCategory': selectedSubCategories,
                  };
                  if (tempYearFrom != defaultFrom || tempYearTo != defaultTo) {
                    filterMap['By Year'] = [tempYearFrom, tempYearTo];
                  }
                  widget.onFiltersChanged(filterMap);
                  Navigator.pop(context); // Close on apply
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      // Header with title and close icon
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Text(
                              'Filters & Sort',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
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
                                              ? Colors.green
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
                                  tempYearFrom,
                                  (from) {
                                    setSheetState(() {
                                      tempYearFrom = from;
                                    });
                                  },
                                  tempYearTo,
                                  (to) {
                                    setSheetState(() {
                                      tempYearTo = to;
                                    });
                                  },
                                  selectedStates,
                                  (states) {
                                    setSheetState(() {
                                      selectedStates = states;
                                    });
                                  },
                                  selectedCategories,
                                  (categories) {
                                    setSheetState(() {
                                      selectedCategories = categories;
                                    });
                                  },
                                  selectedSubCategories,
                                  (subCategories) {
                                    setSheetState(() {
                                      selectedSubCategories = subCategories;
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
      void Function(List<String>)? onBrandsChanged,
      int? tempYearFrom,
      void Function(int)? onYearFromChanged,
      int? tempYearTo,
      void Function(int)? onYearToChanged,
      List<String>? selectedStates,
      void Function(List<String>)? onStatesChanged,
      List<String>? selectedCategories,
      void Function(List<String>)? onCategoriesChanged,
      List<String>? selectedSubCategories,
      void Function(List<String>)? onSubCategoriesChanged]) {
    AppLogger.d("filterName $filterName");
    if (tempValues.containsKey(filterName)) {
      final RangeValues values = tempValues[filterName]!;
      final double max = filterName == 'Budget' ? 20000 : 200000;
      final String unit = filterName == 'Budget' ? '₹' : 'km ';

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

    if (selectedCategory.contains(filterName.trim())) {
      AppLogger.d("selectedCategory  $filterName");
      return CheckboxFilterWidget(
        displayList: getAllPopCategoryNames(),
        selectedItems: selectedCategories ?? [],
        key: ValueKey(selectedCategories?.join(',')),
        onSelectionChanged: (updatedSet) {
          if (onCategoriesChanged != null) {
            onCategoriesChanged(List<String>.from(updatedSet));
          }
        },
      );
    }

    if (selectedState.contains(filterName.trim())) {
      AppLogger.d("selectedState  $filterName");
      return CheckboxFilterWidget(
        displayList: stateNames, // You need to define statesList somewhere
        selectedItems: selectedStates ?? [],
        key: ValueKey(selectedStates?.join(',')),
        onSelectionChanged: (updatedSet) {
          if (onStatesChanged != null) {
            onStatesChanged(List<String>.from(updatedSet));
          }
        },
      );
    }

    if (selectedSubCategory.contains(filterName.trim())) {
      AppLogger.d("selectedSubCategory  $filterName");
      return CheckboxFilterWidget(
        displayList: getAllPopSubCategoryNames(),
        // You need to define subCategoryList somewhere
        selectedItems: selectedSubCategories ?? [],
        key: ValueKey(selectedSubCategories?.join(',')),
        onSelectionChanged: (updatedSet) {
          if (onSubCategoriesChanged != null) {
            onSubCategoriesChanged(List<String>.from(updatedSet));
          }
        },
      );
    }

    if (selectedYear.contains(filterName.trim())) {
      AppLogger.d("selectedYear  $filterName");
      return _yearFilterWidget(
        tempYearFrom: tempYearFrom ?? _yearFrom,
        onYearFromChanged: onYearFromChanged,
        tempYearTo: tempYearTo ?? _yearTo,
        onYearToChanged: onYearToChanged,
      );
    }

    return Center(child: Text('Options for "$filterName"'));
  }

  Widget _buildFilterChip(String filterName) {
    int count = 0;
    if (filterName == 'Brand / Model') {
      count = _selectedBrands.length;
    } else if (filterName == 'By State') {
      count = _selectedStates.length;
    } else if (filterName == 'By Category') {
      count = _selectedCategories.length;
    } else if (filterName == 'By SubCategory') {
      count = _selectedSubCategories.length;
    } else if (rangeFilterValues.containsKey(filterName)) {
      final RangeValues values = rangeFilterValues[filterName]!;
      // Count as selected if not default
      if ((filterName == 'Budget' &&
              (values.start > 0 || values.end < 20000)) ||
          (filterName == 'By KM Driven' &&
              (values.start > 0 || values.end < 200000))) {
        count = 1;
      }
    } else if (filterName == 'By Year') {
      // Show count if year range is not default
      final int defaultFrom = DateTime.now().year - 1;
      final int defaultTo = DateTime.now().year;
      if (_yearFrom != defaultFrom || _yearTo != defaultTo) {
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
              color: hasCount ? Colors.green : Colors.white70,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _yearFilterWidget({
    int? tempYearFrom,
    void Function(int)? onYearFromChanged,
    int? tempYearTo,
    void Function(int)? onYearToChanged,
  }) {
    final int currentYear = DateTime.now().year;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 35),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: context.inputDecoration(
                    "From year", "${tempYearFrom ?? _yearFrom}"),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  String? error;
                  if (parsed == null) {
                    error = 'Enter a valid year';
                  } else if (parsed > currentYear) {
                    error = 'Year cannot be in the future';
                  } else if (parsed >= (tempYearTo ?? _yearTo)) {
                    error = 'From year must be less than To year';
                  }
                  setState(() {
                    _yearFromError = error;
                  });
                  if (parsed != null && onYearFromChanged != null) {
                    onYearFromChanged(parsed);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: context.inputDecoration(
                    "To year", "${tempYearTo ?? _yearTo}"),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  String? error;
                  if (parsed == null) {
                    error = 'Enter a valid year';
                  } else if (parsed > currentYear) {
                    error = 'Year cannot be in the future';
                  } else if (parsed <= (tempYearFrom ?? _yearFrom)) {
                    error = 'To year must be greater than From year';
                  }
                  setState(() {
                    _yearToError = error;
                  });
                  if (parsed != null && onYearToChanged != null) {
                    onYearToChanged(parsed);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 30),
        if (_yearFromError != null && _yearFromError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              _yearFromError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(width: 20),
        if (_yearToError != null && _yearToError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              _yearToError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
