import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState renders title, subtitle, and action',
      (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.bluetooth_searching,
            title: 'No devices found',
            subtitle: 'Start a scan to discover BLE devices.',
            actionLabel: 'Scan',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('No devices found'), findsOneWidget);
    expect(find.text('Start a scan to discover BLE devices.'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
