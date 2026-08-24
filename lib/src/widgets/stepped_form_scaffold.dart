import 'package:flutter/material.dart';

import '../toolbar/common_app_bar.dart';
import 'title_text.dart';
import 'web_constrained_box.dart';

/// Allows the parent to programmatically jump to a specific step.
class SteppedFormController {
  void Function(int)? _jumpTo;
  void jumpTo(int index) => _jumpTo?.call(index);
}

/// A single step inside a [SteppedFormScaffold].
///
/// The [builder] returns the form fields for this step. The scaffold wraps
/// that output in a [Form] keyed by [formKey], so each step validates
/// independently.
class FormStep {
  final String title;
  final String? subtitle;
  final GlobalKey<FormState> formKey;
  final WidgetBuilder builder;

  FormStep({
    required this.title,
    this.subtitle,
    required this.formKey,
    required this.builder,
  });
}

/// A reusable multi-step ("wizard") form layout with the app's premium dark
/// theme. Shows a segmented progress indicator, one focused group of fields
/// per screen, and a Back / Next (or Submit) bar.
///
/// "Next" validates only the current step before advancing. Submitting
/// validates every step and jumps to the first invalid one.
///
/// All field *values* are expected to live in the parent screen (controllers
/// and state variables), so data is preserved across steps automatically.
class SteppedFormScaffold extends StatefulWidget {
  final String appBarTitle;
  final List<FormStep> steps;
  final String submitLabel;

  /// Called once every step passes validation. The parent performs any
  /// remaining checks (e.g. terms acceptance) and the actual submission.
  final Future<void> Function() onSubmit;

  /// When true the Submit button is disabled and shows a spinner.
  final bool isLoading;

  /// When true (typically edit mode) the progress steps are tappable so the
  /// user can jump straight to a section.
  final bool allowStepJump;

  /// Optional banner shown under the progress bar (e.g. a notice).
  final Widget? banner;

  /// Optional controller to programmatically jump to a step.
  final SteppedFormController? controller;

  /// Optional action widgets for the app bar (e.g. a change-category button).
  final List<Widget>? actions;

  /// Called when the app bar back button is pressed.
  /// Defaults to [Navigator.pop] if not provided.
  final VoidCallback? onBackPressed;

  const SteppedFormScaffold({
    super.key,
    required this.appBarTitle,
    required this.steps,
    required this.onSubmit,
    this.submitLabel = "Submit",
    this.isLoading = false,
    this.allowStepJump = false,
    this.banner,
    this.controller,
    this.actions,
    this.onBackPressed,
  });

  @override
  State<SteppedFormScaffold> createState() => _SteppedFormScaffoldState();
}

class _SteppedFormScaffoldState extends State<SteppedFormScaffold> {
  int _current = 0;

  int get _lastIndex => widget.steps.length - 1;

  void _registerController(SteppedFormController? c) {
    c?._jumpTo = (i) => setState(() => _current = i.clamp(0, _lastIndex));
  }

  @override
  void initState() {
    super.initState();
    _registerController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant SteppedFormScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._jumpTo = null;
      _registerController(widget.controller);
    }
  }

  @override
  void dispose() {
    widget.controller?._jumpTo = null;
    super.dispose();
  }
  bool get _isLastStep => _current == _lastIndex;

  bool _validateStep(int index) =>
      widget.steps[index].formKey.currentState?.validate() ?? true;

  void _showValidationSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all required fields')),
    );
  }

  void _onNext() {
    if (!_validateStep(_current)) {
      _showValidationSnack();
      return;
    }
    if (_isLastStep) {
      _submit();
    } else {
      setState(() => _current++);
    }
  }

  void _onBack() {
    if (_current > 0) setState(() => _current--);
  }

  void _onStepTapped(int target) {
    if (target == _current) return;
    if (target > _current && !_validateStep(_current)) {
      _showValidationSnack();
      return;
    }
    setState(() => _current = target);
  }

  Future<void> _submit() async {
    for (int i = 0; i < widget.steps.length; i++) {
      if (!_validateStep(i)) {
        setState(() => _current = i);
        _showValidationSnack();
        return;
      }
    }
    await widget.onSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];

    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(widget.appBarTitle),
        actions: widget.actions,
        onBackPressed: widget.onBackPressed,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Container(
          child: WebConstrainedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressBar(context),
                if (widget.banner != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: widget.banner!,
                  ),
                _buildStepHeader(context, step),
                Expanded(
                  child: IndexedStack(
                    index: _current,
                    sizing: StackFit.expand,
                    children: [
                      for (final s in widget.steps)
                        Form(
                          key: s.formKey,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            child: s.builder(context),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final children = <Widget>[];
    for (int i = 0; i < widget.steps.length; i++) {
      final bool done = i < _current;
      final bool active = i == _current;
      final bool filled = done || active;

      if (i > 0) {
        children.add(Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i <= _current ? cs.primary : cs.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ));
      }

      children.add(
        GestureDetector(
          onTap: widget.allowStepJump ? () => _onStepTapped(i) : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? cs.primary : Colors.transparent,
              border: Border.all(
                color: filled ? cs.primary : cs.outline,
                width: 2,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.4),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: done
                ? Icon(Icons.check, size: 16, color: cs.onPrimary)
                : Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: active
                          ? cs.onPrimary
                          : cs.onSurface.withOpacity(0.38),
                    ),
                  ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(children: children),
    );
  }

  Widget _buildStepHeader(BuildContext context, FormStep step) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEP ${_current + 1} OF ${widget.steps.length}',
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (step.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              step.subtitle!,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: WebConstrainedBox(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                if (_current > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.isLoading ? null : _onBack,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: cs.onSurface,
                        side: BorderSide(color: cs.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text("Back",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: _PrimaryButton(
                    label: _isLastStep ? widget.submitLabel : "Next",
                    isLastStep: _isLastStep,
                    isLoading: widget.isLoading,
                    onPressed: widget.isLoading ? null : _onNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLastStep;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLastStep,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: isLoading
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cs.primary, cs.primary.withOpacity(0.7)],
              ),
        color: isLoading ? cs.onSurface.withOpacity(0.3) : null,
        boxShadow: isLoading
            ? null
            : [
                BoxShadow(
                  color: cs.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: isLoading
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: cs.onPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text("Submitting...",
                        style: TextStyle(color: cs.onPrimary)),
                  ],
                )
              : Row(
                  key: ValueKey(label),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLastStep ? Icons.check_rounded : Icons.arrow_forward,
                      size: 20,
                      color: cs.onPrimary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
