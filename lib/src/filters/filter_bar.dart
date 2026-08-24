import 'package:flutter/material.dart';

import '../models/pop_category.dart';
import '../utils/product_content_data.dart';
import '../utils/product_utils.dart';
import '../widgets/filter_pill_chip.dart';
import '../widgets/range_filter_widget.dart';
import '../widgets/searchable_avatar_list_widget.dart';
import '../widgets/searchable_brand_grid_widget.dart';

class FilterBar extends StatefulWidget {
  final List<String> filters;
  final Map<String, int> activeFilterCounts;
  final void Function(Map<String, dynamic>) onFiltersChanged;
  final List<String>? dynamicStates;
  final List<String>? dynamicCities;
  final List<String>? dynamicAreas;

  /// Full unfiltered product list. When provided, the sheet shows a live
  /// "Show N bikes" count as filters are edited; when omitted (e.g. the
  /// location-only usage in service listing screens), the footer falls
  /// back to a plain "Apply" button.
  final List<Map<String, dynamic>>? products;

  const FilterBar({
    super.key,
    required this.filters,
    this.activeFilterCounts = const {},
    required this.onFiltersChanged,
    this.dynamicStates,
    this.dynamicCities,
    this.dynamicAreas,
    this.products,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  static const double _budgetMax = 20000;
  static const double _kmMax = 200000;

  final int _currentYear = DateTime.now().year;
  int get _yearBoundMin => _currentYear - 15;

  final Map<String, RangeValues> rangeFilterValues = {
    'Budget': const RangeValues(0, _budgetMax),
    'By KM Driven': const RangeValues(0, _kmMax),
  };

  late int _yearFrom = _yearBoundMin;
  late int _yearTo = _currentYear;

  List<String> _selectedBrands = [];
  List<String> _selectedStates = [];
  List<String> _selectedCities = [];
  List<String> _selectedAreas = [];
  List<String> _selectedCategories = [];
  List<String> _selectedSubCategories = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.tune,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          ...widget.filters.map(_buildFilterChip),
        ],
      ),
    );
  }

  int _countFor(String filterName) {
    if (filterName == 'Brand / Model') return _selectedBrands.length;
    if (filterName == 'By State') return _selectedStates.length;
    if (filterName == 'By City') return _selectedCities.length;
    if (filterName == 'By Area') return _selectedAreas.length;
    if (filterName == 'By Category') return _selectedCategories.length;
    if (filterName == 'By SubCategory') return _selectedSubCategories.length;
    if (rangeFilterValues.containsKey(filterName)) {
      final values = rangeFilterValues[filterName]!;
      final max = filterName == 'Budget' ? _budgetMax : _kmMax;
      return (values.start > 0 || values.end < max) ? 1 : 0;
    }
    if (filterName == 'By Year') {
      return (_yearFrom != _yearBoundMin || _yearTo != _currentYear) ? 1 : 0;
    }
    return 0;
  }

  Widget _buildFilterChip(String filterName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterPillChip(
        label: filterName,
        count: _countFor(filterName),
        showDropdownIcon: true,
        onTap: () => _openFilterBottomSheet(filterName),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            List<String> selectedCities = List<String>.from(_selectedCities);
            List<String> selectedAreas = List<String>.from(_selectedAreas);
            List<String> selectedCategories =
                List<String>.from(_selectedCategories);
            List<String> selectedSubCategories =
                List<String>.from(_selectedSubCategories);
            int tempYearFrom = _yearFrom;
            int tempYearTo = _yearTo;

            return StatefulBuilder(
              builder: (context, setSheetState) {
                bool yearIsNonDefault() =>
                    tempYearFrom != _yearBoundMin || tempYearTo != _currentYear;

                Map<String, dynamic> buildLiveFilterMap() {
                  final map = <String, dynamic>{
                    ...tempValues,
                    'Brand / Model': selectedBrands,
                    'By State': selectedStates,
                    'By City': selectedCities,
                    'By Area': selectedAreas,
                    'By Category': selectedCategories,
                    'By SubCategory': selectedSubCategories,
                  };
                  if (yearIsNonDefault()) {
                    map['By Year'] = [tempYearFrom, tempYearTo];
                  }
                  return map;
                }

                int tempCountFor(String filterName) {
                  if (filterName == 'Brand / Model') return selectedBrands.length;
                  if (filterName == 'By State') return selectedStates.length;
                  if (filterName == 'By City') return selectedCities.length;
                  if (filterName == 'By Area') return selectedAreas.length;
                  if (filterName == 'By Category') {
                    return selectedCategories.length;
                  }
                  if (filterName == 'By SubCategory') {
                    return selectedSubCategories.length;
                  }
                  if (tempValues.containsKey(filterName)) {
                    final values = tempValues[filterName]!;
                    final max = filterName == 'Budget' ? _budgetMax : _kmMax;
                    return (values.start > 0 || values.end < max) ? 1 : 0;
                  }
                  if (filterName == 'By Year') {
                    return yearIsNonDefault() ? 1 : 0;
                  }
                  return 0;
                }

                final int? liveCount = widget.products != null
                    ? ProductUtils.applyFilters(
                            widget.products!, buildLiveFilterMap())
                        .length
                    : null;

                void resetAll() {
                  final defaultValues = {
                    'Budget': const RangeValues(0, _budgetMax),
                    'By KM Driven': const RangeValues(0, _kmMax),
                  };
                  setSheetState(() {
                    tempValues = Map<String, RangeValues>.from(defaultValues);
                    selectedBrands = [];
                    selectedStates = [];
                    selectedCities = [];
                    selectedAreas = [];
                    selectedCategories = [];
                    selectedSubCategories = [];
                    tempYearFrom = _yearBoundMin;
                    tempYearTo = _currentYear;
                  });
                  setState(() {
                    rangeFilterValues.clear();
                    rangeFilterValues.addAll(defaultValues);
                    _selectedBrands = [];
                    _selectedStates = [];
                    _selectedCities = [];
                    _selectedAreas = [];
                    _selectedCategories = [];
                    _selectedSubCategories = [];
                    _yearFrom = _yearBoundMin;
                    _yearTo = _currentYear;
                  });
                  widget.onFiltersChanged({
                    ...defaultValues,
                    'Brand / Model': [],
                    'By State': [],
                    'By City': [],
                    'By Area': [],
                    'By Category': [],
                    'By SubCategory': [],
                    // Do not include 'By Year' on reset
                  });
                  Navigator.pop(context); // Close on clear all
                }

                void applyAll() {
                  setState(() {
                    rangeFilterValues.clear();
                    rangeFilterValues.addAll(tempValues);
                    _selectedBrands = List<String>.from(selectedBrands);
                    _selectedStates = List<String>.from(selectedStates);
                    _selectedCities = List<String>.from(selectedCities);
                    _selectedAreas = List<String>.from(selectedAreas);
                    _selectedCategories = List<String>.from(selectedCategories);
                    _selectedSubCategories =
                        List<String>.from(selectedSubCategories);
                    _yearFrom = tempYearFrom;
                    _yearTo = tempYearTo;
                  });
                  widget.onFiltersChanged(buildLiveFilterMap());
                  Navigator.pop(context); // Close on apply
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header with title and close icon
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                        child: Row(
                          children: [
                            Text(
                              'Filters & Sort',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(Icons.close,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      // In-sheet tab strip (replaces the old sidebar list)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: widget.filters.map((filterName) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterPillChip(
                                label: filterName,
                                count: tempCountFor(filterName),
                                selected: filterName == currentFilter,
                                onTap: () => setSheetState(
                                    () => currentFilter = filterName),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            selectedCities,
                            (cities) {
                              setSheetState(() {
                                selectedCities = cities;
                              });
                            },
                            selectedAreas,
                            (areas) {
                              setSheetState(() {
                                selectedAreas = areas;
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
                      // Sticky footer
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: resetAll,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    side: BorderSide(
                                        color: Theme.of(context).colorScheme.outline),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text('Clear all'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: applyAll,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: Text(
                                    liveCount != null
                                        ? 'Show $liveCount bikes'
                                        : 'Apply',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      List<String> selectedBrands,
      void Function(List<String>) onBrandsChanged,
      int tempYearFrom,
      void Function(int) onYearFromChanged,
      int tempYearTo,
      void Function(int) onYearToChanged,
      List<String> selectedStates,
      void Function(List<String>) onStatesChanged,
      List<String> selectedCities,
      void Function(List<String>) onCitiesChanged,
      List<String> selectedAreas,
      void Function(List<String>) onAreasChanged,
      List<String> selectedCategories,
      void Function(List<String>) onCategoriesChanged,
      List<String> selectedSubCategories,
      void Function(List<String>) onSubCategoriesChanged) {
    if (filterName == 'Budget') {
      return RangeFilterWidget(
        title: 'Select budget range',
        subtitle: 'Drag either handle to set a min and max price',
        min: 0,
        max: _budgetMax,
        divisions: 100,
        values: tempValues['Budget']!,
        formatValue: (v) => '₹${(v / 1000).round()}k',
        quickPicks: const [
          RangeQuickPick('Under ₹5k', RangeValues(0, 5000)),
          RangeQuickPick('₹5k-10k', RangeValues(5000, 10000)),
          RangeQuickPick('₹10k-15k', RangeValues(10000, 15000)),
          RangeQuickPick('₹15k+', RangeValues(15000, _budgetMax)),
        ],
        onChanged: (v) => updateValue('Budget', v),
      );
    }

    if (filterName == 'By KM Driven') {
      return RangeFilterWidget(
        title: 'Select KM driven range',
        subtitle: 'Drag either handle to set a min and max distance',
        min: 0,
        max: _kmMax,
        divisions: 100,
        values: tempValues['By KM Driven']!,
        formatValue: (v) => '${(v / 1000).round()}k km',
        quickPicks: const [
          RangeQuickPick('Under 20k', RangeValues(0, 20000)),
          RangeQuickPick('20k-50k', RangeValues(20000, 50000)),
          RangeQuickPick('50k-100k', RangeValues(50000, 100000)),
          RangeQuickPick('100k+', RangeValues(100000, _kmMax)),
        ],
        onChanged: (v) => updateValue('By KM Driven', v),
      );
    }

    if (filterName == 'By Year') {
      final double boundMin = _yearBoundMin.toDouble();
      final double boundMax = _currentYear.toDouble();
      return RangeFilterWidget(
        title: 'Select model year range',
        subtitle: 'Bikes registered within this range',
        min: boundMin,
        max: boundMax,
        divisions: _currentYear - _yearBoundMin,
        showPlusAtMax: false,
        values: RangeValues(tempYearFrom.toDouble(), tempYearTo.toDouble()),
        formatValue: (v) => '${v.round()}',
        quickPicks: [
          RangeQuickPick(
            'Last 2 yrs',
            RangeValues((_currentYear - 2).toDouble(), boundMax),
          ),
          RangeQuickPick(
            'Last 6 yrs',
            RangeValues((_currentYear - 6).toDouble(), boundMax),
          ),
          RangeQuickPick('Any year', RangeValues(boundMin, boundMax)),
        ],
        onChanged: (v) {
          onYearFromChanged(v.start.round());
          onYearToChanged(v.end.round());
        },
      );
    }

    if (filterName == 'Brand / Model') {
      return SearchableBrandGridWidget(
        displayList: bikeBrands,
        selectedItems: selectedBrands,
        onSelectionChanged: onBrandsChanged,
      );
    }

    if (filterName == 'By Category') {
      return SearchableAvatarListWidget(
        displayList: getAllPopCategoryNames(),
        selectedItems: selectedCategories,
        searchHint: 'Search category',
        onSelectionChanged: onCategoriesChanged,
      );
    }

    if (filterName == 'By State') {
      return SearchableAvatarListWidget(
        displayList: widget.dynamicStates ?? stateNames,
        selectedItems: selectedStates,
        searchHint: 'Search state',
        onSelectionChanged: onStatesChanged,
      );
    }

    if (filterName == 'By City') {
      return SearchableAvatarListWidget(
        displayList: widget.dynamicCities ?? [],
        selectedItems: selectedCities,
        searchHint: 'Search city',
        onSelectionChanged: onCitiesChanged,
      );
    }

    if (filterName == 'By Area') {
      return SearchableAvatarListWidget(
        displayList: widget.dynamicAreas ?? [],
        selectedItems: selectedAreas,
        searchHint: 'Search area',
        onSelectionChanged: onAreasChanged,
      );
    }

    if (filterName == 'By SubCategory') {
      return SearchableAvatarListWidget(
        displayList: getAllPopSubCategoryNames(),
        selectedItems: selectedSubCategories,
        searchHint: 'Search subcategory',
        onSelectionChanged: onSubCategoriesChanged,
      );
    }

    return Center(
      child: Text('Options for "$filterName"',
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.38))),
    );
  }
}
