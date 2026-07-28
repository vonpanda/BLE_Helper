import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/connection_params.dart';

void main() {
  group('ConnectionParams', () {
    group('Constructor & Defaults', () {
      test('should have correct default values', () {
        const params = ConnectionParams();
        expect(params.mtu, 23);
        expect(params.intervalMs, 50);
        expect(params.latency, 0);
        expect(params.supervisionTimeoutMs, 5000);
      });

      test('should create with custom values', () {
        const params = ConnectionParams(
          mtu: 512,
          intervalMs: 30,
          latency: 10,
          supervisionTimeoutMs: 10000,
        );
        expect(params.mtu, 512);
        expect(params.intervalMs, 30);
        expect(params.latency, 10);
        expect(params.supervisionTimeoutMs, 10000);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const params = ConnectionParams();
        final copied = params.copyWith(mtu: 185, intervalMs: 15);
        expect(copied.mtu, 185);
        expect(copied.intervalMs, 15);
        expect(copied.latency, 0); // unchanged
        expect(copied.supervisionTimeoutMs, 5000); // unchanged
      });

      test('should copy with no changes', () {
        const params = ConnectionParams(mtu: 100, intervalMs: 20, latency: 5);
        final copied = params.copyWith();
        expect(copied.mtu, 100);
        expect(copied.intervalMs, 20);
        expect(copied.latency, 5);
      });
    });

    group('toJson / fromJson', () {
      test('should perform roundtrip', () {
        const params = ConnectionParams(
          mtu: 247,
          intervalMs: 45,
          latency: 3,
          supervisionTimeoutMs: 8000,
        );
        final json = params.toJson();
        expect(json['mtu'], 247);
        expect(json['intervalMs'], 45);
        expect(json['latency'], 3);
        expect(json['supervisionTimeoutMs'], 8000);

        final restored = ConnectionParams.fromJson(json);
        expect(restored.mtu, params.mtu);
        expect(restored.intervalMs, params.intervalMs);
        expect(restored.latency, params.latency);
        expect(restored.supervisionTimeoutMs, params.supervisionTimeoutMs);
      });

      test('should handle missing fields with defaults', () {
        final restored = ConnectionParams.fromJson({});
        expect(restored.mtu, 23);
        expect(restored.intervalMs, 50);
        expect(restored.latency, 0);
        expect(restored.supervisionTimeoutMs, 5000);
      });

      test('should handle null values with defaults', () {
        final json = {
          'mtu': null,
          'intervalMs': null,
          'latency': null,
          'supervisionTimeoutMs': null,
        };
        final restored = ConnectionParams.fromJson(json);
        expect(restored.mtu, 23);
        expect(restored.intervalMs, 50);
        expect(restored.latency, 0);
        expect(restored.supervisionTimeoutMs, 5000);
      });
    });
  });
}
