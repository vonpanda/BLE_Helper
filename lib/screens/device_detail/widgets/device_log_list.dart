import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/log/log_bloc.dart';
import '../../../bloc/log/log_event.dart';
import '../../../bloc/log/log_state.dart';
import '../../../data/models/log_entry.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../widgets/empty_state.dart';
import '../../log/widgets/log_entry_tile.dart';

/// A filtered log list showing only entries for a specific device.
class DeviceLogList extends StatefulWidget {
  final String deviceId;

  const DeviceLogList({super.key, required this.deviceId});

  @override
  State<DeviceLogList> createState() => _DeviceLogListState();
}

class _DeviceLogListState extends State<DeviceLogList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogBloc>().add(
            LogFilterChanged(
              query: LogQuery(deviceId: widget.deviceId),
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogBloc, LogState>(
      builder: (BuildContext context, LogState state) {
        if (state.entries.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'No Logs',
            subtitle: 'Log entries for this device will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(UiConstants.spacingSm),
          itemCount: state.entries.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            return LogEntryTile(entry: state.entries[index]);
          },
        );
      },
    );
  }
}
