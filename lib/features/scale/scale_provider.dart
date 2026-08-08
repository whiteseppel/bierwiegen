import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'scale_state.dart';

class ScaleNotifier extends StateNotifier<ScaleState> {
  ScaleNotifier() : super(const ScaleState()) {
    _watchAdapterState();
    refreshAvailability();
  }

  static const _deviceName = 'Chipsea-BLE';
  static const _weightCharacteristicId = 'fff1';
  static const _scanDuration = Duration(seconds: 7);
  static const _stabilityDuration = Duration(seconds: 2);
  static const _connectTimeout = Duration(seconds: 10);

  /// Back-off in seconds between reconnect attempts; the last entry repeats
  /// until [_maxReconnectAttempts] is reached (long enough to survive the
  /// scale's auto-sleep being switched back on).
  static const _reconnectDelays = [1, 2, 5, 10, 20, 30];
  static const _maxReconnectAttempts = 12;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _weightSubscription;
  StreamSubscription? _adapterSubscription;
  Timer? _stabilityTimer;
  List<int>? _lastLoggedFrame;
  final _seenDeviceIds = <String>{};
  BluetoothDevice? _knownDevice;
  bool _reconnecting = false;

  BluetoothAdapterState _rawAdapter = BluetoothAdapterState.unknown;
  bool _permissionDenied = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void _log(String message) => print('[scale] $message');

  void _watchAdapterState() {
    try {
      _rawAdapter = FlutterBluePlus.adapterStateNow;
      _updateAvailability();
      _adapterSubscription = FlutterBluePlus.adapterState.listen((btState) {
        _rawAdapter = btState;
        _updateAvailability();
      });
    } catch (e) {
      _log('adapter state unavailable: $e');
    }
  }

  /// Combines the hardware adapter state with the runtime permission: a missing
  /// Bluetooth permission masks the adapter as unauthorized.
  void _updateAvailability() {
    final availability =
        _permissionDenied
            ? BluetoothAvailability.unauthorized
            : _mapAdapterState(_rawAdapter);
    if (availability != state.adapter) {
      state = state.copyWith(adapter: availability);
    }
  }

  BluetoothAvailability _mapAdapterState(BluetoothAdapterState btState) {
    switch (btState) {
      case BluetoothAdapterState.on:
        return BluetoothAvailability.ready;
      case BluetoothAdapterState.unauthorized:
        return BluetoothAvailability.unauthorized;
      case BluetoothAdapterState.off:
      case BluetoothAdapterState.turningOff:
      case BluetoothAdapterState.turningOn:
      case BluetoothAdapterState.unavailable:
        return BluetoothAvailability.off;
      case BluetoothAdapterState.unknown:
        return BluetoothAvailability.unknown;
    }
  }

  /// Re-checks whether the Bluetooth runtime permission is granted. On iOS the
  /// adapter state already reports [BluetoothAdapterState.unauthorized], so this
  /// only matters on Android, where a missing permission is otherwise invisible.
  Future<void> refreshAvailability() async {
    if (!_isAndroid) {
      return;
    }
    try {
      final scan = await Permission.bluetoothScan.status;
      final connect = await Permission.bluetoothConnect.status;
      _permissionDenied = !(scan.isGranted && connect.isGranted);
    } catch (e) {
      _log('permission check failed: $e');
      _permissionDenied = false;
    }
    _updateAvailability();
  }

  /// Requests the Bluetooth permission; on success starts connecting, and opens
  /// the app settings when the user has permanently denied it.
  Future<void> requestBluetoothAccess() async {
    if (!_isAndroid) {
      await tryConnect();
      return;
    }

    final statuses =
        await [Permission.bluetoothScan, Permission.bluetoothConnect].request();
    final granted = statuses.values.every((s) => s.isGranted);
    _permissionDenied = !granted;
    _updateAvailability();

    if (granted) {
      await tryConnect();
    } else if (statuses.values.any((s) => s.isPermanentlyDenied)) {
      await openAppSettings();
    }
  }

  void resetConnection() {
    _cancelSubscriptions();
    // Keep the adapter availability; only the scale connection is reset.
    state = ScaleState(adapter: state.adapter);
  }

