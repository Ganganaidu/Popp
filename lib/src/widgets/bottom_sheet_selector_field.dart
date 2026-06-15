import 'package:flutter/material.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';
import 'package:popp/src/utils/build_extensions.dart';

/// A form field that opens a themed bottom sheet for selection instead of a dropdown.
class BottomSheetSelectorField<T> extends StatefulWidget {

  final String label;
  final String hint;
  final T? value;
  final bool enabled;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final Icon? prefixIcon;

  const BottomSheetSelectorField({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    this.enabled = true,
    required this.items,
    required this.labelBuilder,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<BottomSheetSelectorField<T>> createState() =>
      _BottomSheetSelectorFieldState<T>();
}

class _BottomSheetSelectorFieldState<T>
    extends State<BottomSheetSelectorField<T>> {
  final _fieldKey = GlobalKey<FormFieldState<T>>();

  @override
  void didUpdateWidget(covariant BottomSheetSelectorField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fieldKey.currentState?.didChange(widget.value);
      });
    }
  }

  Future<void> _showPicker() async {
    if (!widget.enabled) return;
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: BikerverseColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SelectorSheet<T>(
        title: widget.label,
        items: widget.items,
        selected: widget.value,
        labelBuilder: widget.labelBuilder,
      ),
    );
    if (result != null) {
      _fieldKey.currentState?.didChange(result);
      widget.onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (state) {
        final displayText =
            state.value != null ? widget.labelBuilder(state.value as T) : null;
        final decoration = context
            .inputDecoration(widget.label, widget.hint, enable: widget.enabled)
            .copyWith(
              prefixIcon: widget.prefixIcon,
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                color: widget.enabled
                    ? Colors.grey
                    : BikerverseColors.textMuted,
              ),
              errorText: state.hasError ? state.errorText : null,
            );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? _showPicker : null,
          child: InputDecorator(
            decoration: decoration,
            isEmpty: displayText == null,
            child: displayText != null
                ? Text(
                    displayText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: BikerverseColors.textPrimary,
                        ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _SelectorSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T) labelBuilder;

  const _SelectorSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: BikerverseColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: BikerverseColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Divider(color: BikerverseColors.divider, height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final label = labelBuilder(item);
                  final isSelected = item == selected;
                  return _SelectionTile(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: isSelected
              ? BoxDecoration(
                  color: BikerverseColors.accentFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BikerverseColors.accent.withValues(alpha: 0.3),
                  ),
                )
              : null,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? BikerverseColors.textPrimary
                        : BikerverseColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: BikerverseColors.brightGreen,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
