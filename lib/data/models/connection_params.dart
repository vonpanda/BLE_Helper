/// Connection parameters negotiated/requested for a BLE connection.
class ConnectionParams {
  final int mtu;
  final int intervalMs;
  final int latency;
  final int supervisionTimeoutMs;

  const ConnectionParams({
    this.mtu = 23,
    this.intervalMs = 50,
    this.latency = 0,
    this.supervisionTimeoutMs = 5000,
  });

  ConnectionParams copyWith({
    int? mtu,
    int? intervalMs,
    int? latency,
    int? supervisionTimeoutMs,
  }) {
    return ConnectionParams(
      mtu: mtu ?? this.mtu,
      intervalMs: intervalMs ?? this.intervalMs,
      latency: latency ?? this.latency,
      supervisionTimeoutMs: supervisionTimeoutMs ?? this.supervisionTimeoutMs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mtu': mtu,
      'intervalMs': intervalMs,
      'latency': latency,
      'supervisionTimeoutMs': supervisionTimeoutMs,
    };
  }

  factory ConnectionParams.fromJson(Map<String, dynamic> json) {
    return ConnectionParams(
      mtu: json['mtu'] as int? ?? 23,
      intervalMs: json['intervalMs'] as int? ?? 50,
      latency: json['latency'] as int? ?? 0,
      supervisionTimeoutMs: json['supervisionTimeoutMs'] as int? ?? 5000,
    );
  }

  @override
  String toString() => 'ConnectionParams(mtu: $mtu, interval: ${intervalMs}ms)';
}
