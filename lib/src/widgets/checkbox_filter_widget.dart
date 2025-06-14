import 'package:flutter/material.dart';

class CheckboxFilterWidget extends StatefulWidget {
  final List<String> selectedItems;
  final List<String> displayList;
  final ValueChanged<List<String>> onSelectionChanged;

  const CheckboxFilterWidget({
    super.key,
    required this.displayList,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<CheckboxFilterWidget> createState() => _CheckboxFilterWidgetState();
}

class _CheckboxFilterWidgetState extends State<CheckboxFilterWidget> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    // Initialize selection from widget.selectedItems
    _selected = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: widget.displayList.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final option = widget.displayList[index];
              final isSelected = _selected.contains(option);

              return CheckboxListTile(
                title: Text(option),
                value: isSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selected.add(option);
                    } else {
                      _selected.remove(option);
                    }
                    widget.onSelectionChanged(_selected);
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
