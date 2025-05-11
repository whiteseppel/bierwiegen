import 'dart:async';

enum ScaleConnectionState { disconnected, connecting, connected }

class ScaleState {
  final int? weight;
  final ScaleConnectionState connectionState;
  final String? errorMessage;
  final StreamSubscription? weightSubscription;
  final StreamSubscription? connectionSubscription;

  ScaleState({
    this.weight,
    this.connectionState = ScaleConnectionState.disconnected,
    this.errorMessage,
    this.weightSubscription,
    this.connectionSubscription,
  });

  ScaleState copyWith({
    int? weight,
    ScaleConnectionState? connectionState,
    String? errorMessage,
    StreamSubscription<dynamic>? weightSubscription,
    StreamSubscription<dynamic>? connectionSubscription,
  }) {
    return ScaleState(
      weight: weight ?? this.weight,
      connectionState: connectionState ?? this.connectionState,
      errorMessage: errorMessage ?? this.errorMessage,
      weightSubscription: weightSubscription ?? this.weightSubscription,
      connectionSubscription:
          connectionSubscription ?? this.connectionSubscription,
    );
  }

  void cancelSubscriptions() {
    weightSubscription?.cancel();
    connectionSubscription?.cancel();
  }
}
