import 'package:flutter/material.dart';

import '../theme/bikerverse_colors.dart';

class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;
  final Color? iconColor;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.accent = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        accent ? BikerverseColors.accent : BikerverseColors.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: BikerverseColors.iconButtonBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Icon(icon,
              color: iconColor ??
                  (accent
                      ? BikerverseColors.accent
                      : BikerverseColors.textPrimary),
              size: 22),
        ),
      ),
    );
  }
}
