import 'package:flutter/material.dart';


class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  final Color? iconColor;
  final String? iconSemanticLabel;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.accent = false,
    this.iconColor,
    this.iconSemanticLabel
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = accent ? cs.primary : cs.onSurface.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Icon(icon,
              semanticLabel: iconSemanticLabel,
              color: iconColor ??
                  (accent ? cs.primary : cs.onSurface),
              size: 22),
        ),
      ),
    );
  }
}
