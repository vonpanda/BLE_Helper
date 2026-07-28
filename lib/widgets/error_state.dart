import 'package:flutter/material.dart';

import '../core/constants/ui_constants.dart';

/// A reusable error-state placeholder with error message and retry action.
class ErrorState extends StatelessWidget {
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: UiConstants.iconXl,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: UiConstants.spacingMd),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (retryLabel != null && onRetry != null) ...[
              const SizedBox(height: UiConstants.spacingLg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
