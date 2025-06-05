import 'package:flutter/material.dart';

import '../models/pop_category.dart';
import 'custom_dropdown_form_field.dart'; // <--- Your Category model

class CategorySelector extends StatefulWidget {
  final Function(PopCategory?) onCategoryChanged;
  final Function(String?) onSubcategoryChanged;

  const CategorySelector({
    super.key,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  PopCategory? selectedCategory;
  String? selectedSubcategory;
  List<PopCategory> filteredCatList = catList.isNotEmpty ? catList.sublist(1) : [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomDropdownFormField<PopCategory>(
          label: "Category",
          hint: "Select your Category",
          value: selectedCategory,
          items: filteredCatList
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name)))
              .toList(),
          onChanged: (cat) {
            setState(() {
              selectedCategory = cat;
              selectedSubcategory = null;
            });
            widget.onCategoryChanged(cat);
            widget.onSubcategoryChanged(null);
          },
        ),
        const SizedBox(height: 16),
        CustomDropdownFormField<String>(
          label: "Sub Category",
          hint: "Select your Sub Category",
          value: selectedSubcategory,
          items: selectedCategory?.subcategories
                  ?.map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                  .toList() ??
              [],
          onChanged: (sub) {
            setState(() => selectedSubcategory = sub);
            widget.onSubcategoryChanged(sub);
          },
        ),
      ],
    );
  }
}
