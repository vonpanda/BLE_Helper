import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/scan/scan_bloc.dart';
import '../../../bloc/scan/scan_state.dart';
import '../../../data/models/scan_filter.dart';
import '../../../core/constants/ui_constants.dart';

/// Dialog for configuring scan filters (name, MAC, RSSI, sort).
class ScanFilterDialog extends StatefulWidget {
  const ScanFilterDialog({super.key});

  @override
  State<ScanFilterDialog> createState() => _ScanFilterDialogState();
}

class _ScanFilterDialogState extends State<ScanFilterDialog> {
  late TextEditingController _nameController;
  late TextEditingController _rssiController;
  late SortBy _sortBy;
  late SortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    final ScanState state = context.read<ScanBloc>().state;
    _nameController =
        TextEditingController(text: state.filter.nameFilter ?? '');
    _rssiController = TextEditingController(
      text: state.filter.rssiMin?.toString() ?? '',
    );
    _sortBy = state.filter.sortBy;
    _sortOrder = state.filter.sortOrder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rssiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Scan Filter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name filter
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'Filter by name...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // RSSI minimum
            TextField(
              controller: _rssiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Min RSSI (dBm)',
                hintText: 'e.g., -80',
                prefixIcon: Icon(Icons.signal_cellular_alt),
              ),
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // Sort by
            Text('Sort by', style: theme.textTheme.titleSmall),
            const SizedBox(height: UiConstants.spacingSm),
            DropdownButtonFormField<SortBy>(
              initialValue: _sortBy,
              items: SortBy.values.map((SortBy s) {
                return DropdownMenuItem<SortBy>(
                  value: s,
                  child: Text(s.name.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (SortBy? value) {
                if (value != null) {
                  setState(() => _sortBy = value);
                }
              },
            ),
            const SizedBox(height: UiConstants.spacingMd),

            // Sort order
            DropdownButtonFormField<SortOrder>(
              initialValue: _sortOrder,
              items: SortOrder.values.map((SortOrder s) {
                return DropdownMenuItem<SortOrder>(
                  value: s,
                  child: Text(s.name),
                );
              }).toList(),
              onChanged: (SortOrder? value) {
                if (value != null) {
                  setState(() => _sortOrder = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Clear all filters
            _nameController.clear();
            _rssiController.clear();
            setState(() {
              _sortBy = SortBy.RSSI;
              _sortOrder = SortOrder.DESC;
            });
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final ScanFilter filter = ScanFilter(
              nameFilter: _nameController.text.trim().nullIfEmpty,
              rssiMin: int.tryParse(_rssiController.text.trim()),
              sortBy: _sortBy,
              sortOrder: _sortOrder,
            );
            Navigator.of(context).pop(filter);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

extension _StringNull on String {
  String? get nullIfEmpty => trim().isEmpty ? null : this;
}
