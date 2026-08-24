import 'package:flutter/material.dart';

import '../utils/avatar_color_utils.dart';

/// A searchable, multi-select list where each row shows a colored initials
/// avatar and a trailing checkmark indicator. Used for State/City/Area/
/// Category/SubCategory filters.
class SearchableAvatarListWidget extends StatefulWidget {
  final List<String> displayList;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String searchHint;

  const SearchableAvatarListWidget({
    super.key,
    required this.displayList,
    required this.selectedItems,
    required this.onSelectionChanged,
    required this.searchHint,
  });

  @override
  State<SearchableAvatarListWidget> createState() =>
      _SearchableAvatarListWidgetState();
}

class _SearchableAvatarListWidgetState
    extends State<SearchableAvatarListWidget> {
  late List<String> _selected;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant SearchableAvatarListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync when the parent resets selection externally (e.g. "Clear all")
    // rather than relying on a ValueKey remount.
    if (oldWidget.selectedItems.join(',') != widget.selectedItems.join(',')) {
      _selected = List<String>.from(widget.selectedItems);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return widget.displayList;
    final q = _query.toLowerCase();
    return widget.displayList
        .where((item) => item.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(String item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        _selected.add(item);
      }
    });
    widget.onSelectionChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: widget.searchHint,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
            prefixIcon: Icon(Icons.search,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No results',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.38))),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _AvatarRow(
                      name: item,
                      selected: _selected.contains(item),
                      onTap: () => _toggle(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AvatarRow extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarRow({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AvatarColorUtils.colorFor(name);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                AvatarColorUtils.initialsFor(name),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
