enum ScaleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,

  /// Connection dropped unexpectedly; automatic retries are running.
  reconnecting,
  notFound,
  error,
}

/// Availability of the phone's Bluetooth adapter, independent of any scale
/// connection.
enum BluetoothAvailability {
  unknown,
  ready,
  off,

  /// The app is not allowed to use Bluetooth (permission missing).
  unauthorized,
}

const Object _unset = Object();

class ScaleState {
  /// Weight in grams as currently reported by the scale.
  final int? liveWeight;

  /// Set once [liveWeight] has been stable for the stability duration;
  /// cleared whenever the weight changes again.
  final int? stableWeight;

  final ScaleConnectionState connectionState;
  final BluetoothAvailability adapter;
  final String? errorMessage;

  const ScaleState({
    this.liveWeight,
    this.stableWeight,
    this.connectionState = ScaleConnectionState.disconnected,
    this.adapter = BluetoothAvailability.unknown,
    this.errorMessage,
  });

  ScaleState copyWith({
    Object? liveWeight = _unset,
    Object? stableWeight = _unset,
    ScaleConnectionState? connectionState,
    BluetoothAvailability? adapter,
    Object? errorMessage = _unset,
  }) {
    return ScaleState(
      liveWeight: liveWeight == _unset ? this.liveWeight : liveWeight as int?,
      stableWeight:
          stableWeight == _unset ? this.stableWeight : stableWeight as int?,
      connectionState: connectionState ?? this.connectionState,
      adapter: adapter ?? this.adapter,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }
}
