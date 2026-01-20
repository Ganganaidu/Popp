import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';

class WebConstrainedBox extends StatelessWidget {
  final Widget child;

  const WebConstrainedBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && context.isDesktop) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: child,
        ),
      );
    }
    return child;
  }
}
