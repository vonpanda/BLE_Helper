import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/log/log_bloc.dart';
import '../../../bloc/log/log_event.dart';
import '../../../bloc/log/log_state.dart';
import '../../../data/models/log_entry.dart';
import '../../../data/models/scan_filter.dart';
import '../../../core/constants/ui_constants.dart';

/// Dialog for selecting log export format and options.
class LogExportDialog extends StatefulWidget {
  const LogExportDialog({super.key});

  @override
  State<LogExportDialog> createState() => _LogExportDialogState();
}

class _LogExportDialogState extends State<LogExportDialog> {
  LogExportFormat _format = LogExportFormat.TXT;
  LogEventType? _eventTypeFilter;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocConsumer<LogBloc, LogState>(
      listener: (BuildContext context, LogState state) {
        if (state.exportStatus == LogExportStatus.completed) {
          Navigator.of(context).pop(state);
        } else if (state.exportStatus == LogExportStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export failed')),
          );
        }
      },
      builder: (BuildContext context, LogState state) {
        return AlertDialog(
          title: const Text('Export Logs'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Format', style: theme.textTheme.titleSmall),
                const SizedBox(height: UiConstants.spacingSm),
                SegmentedButton<LogExportFormat>(
                  segments: LogExportFormat.values.map((LogExportFormat f) {
                    return ButtonSegment<LogExportFormat>(
                      value: f,
                      label: Text(f.name),
                    );
                  }).toList(),
                  selected: {_format},
                  onSelectionChanged: (Set<LogExportFormat> selection) {
                    setState(() => _format = selection.first);
                  },
                ),
                const SizedBox(height: UiConstants.spacingMd),
                Text('Filter by type (optional)',
                    style: theme.textTheme.titleSmall),
                const SizedBox(height: UiConstants.spacingSm),
                DropdownButtonFormField<LogEventType?>(
                  initialValue: _eventTypeFilter,
                  items: [
                    const DropdownMenuItem<LogEventType?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...LogEventType.values.map((LogEventType t) {
                      return DropdownMenuItem<LogEventType>(
                        value: t,
                        child: Text(t.name.replaceAll('_', ' ')),
                      );
                    }),
                  ],
                  onChanged: (LogEventType? value) {
                    setState(() => _eventTypeFilter = value);
                  },
                ),
                if (state.exportStatus == LogExportStatus.exporting) ...[
                  const SizedBox(height: UiConstants.spacingMd),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: state.exportStatus != LogExportStatus.exporting
                  ? () => Navigator.of(context).pop()
                  : null,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: state.exportStatus != LogExportStatus.exporting
                  ? () {
                      final LogQuery query = LogQuery(
                        eventType: _eventTypeFilter,
                        sortField: LogSortField.TIMESTAMP,
                        sortOrder: SortOrder.DESC,
                      );
                      context.read<LogBloc>().add(
                            ExportRequested(format: _format, query: query),
                          );
                    }
                  : null,
              child: const Text('Export'),
            ),
          ],
        );
      },
    );
  }
}
