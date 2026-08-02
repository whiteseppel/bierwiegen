import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scale_state.dart';

class ScaleNotifier extends StateNotifier<ScaleState> {
  ScaleNotifier() : super(const ScaleState());

  static const _deviceName = 'Chipsea-BLE';
  static const _weightCharacteristicId = 'fff1';
  static const _scanDuration = Duration(seconds: 7);
  static const _stabilityDuration = Duration(seconds: 2);

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _weightSubscription;
  Timer? _stabilityTimer;
  List<int>? _lastLoggedFrame;

  void _log(String message) => print('[scale] $message');

  void resetConnection() {
    _cancelSubscriptions();
    state = const ScaleState();
  }

  Future<void> tryConnect() async {
    resetConnection();
    _log('scanning for $_deviceName ...');
    state = state.copyWith(connectionState: ScaleConnectionState.scanning);

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (result.device.advName == _deviceName) {
            _log('found ${result.device.advName} (${result.device.remoteId})');
            _scanSubscription?.cancel();
            _scanSubscription = null;
            _connectScale(result.device);
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: _scanDuration);

      Future.delayed(_scanDuration, () {
        if (state.connectionState == ScaleConnectionState.scanning) {
          _log('scan finished: no scale found');
          state = state.copyWith(
            connectionState: ScaleConnectionState.notFound,
          );
        }
      });
    } catch (e) {
      _log('scan failed: $e');
      state = state.copyWith(
        connectionState: ScaleConnectionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _connectScale(BluetoothDevice device) async {
    state = state.copyWith(connectionState: ScaleConnectionState.connecting);

    try {
      _connectionSubscription = device.connectionState.listen((
        bluetoothConnectionState,
      ) {
        _log('bluetooth connection state: $bluetoothConnectionState');
        if (bluetoothConnectionState == BluetoothConnectionState.disconnected &&
            state.connectionState == ScaleConnectionState.connected) {
          state = state.copyWith(
            connectionState: ScaleConnectionState.disconnected,
          );
        }

        if (bluetoothConnectionState == BluetoothConnectionState.connected) {
          state = state.copyWith(
            connectionState: ScaleConnectionState.connected,
          );
        }
      });

      await device.connect();

      final services = await device.discoverServices();
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          final charUuid =
              characteristic.characteristicUuid.toString().toLowerCase();
          if (charUuid.contains(_weightCharacteristicId)) {
            _log('subscribing to weight characteristic $charUuid');
            await characteristic.setNotifyValue(true);
            _weightSubscription = characteristic.lastValueStream.listen(
              _handleWeightStreamInput,
            );
            return;
          }
        }
      }

      _log('no weight characteristic found; services: '
          '${[for (final s in services) s.serviceUuid].join(', ')}');
      state = state.copyWith(
        connectionState: ScaleConnectionState.error,
        errorMessage: 'Die Waage sendet keine Gewichtsdaten',
      );
    } catch (e) {
      _log('connect failed: $e');
      state = state.copyWith(
        connectionState: ScaleConnectionState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _handleWeightStreamInput(List<int> value) {
    _logFrame(value);

    final weight = _decodeWeightFromIntList(value);
    if (weight == state.liveWeight) {
      return;
    }

    state = state.copyWith(liveWeight: weight, stableWeight: null);

    _stabilityTimer?.cancel();
    if (weight == 0) {
      return;
    }

    _stabilityTimer = Timer(_stabilityDuration, () {
      _log('weight stable: ${state.liveWeight} g');
      state = state.copyWith(stableWeight: state.liveWeight);
    });
  }

  /// Raw frames arrive many times per second, mostly identical — only changes
  /// are logged (same dedup as tools/scale_probe.py).
  void _logFrame(List<int> value) {
    if (_lastLoggedFrame != null &&
        _lastLoggedFrame!.length == value.length &&
        List.generate(value.length, (i) => i)
            .every((i) => _lastLoggedFrame![i] == value[i])) {
      return;
    }

    _lastLoggedFrame = [...value];
    final hex =
        value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _log('frame $hex -> ${_decodeWeightFromIntList(value)} g');
  }

  int _decodeWeightFromIntList(List<int> intList) {
    if (intList.length < 8) {
      return 0;
    }

    // Byte 6 and Byte 5 hold the weight in Little Endian format
    final weight = intList[6] | (intList[5] << 8);

    final isNegative = intList[2] == 0x02;

    return isNegative ? -weight : weight;
  }

  void _cancelSubscriptions() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _weightSubscription?.cancel();
    _weightSubscription = null;
    _stabilityTimer?.cancel();
    _stabilityTimer = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

final scaleProvider = StateNotifierProvider<ScaleNotifier, ScaleState>(
  (ref) => ScaleNotifier(),
);
