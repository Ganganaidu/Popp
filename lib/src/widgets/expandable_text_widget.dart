import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String description;

  const ExpandableText({super.key, required this.description});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;
  bool isLongText = false;

  final int maxLines = 5;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Delay measuring to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTextOverflow());
  }

  void _checkTextOverflow() {
    final textRenderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (textRenderBox != null) {
      final textHeight = textRenderBox.size.height;
      const lineHeight = 18.0; // Approximate line height, adjust if needed
      final visibleLines = textHeight / lineHeight;

      setState(() {
        isLongText = visibleLines > maxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          key: _textKey,
          maxLines: isExpanded ? null : maxLines,
          overflow: TextOverflow.fade,
          style: theme.titleMedium
              ?.copyWith(fontWeight: FontWeight.normal),
        ),
        if (isLongText)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Text(
              isExpanded ? "Show Less" : "Show More",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
