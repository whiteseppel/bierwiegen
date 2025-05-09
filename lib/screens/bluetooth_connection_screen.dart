import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BluetoothConnectionScreen extends ConsumerStatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  _BluetoothConnectionScreenState createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState
    extends ConsumerState<BluetoothConnectionScreen> {
  List<ScanResult> scanResults = [];
  BluetoothDevice? targetDevice;
  DeviceIdentifier _id = DeviceIdentifier('DC:23:51:A5:79:74');

  BluetoothDevice? selectedDevice;
  List<BluetoothService> services = [];
  BluetoothCharacteristic? notifyCharacteristic;

  String log = '';

  void logMessage(String message) {
    print(message);
    setState(() {
      log += '$message\n';
    });
  }

  void startScan() async {
    logMessage('Starting scan...');
    scanResults.clear();
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (!scanResults.contains(r)) {
          scanResults.add(r);
          if (r.device.name.toLowerCase().contains('renpho')) {
            logMessage('Found device: ${r.device.name} (${r.device.id})');
          }
        }
      }
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    logMessage('Scan stopped.');
  }

  void showScanResults() {
    for (final r in scanResults) {
      if (r.device.advName.trim().isNotEmpty) {}
      logMessage(r.device.advName);
      logMessage(r.device.platformName);
    }
  }

  void resetLog() {
    setState(() {
      log = '';
    });
  }

  void connectToDevice() async {
    var device =
        scanResults
            .firstWhere(
              (r) => r.device.remoteId == _id,
              orElse: () => throw Exception('Renpho device not found'),
            )
            .device;

    logMessage('Connecting to ${device.name}...');
    await device.connect();
    targetDevice = device;
    logMessage('Connected to ${device.id}');
  }

  void discoverServices() async {
    if (targetDevice == null) return;

    logMessage('Discovering services...');
    services = await targetDevice!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.uuid.toString().toLowerCase().contains('2b10')) {
          notifyCharacteristic = characteristic;
          logMessage(
            'Found weight measurement characteristic: ${characteristic.uuid}',
          );
        }
      }
    }

    if (notifyCharacteristic == null) {
      logMessage('Weight measurement characteristic not found.');
    }
  }

  void subscribeToNotifications() async {
    if (notifyCharacteristic == null) return;

    await notifyCharacteristic!.setNotifyValue(true);

    notifyCharacteristic!.value.listen((value) {
      final hex = value
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('-');
      print(hex);
      logMessage('Notification: $hex');
    });

    logMessage('Subscribed to notifications.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text('bluetooth screen'),
              ElevatedButton(onPressed: resetLog, child: Text('Reset Log')),
              ElevatedButton(onPressed: startScan, child: Text('Start Scan')),
              ElevatedButton(onPressed: stopScan, child: Text('Stop Scan')),
              DropdownButton<BluetoothDevice>(
                hint: Text('Select a device'),
                value: selectedDevice,
                onChanged: (BluetoothDevice? newDevice) {
                  setState(() {
                    selectedDevice = newDevice;
                  });
                },
                items:
                    scanResults
                        .where((r) => r.device.name.isNotEmpty)
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.device,
                            child: Text('${r.device.name} (${r.device.id})'),
                          ),
                        )
                        .toList(),
              ),
              ElevatedButton(
                onPressed: showScanResults,
                child: Text('Show Results'),
              ),
              ElevatedButton(
                onPressed: connectToDevice,
                child: Text('Connect'),
              ),
              ElevatedButton(
                onPressed: discoverServices,
                child: Text('Discover Services'),
              ),
              ElevatedButton(
                onPressed: subscribeToNotifications,
                child: Text('Subscribe to UUID 0x2B10'),
              ),
              SizedBox(height: 20),
              Text('Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: SingleChildScrollView(child: Text(log))),
            ],
          ),
        ),
      ),
    );
  }
}
