import 'package:flutter/material.dart';

import '../utils/avatar_color_utils.dart';

/// A searchable, multi-select 2-column grid of brand chips — colored
/// initials avatar + name, with a green border ring and corner checkmark
/// badge when selected. Used for the Brand/Model filter.
class SearchableBrandGridWidget extends StatefulWidget {
  final List<String> displayList;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;

  const SearchableBrandGridWidget({
    super.key,
    required this.displayList,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  State<SearchableBrandGridWidget> createState() =>
      _SearchableBrandGridWidgetState();
}

class _SearchableBrandGridWidgetState
    extends State<SearchableBrandGridWidget> {
  late List<String> _selected;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(covariant SearchableBrandGridWidget oldWidget) {
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
            hintText: 'Search brand',
            hintStyle: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
            prefixIcon: Icon(Icons.search,
                size: 20,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.38)),
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
        const SizedBox(height: 12),
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
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.6,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final brand = filtered[index];
                    return _BrandChip(
                      name: brand,
                      selected: _selected.contains(brand),
                      onTap: () => _toggle(brand),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _BrandChip({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AvatarColorUtils.colorFor(name);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    AvatarColorUtils.initialsFor(name),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            width: 1.5),
                      ),
                      child: Icon(Icons.check,
                          size: 10,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