  /// Asks the OS to enable Bluetooth (Android only; a no-op elsewhere).
  Future<void> enableBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      _log('turn on bluetooth failed: $e');
    }
  }

  Future<void> tryConnect() async {
    resetConnection();
    // Keep the console readable: FBP logs every notification at debug level.
    FlutterBluePlus.setLogLevel(LogLevel.warning, color: false);

    final known = _knownDevice;
    if (known != null) {
      _log('direct connection to known scale ${known.remoteId} ...');
      state = state.copyWith(connectionState: ScaleConnectionState.connecting);
      try {
        await _establishConnection(known);
        return;
      } catch (e) {
        _log('direct connection failed ($e), falling back to scan');
      }
    }

    await _scanAndConnect();
  }

  Future<void> _scanAndConnect() async {
    _log('scanning for $_deviceName ...');
    state = state.copyWith(connectionState: ScaleConnectionState.scanning);

    try {
      _seenDeviceIds.clear();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (_seenDeviceIds.add(result.device.remoteId.str)) {
            final adv = result.advertisementData;
            _log(
              'seen: advName="${result.device.advName}" '
              'platformName="${result.device.platformName}" '
              'id=${result.device.remoteId} rssi=${result.rssi} '
              'connectable=${adv.connectable} '
              'services=${adv.serviceUuids} '
              'mfgIds=${adv.manufacturerData.keys.toList()}',
            );
          }

          if (result.device.advName == _deviceName) {
            _log('found ${result.device.advName} (${result.device.remoteId})');
            _scanSubscription?.cancel();
            _scanSubscription = null;
            FlutterBluePlus.stopScan();
            _connectAfterScan(result.device);
            break;
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: _scanDuration);

      Future.delayed(_scanDuration, () {
        if (mounted && state.connectionState == ScaleConnectionState.scanning) {
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

  Future<void> _connectAfterScan(BluetoothDevice device) async {
    state = state.copyWith(connectionState: ScaleConnectionState.connecting);
    try {
      await _establishConnection(device);
    } catch (e) {
      _log('connect failed: $e');
      state = state.copyWith(
        connectionState: ScaleConnectionState.error,
        errorMessage: _errorText(e),
      );
    }
  }

  /// Connects, discovers services and subscribes to the weight stream;
  /// throws when any step fails.
  Future<void> _establishConnection(BluetoothDevice device) async {
    _connectionSubscription?.cancel();
    _weightSubscription?.cancel();
    _weightSubscription = null;

    _connectionSubscription = device.connectionState.listen((btState) {
      _log('bluetooth connection state: $btState');
      if (btState == BluetoothConnectionState.disconnected &&
          state.connectionState == ScaleConnectionState.connected) {
        _log('connection lost');
        _reconnectLoop();
      }

      if (btState == BluetoothConnectionState.connected) {
        state = state.copyWith(connectionState: ScaleConnectionState.connected);
      }
    });

    await device.connect(timeout: _connectTimeout);

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
          _knownDevice = device;
          return;
        }
      }
    }

    _log(
      'no weight characteristic found; services: '
      '${[for (final s in services) s.serviceUuid].join(', ')}',
    );
    throw StateError('Die Waage sendet keine Gewichtsdaten');
  }

  Future<void> _reconnectLoop() async {
    final device = _knownDevice;
    if (_reconnecting || device == null) {
      return;
    }
    _reconnecting = true;
    state = state.copyWith(
      connectionState: ScaleConnectionState.reconnecting,
      liveWeight: null,
      stableWeight: null,
    );

    try {
      for (int attempt = 0; attempt < _maxReconnectAttempts; attempt++) {
        final delay =
            _reconnectDelays[min(attempt, _reconnectDelays.length - 1)];
        await Future.delayed(Duration(seconds: delay));
        // Stop when the user reset or started a manual connect meanwhile.
        if (!mounted ||
            state.connectionState != ScaleConnectionState.reconnecting) {
          return;
        }

        _log('reconnect attempt ${attempt + 1} ...');
        try {
          await _establishConnection(device);
          _log('reconnected');
          return;
        } catch (e) {
          _log('reconnect attempt failed: $e');
        }
      }

      if (mounted &&
          state.connectionState == ScaleConnectionState.reconnecting) {
        _log('giving up reconnecting');
        state = state.copyWith(
          connectionState: ScaleConnectionState.disconnected,
        );
      }
    } finally {
      _reconnecting = false;
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
        List.generate(
          value.length,
          (i) => i,
        ).every((i) => _lastLoggedFrame![i] == value[i])) {
      return;
    }

    _lastLoggedFrame = [...value];
    final hex = value.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    _log('frame $hex -> ${_decodeWeightFromIntList(value)} g');
  }

  int _decodeWeightFromIntList(List<int> intList) {
    if (intList.length < 8) {
      return 0;
    }

    // Bytes 5 (high) and 6 (low) hold the weight in grams, big-endian.
    final weight = intList[6] | (intList[5] << 8);

    final isNegative = intList[2] == 0x02;

    return isNegative ? -weight : weight;
  }

  String _errorText(Object e) => e is StateError ? e.message : e.toString();

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
    _adapterSubscription?.cancel();
    super.dispose();
  }
}

final scaleProvider = StateNotifierProvider<ScaleNotifier, ScaleState>(
  (ref) => ScaleNotifier(),
);
