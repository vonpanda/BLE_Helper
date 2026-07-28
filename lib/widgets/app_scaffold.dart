import 'package:flutter/material.dart';

/// A reusable Scaffold wrapper with a consistent app bar and optional FAB.
class AppScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppScaffold({
    super.key,
    required this.title,
    this.actions,
    this.body,
    this.floatingActionButton,
    this.bottom,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: theme.textTheme.titleLarge),
        actions: actions,
        bottom: bottom,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed ??
                    () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
              )
            : null,
      ),
      body: SafeArea(
        child: body ?? const SizedBox.shrink(),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
