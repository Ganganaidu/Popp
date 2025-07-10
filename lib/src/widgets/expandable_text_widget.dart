import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 2,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _showMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textSpan = TextSpan(text: widget.text, style: widget.style);
    final tp = TextPainter(
      text: textSpan,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(
        maxWidth:
            MediaQuery.of(context).size.width - 32); // 16 padding each side
    setState(() {
      _showMore = tp.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);
        final isOverflow = tp.didExceedMaxLines;

        if (!_expanded && isOverflow) {
          // Find cutoff point for maxLines
          int endIndex =
              tp.getPositionForOffset(Offset(tp.width, tp.height)).offset;
          String visibleText = widget.text.substring(0, endIndex).trim();
          // Remove last word if it is cut
          int lastSpace = visibleText.lastIndexOf(' ');
          if (lastSpace > 0) visibleText = visibleText.substring(0, lastSpace);
          return RichText(
            text: TextSpan(
              style: widget.style,
              children: [
                TextSpan(text: '$visibleText... '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => setState(() => _expanded = true),
                    child: Text(
                      'more',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.style?.fontSize ?? 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: widget.style,
              ),
              if (isOverflow && _expanded)
                GestureDetector(
                  onTap: () => setState(() => _expanded = false),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Show less',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.style?.fontSize ?? 16,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
      },
    );
  }
}
