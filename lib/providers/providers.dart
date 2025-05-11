import 'package:bierwiegen/models/measurement.dart';
import 'package:bierwiegen/models/scale_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_round.dart';
import '../models/player.dart';

class PlayerNotifier extends StateNotifier<List<Player>> {
  PlayerNotifier(this.ref) : super([]);

  final Ref ref;

  void clearPlayers() {
    state = [];
  }

  void addPlayer(Player player) {
    state = [...state, player];
  }

  void resetInitialWeight() {
    final players = state;
    for (final p in players) {
      p.initialWeight.value = 0;
      p.initialWeight.controller.clear();
    }
    state = players;
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, List<Player>>(
  (ref) => PlayerNotifier(ref),
);

class GameRoundNotifier extends StateNotifier<List<GameRound>> {
  GameRoundNotifier(this.ref) : super([]);

  final Ref ref;

  void clearRounds() {
    state = [];
  }

  void addRound(double weight) {
    final r = GameRound(weight, []);
    for (var _ in ref.read(playerProvider)) {
      r.measurements.add(Measurement.empty());
    }

    state = [...state, r];
  }

  void forceRefresh() {
    state = [...state];
  }
}

final gameRoundProvider =
    StateNotifierProvider<GameRoundNotifier, List<GameRound>>(
      (ref) => GameRoundNotifier(ref),
    );

class ScaleStateNotifier extends StateNotifier<ScaleState> {
  ScaleStateNotifier() : super(ScaleState());

  final scanDuration = Duration(seconds: 7);

  void resetConnection() {
    // NOTE: cancel subs and reset weight and streams
    state.cancelSubscriptions();
    state = ScaleState();
  }

  Future<void> tryConnect() async {
    resetConnection();
    state = state.copyWith(connectionState: ScaleConnectionState.connecting);

    try {
      print("Starting scan...");
      await FlutterBluePlus.startScan(timeout: scanDuration);

      Future.delayed(scanDuration, () {
        // NOTE: if we do not have a subscription yet we have to reset the state to disconnected
        if (state.weightSubscription == null) {
          print(
            'setting state to disconnected because no weight sub is available',
          );
          state = state.copyWith(
            connectionState: ScaleConnectionState.disconnected,
          );
        }
      });

      FlutterBluePlus.scanResults.listen((results) {
        for (var r in results) {
          if (r.device.advName == 'Chipsea-BLE') {
            print('found Bluetooth scale');
            _connectScale(r.device);
            break;
          }
        }
      });
    } catch (e) {
      print('Error: $e');
      state = state.copyWith(
        connectionState: ScaleConnectionState.disconnected,
      );
    }
  }

  Future<void> _connectScale(BluetoothDevice device) async {
    final bluetoothConnectionSub = device.connectionState.listen((
      bluetoothConnectionState,
    ) {
      print(bluetoothConnectionState);
      if (bluetoothConnectionState == BluetoothConnectionState.disconnected) {
        if (state.connectionState == ScaleConnectionState.connected) {
          print("Disconnected from Service");
          state = state.copyWith(
            connectionState: ScaleConnectionState.disconnected,
          );
        }
      }

      if (bluetoothConnectionState == BluetoothConnectionState.connected) {
        print("Connected to Service");
        state = state.copyWith(connectionState: ScaleConnectionState.connected);
      }
    });

    state = state.copyWith(connectionSubscription: bluetoothConnectionSub);

    print('Connecting to ${device.platformName}...');
    await device.connect();
    print('Connected to ${device.remoteId}');

    print("Discovering services...");
    final services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        final charUuid =
            characteristic.characteristicUuid.toString().toLowerCase();
        if (charUuid.contains('fff1')) {
          print('Found weight characteristic: ${characteristic.uuid}');
          await characteristic.setNotifyValue(true);

          final weightStreamSub = characteristic.lastValueStream.listen(
            _handleWeightStreamInput,
          );
          state = state.copyWith(weightSubscription: weightStreamSub);
          break;
        }
      }
    }
  }

  void _handleWeightStreamInput(List<int> value) {
    final weight = _decodeWeightFromIntList(value);

    if (state.weight != weight) {
      print("Weight updated: $weight grams");
      state = state.copyWith(weight: weight);
    }
  }

  int _decodeWeightFromIntList(List<int> intList) {
    if (intList.length < 8) {
      print("⚠️ Data length too short to decode weight.");
      return 0;
    }

    // Byte 6 and Byte 5 hold the weight in Little Endian format
    final weight = intList[6] | (intList[5] << 8);

    final isNegative = intList[2] == 0x02;

    return isNegative ? -weight : weight;
  }
}

final scaleStateProvider =
    StateNotifierProvider<ScaleStateNotifier, ScaleState>(
      (ref) => ScaleStateNotifier(),
    );
