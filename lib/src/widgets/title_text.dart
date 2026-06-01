import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TitleText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(fontFamily: 'Orbitron');
    final mergedStyle = baseStyle.merge(style);
    return Text(text, style: mergedStyle);
  }
}
