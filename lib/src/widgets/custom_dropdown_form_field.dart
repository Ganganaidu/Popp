import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';

class CustomDropdownFormField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? value;
  final bool enabled;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final Color? fillColor;
  final Icon? prefixIcon;
  final TextStyle? style;
  final Color? dropdownColor;
  final InputDecoration? decoration;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.hint,
    this.enabled = true,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.fillColor,
    this.prefixIcon,
    this.style,
    this.dropdownColor,
    this.decoration,
  });

  @override
  State<CustomDropdownFormField<T>> createState() =>
      _CustomDropdownFormFieldState<T>();
}

class _CustomDropdownFormFieldState<T>
    extends State<CustomDropdownFormField<T>> {
  late final ValueNotifier<T?> _valueNotifier =
      ValueNotifier<T?>(widget.value);

  @override
  void didUpdateWidget(covariant CustomDropdownFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _valueNotifier.value = widget.value;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      isExpanded: true,
      valueListenable: _valueNotifier,
      decoration: widget.decoration ??
          context
              .inputDecoration(widget.label, widget.hint,
                  enable: widget.enabled)
              .copyWith(
                fillColor: widget.fillColor,
                // When no explicit fillColor, keep the base decoration's fill
                // (passing null to copyWith leaves `filled` unchanged).
                filled: widget.fillColor != null ? true : null,
                prefixIcon: widget.prefixIcon,
              ),
      items: widget.items
          .map((item) => DropdownItem<T>(value: item.value, child: item.child))
          .toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      validator: widget.validator,
      style: widget.style,
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: widget.dropdownColor,
        ),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: WidgetStateProperty.all(6),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
      ),
    );
  }
}