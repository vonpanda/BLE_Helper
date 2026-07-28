import 'package:flutter/material.dart';

import '../core/utils/data_formatter.dart';
import '../core/constants/ui_constants.dart';

/// A text input field for entering Hex/ASCII data to send via BLE.
class DataInput extends StatefulWidget {
  final Function(List<int> data)? onSend;
  final String? hintText;
  final bool enabled;
  final double maxHeight;

  const DataInput({
    super.key,
    this.onSend,
    this.hintText,
    this.enabled = true,
    this.maxHeight = 120,
  });

  @override
  State<DataInput> createState() => _DataInputState();
}

class _DataInputState extends State<DataInput> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;

    final List<int>? bytes = DataFormatter.parseHexString(text);
    if (bytes == null) {
      setState(() {
        _errorText =
            'Invalid hex format. Use space-separated hex bytes (e.g., "1A 2B FF")';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    widget.onSend?.call(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Enter hex (e.g., 1A 2B FF)',
                    errorText: _errorText,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(UiConstants.radiusMd),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() => _errorText = null);
                    }
                  },
                ),
              ),
              const SizedBox(width: UiConstants.spacingSm),
              IconButton.filled(
                onPressed: widget.enabled ? _handleSend : null,
                icon: const Icon(Icons.send),
                tooltip: 'Send',
              ),
            ],
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
