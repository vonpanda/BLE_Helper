/// Defines how scan results are sorted.
enum SortBy {
  RSSI,
  NAME,
  LAST_SEEN,
}

/// Defines the sort direction.
enum SortOrder {
  ASC,
  DESC,
}

/// Filter criteria for BLE device scanning.
class ScanFilter {
  final String? nameFilter;
  final String? macFilter;
  final int? rssiMin;
  final SortBy sortBy;
  final SortOrder sortOrder;

  const ScanFilter({
    this.nameFilter,
    this.macFilter,
    this.rssiMin,
    this.sortBy = SortBy.RSSI,
    this.sortOrder = SortOrder.DESC,
  });

  ScanFilter copyWith({
    String? nameFilter,
    String? macFilter,
    int? rssiMin,
    SortBy? sortBy,
    SortOrder? sortOrder,
    bool clearNameFilter = false,
    bool clearMacFilter = false,
    bool clearRssiMin = false,
  }) {
    return ScanFilter(
      nameFilter: clearNameFilter ? null : (nameFilter ?? this.nameFilter),
      macFilter: clearMacFilter ? null : (macFilter ?? this.macFilter),
      rssiMin: clearRssiMin ? null : (rssiMin ?? this.rssiMin),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Whether any filter is active.
  bool get isActive =>
      nameFilter != null || macFilter != null || rssiMin != null;

  Map<String, dynamic> toJson() {
    return {
      'nameFilter': nameFilter,
      'macFilter': macFilter,
      'rssiMin': rssiMin,
      'sortBy': sortBy.name,
      'sortOrder': sortOrder.name,
    };
  }

  factory ScanFilter.fromJson(Map<String, dynamic> json) {
    return ScanFilter(
      nameFilter: json['nameFilter'] as String?,
      macFilter: json['macFilter'] as String?,
      rssiMin: json['rssiMin'] as int?,
      sortBy: SortBy.values.firstWhere(
        (e) => e.name == json['sortBy'],
        orElse: () => SortBy.RSSI,
      ),
      sortOrder: SortOrder.values.firstWhere(
        (e) => e.name == json['sortOrder'],
        orElse: () => SortOrder.DESC,
      ),
    );
  }

  @override
  String toString() => 'ScanFilter(name: $nameFilter, rssiMin: $rssiMin)';
}
