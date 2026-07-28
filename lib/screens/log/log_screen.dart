import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../bloc/log/log_bloc.dart';
import '../../bloc/log/log_event.dart';
import '../../bloc/log/log_state.dart';
import '../../core/di/injection_container.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/log_entry.dart';
import '../../widgets/empty_state.dart';
import 'widgets/log_entry_tile.dart';
import 'widgets/log_export_dialog.dart';

/// Log overview screen with filtering, searching, and export capabilities.
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final LogBloc _logBloc;
  LogEventType? _selectedEventType;

  @override
  void initState() {
    super.initState();
    _logBloc = sl<LogBloc>()..add(const LogsRequested());
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedEventType = null;
            break;
          case 1:
            _selectedEventType = LogEventType.SCAN_DEVICE_FOUND;
            break;
          case 2:
            _selectedEventType = LogEventType.DEVICE_CONNECTED;
            break;
          case 3:
            _selectedEventType = LogEventType.GATT_READ;
            break;
          case 4:
            _selectedEventType = LogEventType.ERROR;
            break;
        }
      });
      _refreshLogs();
    }
  }

  void _refreshLogs() {
    _logBloc.add(
      LogFilterChanged(
        query: LogQuery(eventType: _selectedEventType),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _logBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocProvider<LogBloc>.value(
      value: _logBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear logs',
              onPressed: () => _confirmClear(context),
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Export',
              onPressed: () => _showExportDialog(context),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Scan'),
              Tab(text: 'Connection'),
              Tab(text: 'Data'),
              Tab(text: 'Errors'),
            ],
          ),
        ),
        body: BlocBuilder<LogBloc, LogState>(
          builder: (BuildContext context, LogState state) {
            if (state.entries.isEmpty) {
              return const EmptyState(
                icon: Icons.history,
                title: 'No Logs',
                subtitle: 'BLE activity logs will appear here.',
              );
            }

            return Column(
              children: [
                // Stats bar
                if (state.stats != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConstants.spacingMd,
                      vertical: UiConstants.spacingSm,
                    ),
                    color:
                        theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                    child: Row(
                      children: [
                        Text(
                          '${state.stats!.totalEntries} entries',
                          style: theme.textTheme.labelSmall,
                        ),
                        const Spacer(),
                        if (state.exportStatus == LogExportStatus.exporting)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (state.exportStatus == LogExportStatus.completed)
                          Icon(Icons.check_circle,
                              size: 14, color: theme.colorScheme.primary),
                      ],
                    ),
                  ),

                // Log list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: UiConstants.spacingSm),
                    itemCount: state.entries.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (BuildContext context, int index) {
                      return LogEntryTile(entry: state.entries[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Clear Logs'),
        content: const Text(
            'This will archive and clear all log entries. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logBloc.add(const ClearLogs());
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider<LogBloc>.value(
        value: _logBloc,
        child: const LogExportDialog(),
      ),
    ).then((_) {
      if (!context.mounted) {
        return;
      }
      final LogState state = _logBloc.state;
      if (state.exportStatus == LogExportStatus.completed &&
          state.exportFilePath != null) {
        Share.shareXFiles(
          [XFile(state.exportFilePath!)],
          subject: 'BLE Helper Log Export',
        );
      }
    });
  }
}
