import 'package:flutter/material.dart';

import '../../../bloc/dfu/dfu_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/ui_constants.dart';

/// DFU progress indicator showing percentage, progress bar, and status.
class DfuProgress extends StatelessWidget {
  final DfuState state;

  const DfuProgress({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UiConstants.spacingLg),
        child: Column(
          children: [
            // Circular progress indicator
            SizedBox(
              width: UiConstants.dfuProgressIndicatorSize,
              height: UiConstants.dfuProgressIndicatorSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: UiConstants.dfuProgressIndicatorSize,
                    height: UiConstants.dfuProgressIndicatorSize,
                    child: CircularProgressIndicator(
                      value: state.isInProgress
                          ? state.progressPercent / 100.0
                          : state.isCompleted
                              ? 1.0
                              : null,
                      strokeWidth: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: state.isCompleted
                          ? AppColors.bleConnected
                          : state.isFailed
                              ? AppColors.error
                              : AppColors.dfuProgress,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isCompleted
                            ? Icons.check_circle
                            : state.isFailed
                                ? Icons.error
                                : Icons.system_update,
                        size: 32,
                        color: state.isCompleted
                            ? AppColors.bleConnected
                            : state.isFailed
                                ? AppColors.error
                                : AppColors.dfuProgress,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.isCompleted
                            ? '100%'
                            : '${state.progressPercent}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // Status text
            Text(
              _statusText,
              style: theme.textTheme.titleSmall?.copyWith(
                color: _statusColor(theme),
              ),
              textAlign: TextAlign.center,
            ),

            if (state.isFailed && state.errorMessage != null) ...[
              const SizedBox(height: UiConstants.spacingSm),
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _statusText {
    switch (state.processState) {
      case DfuProcessState.IN_PROGRESS:
        return 'Uploading firmware...';
      case DfuProcessState.COMPLETED:
        return 'Upgrade completed successfully!';
      case DfuProcessState.FAILED:
        return 'Upgrade failed';
      default:
        return 'Ready';
    }
  }

  Color _statusColor(ThemeData theme) {
    switch (state.processState) {
      case DfuProcessState.COMPLETED:
        return AppColors.bleConnected;
      case DfuProcessState.FAILED:
        return AppColors.error;
      default:
        return theme.colorScheme.onSurface;
    }
  }
}
