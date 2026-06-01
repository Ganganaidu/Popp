import 'package:flutter/material.dart';

/// A breadcrumb navigation bar showing the path to the current page.
/// e.g. Home / Premium Bikes / Ducati Panigale V2
///
/// Tapping any non-last segment pops back the appropriate number of routes.
class BreadcrumbBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> segments;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const BreadcrumbBar({
    super.key,
    required this.segments,
    this.onBack,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return AppBar(
      backgroundColor: isLight ? Colors.white : theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ),
      titleSpacing: 0,
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _buildCrumbs(context),
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isLight ? Colors.grey.shade200 : Colors.grey.shade800,
        ),
      ),
    );
  }

  List<Widget> _buildCrumbs(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> crumbs = [];

    for (int i = 0; i < segments.length; i++) {
      final isLast = i == segments.length - 1;
      final label = segments[i];

      crumbs.add(
        GestureDetector(
          onTap: isLast
              ? null
              : () {
                  final stepsBack = segments.length - 1 - i;
                  for (int j = 0; j < stepsBack; j++) {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                },
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
              color: isLast
                  ? theme.textTheme.bodyLarge?.color
                  : Colors.orange,
              decoration: isLast ? null : TextDecoration.underline,
              decorationColor: Colors.orange,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      if (!isLast) {
        crumbs.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ),
        );
      }
    }

    return crumbs;
  }
}
