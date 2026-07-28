import 'package:flutter_test/flutter_test.dart';

import 'package:ble_helper/data/models/scan_filter.dart';

void main() {
  group('ScanFilter', () {
    group('Constructor & Defaults', () {
      test('should create with all fields', () {
        const filter = ScanFilter(
          nameFilter: 'Device',
          macFilter: 'AA:BB',
          rssiMin: -70,
          sortBy: SortBy.NAME,
          sortOrder: SortOrder.ASC,
        );
        expect(filter.nameFilter, 'Device');
        expect(filter.macFilter, 'AA:BB');
        expect(filter.rssiMin, -70);
        expect(filter.sortBy, SortBy.NAME);
        expect(filter.sortOrder, SortOrder.ASC);
      });

      test('should have correct defaults', () {
        const filter = ScanFilter();
        expect(filter.nameFilter, isNull);
        expect(filter.macFilter, isNull);
        expect(filter.rssiMin, isNull);
        expect(filter.sortBy, SortBy.RSSI);
        expect(filter.sortOrder, SortOrder.DESC);
      });
    });

    group('isActive', () {
      test('should be false with default filter', () {
        const filter = ScanFilter();
        expect(filter.isActive, false);
      });

      test('should be true when nameFilter is set', () {
        const filter = ScanFilter(nameFilter: 'Test');
        expect(filter.isActive, true);
      });

      test('should be true when macFilter is set', () {
        const filter = ScanFilter(macFilter: 'AA:BB');
        expect(filter.isActive, true);
      });

      test('should be true when rssiMin is set', () {
        const filter = ScanFilter(rssiMin: -80);
        expect(filter.isActive, true);
      });

      test('should be true when multiple filters are set', () {
        const filter = ScanFilter(
          nameFilter: 'Test',
          rssiMin: -70,
        );
        expect(filter.isActive, true);
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        const filter = ScanFilter(nameFilter: 'Test');
        final copied = filter.copyWith(rssiMin: -60, sortBy: SortBy.LAST_SEEN);
        expect(copied.nameFilter, 'Test');
        expect(copied.rssiMin, -60);
        expect(copied.sortBy, SortBy.LAST_SEEN);
        expect(copied.sortOrder, SortOrder.DESC); // unchanged
      });

      test('should clear nameFilter with clearNameFilter flag', () {
        const filter = ScanFilter(nameFilter: 'Test');
        final cleared = filter.copyWith(clearNameFilter: true);
        expect(cleared.nameFilter, isNull);
        expect(cleared.isActive, false);
      });

      test('should clear macFilter with clearMacFilter flag', () {
        const filter = ScanFilter(macFilter: 'AA:BB');
        final cleared = filter.copyWith(clearMacFilter: true);
        expect(cleared.macFilter, isNull);
      });

      test('should clear rssiMin with clearRssiMin flag', () {
        const filter = ScanFilter(rssiMin: -50);
        final cleared = filter.copyWith(clearRssiMin: true);
        expect(cleared.rssiMin, isNull);
      });

      test('should copy with no changes', () {
        const filter = ScanFilter(
          nameFilter: 'Test',
          rssiMin: -70,
          sortBy: SortBy.NAME,
          sortOrder: SortOrder.ASC,
        );
        final copied = filter.copyWith();
        expect(copied.nameFilter, filter.nameFilter);
        expect(copied.rssiMin, filter.rssiMin);
        expect(copied.sortBy, filter.sortBy);
        expect(copied.sortOrder, filter.sortOrder);
      });
    });

    group('toJson / fromJson', () {
      test('should perform roundtrip', () {
        const filter = ScanFilter(
          nameFilter: 'Device',
          macFilter: 'AA:BB',
          rssiMin: -60,
          sortBy: SortBy.NAME,
          sortOrder: SortOrder.ASC,
        );
        final json = filter.toJson();
        expect(json['nameFilter'], 'Device');
        expect(json['sortBy'], 'NAME');
        expect(json['sortOrder'], 'ASC');

        final restored = ScanFilter.fromJson(json);
        expect(restored.nameFilter, filter.nameFilter);
        expect(restored.macFilter, filter.macFilter);
        expect(restored.rssiMin, filter.rssiMin);
        expect(restored.sortBy, filter.sortBy);
        expect(restored.sortOrder, filter.sortOrder);
      });

      test('should handle unknown sortBy with orElse default', () {
        final json = {
          'nameFilter': null,
          'macFilter': null,
          'rssiMin': null,
          'sortBy': 'UNKNOWN',
          'sortOrder': 'ASC',
        };
        final parsed = ScanFilter.fromJson(json);
        expect(parsed.sortBy, SortBy.RSSI); // orElse default
        expect(parsed.sortOrder, SortOrder.ASC);
      });

      test('should handle null optional fields', () {
        final json = {
          'nameFilter': null,
          'macFilter': null,
          'rssiMin': null,
          'sortBy': 'RSSI',
          'sortOrder': 'DESC',
        };
        final parsed = ScanFilter.fromJson(json);
        expect(parsed.nameFilter, isNull);
        expect(parsed.rssiMin, isNull);
      });
    });
  });

  group('SortBy enum', () {
    test('should have three values', () {
      expect(SortBy.values.length, 3);
      expect(SortBy.values, [SortBy.RSSI, SortBy.NAME, SortBy.LAST_SEEN]);
    });
  });

  group('SortOrder enum', () {
    test('should have two values', () {
      expect(SortOrder.values.length, 2);
      expect(SortOrder.values, [SortOrder.ASC, SortOrder.DESC]);
    });
  });
}
