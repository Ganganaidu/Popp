import 'package:flutter/material.dart';

/// A common app bar for all screens that handles accessibility (Semantics)
/// out of the box. The back button always carries a semantic label — defaults
/// to "Go back" — so screen readers announce it correctly without per-screen
/// boilerplate.
///
/// Separate from [PopAppBar], which is the branded bottom-nav-aware bar.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Text shown as the app-bar title. Mutually exclusive with [titleWidget].
  final String? title;

  /// Arbitrary widget shown as the app-bar title. Takes priority over [title].
  final Widget? titleWidget;

  /// Whether to show a back button as the leading widget.
  ///
  /// Defaults to `null`, meaning the button is shown whenever the current
  /// route can be popped (i.e. the Navigator stack has more than one entry).
  /// Pass `true` or `false` to override this auto-detection.
  final bool? showBackButton;

  /// Semantic label announced by screen readers when the back button is focused.
  /// Defaults to `"Go back"`.
  final String backButtonLabel;

  /// Custom action called when the back button is pressed.
  /// Defaults to `Navigator.of(context).pop()`.
  final VoidCallback? onBackPressed;

  /// Replaces the entire leading area (back button). When this is provided,
  /// [showBackButton], [backButtonLabel], and [onBackPressed] are ignored.
  final Widget? leading;

  /// Action widgets placed at the end of the app bar.
  final List<Widget>? actions;

  final bool centerTitle;

  /// Background colour. Defaults to the theme's [AppBarTheme.backgroundColor].
  final Color? backgroundColor;

  final double elevation;

  /// Placed below the toolbar — useful for [TabBar] or a search field.
  final PreferredSizeWidget? bottom;

  const CommonAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton,
    this.backButtonLabel = 'Go back',
    this.onBackPressed,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  }) : assert(
          title == null || titleWidget == null,
          'Provide either title or titleWidget, not both.',
        );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: Theme.of(context).appBarTheme.titleTextStyle ??
                      Theme.of(context).textTheme.titleLarge,
                )
              : null),
      leading: _buildLeading(context),
      actions: actions,
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    final shouldShow =
        showBackButton ?? ModalRoute.of(context)?.canPop ?? false;

    if (!shouldShow) return null;

    final void Function() handleBack =
        onBackPressed ?? () => Navigator.of(context).pop();

    return Semantics(
      label: backButtonLabel,
      button: true,
      enabled: true,
      onTap: handleBack,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: backButtonLabel,
        onPressed: handleBack,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
