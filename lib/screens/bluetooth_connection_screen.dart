// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class BluetoothConnectionScreen extends ConsumerStatefulWidget {
//   const BluetoothConnectionScreen({super.key});
//
//   @override
//   _BluetoothConnectionScreenState createState() =>
//       _BluetoothConnectionScreenState();
// }
//
//
// // NOTE:
// // - when connecting, tell the user if the scale is around
// // - when the scale is connected and the weight service is active show the user that it works (display weith)
// // - i need a controller that has all connections and takes the input and distributes it further
//
// class _BluetoothConnectionScreenState
//     extends ConsumerState<BluetoothConnectionScreen> {
//   final ValueNotifier<int> currentWeight = ValueNotifier<int>(0);
//
//   // NOTE: isConnected should only be true if the scale is connected and the service transfers data
//   bool isConnected = false;
//   bool isLoading = false;
//
//
//
//   StreamSubscription? _connectionSub;
//   StreamSubscription? _weightSub;
//
//   Future<void> scanForScale() async {
//     List<ScanResult> scanResults = [];
//
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       print("🔍 Starting scan...");
//       await FlutterBluePlus.startScan(timeout: Duration(seconds: 5)).then((
//         value,
//       ) {
//         setState(() {
//           isLoading = false;
//         });
//         // if (_connectionSub == null) {}
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         for (var r in results) {
//           if (!scanResults.contains(r)) {
//             scanResults.add(r);
//             if (r.device.advName.trim().isNotEmpty) {
//               print('Found device:');
//               print(r.device.advName);
//             }
//
//             if (r.device.advName == 'Chipsea-BLE') {
//               print('found Bluetooth scale');
//               connectScale(r.device);
//             }
//           }
//         }
//       });
//     } catch (e) {
//       print('❌ Error: $e');
//       setState(() {
//         isConnected = false;
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> connectScale(BluetoothDevice device) async {
//     final bluetoothConnectionSub = device.connectionState.listen((state) {
//       print(state);
//       if (state == BluetoothConnectionState.disconnected) {
//         print("Disconnected from Service");
//         setState(() {
//           isConnected = false;
//         });
//       }
//
//       if (state == BluetoothConnectionState.connected) {
//         print("Connected to Service");
//         setState(() {
//           isConnected = true;
//         });
//       }
//     });
//
//     _connectionSub = bluetoothConnectionSub;
//
//     print('🔗 Connecting to ${device.platformName}...');
//     await device.connect();
//     print('✅ Connected to ${device.remoteId}');
//
//     print("🛠 Discovering services...");
//     final services = await device.discoverServices();
//
//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         final charUuid =
//             characteristic.characteristicUuid.toString().toLowerCase();
//         if (charUuid.contains('fff1')) {
//           print('✅ Found weight characteristic: ${characteristic.uuid}');
//           await characteristic.setNotifyValue(true);
//
//           final weightStreamSub = characteristic.lastValueStream.listen(
//             handleWeightStreamInput,
//           );
//           _weightSub = weightStreamSub;
//         }
//       }
//     }
//   }
//
//   void handleWeightStreamInput(List<int> value) {
//     final weight = decodeWeightFromIntList(value);
//
//     if (currentWeight.value != weight) {
//       currentWeight.value = weight;
//       print("⚖️ Weight updated: $weight grams");
//     }
//   }
//
//   int decodeWeightFromIntList(List<int> intList) {
//     if (intList.length < 8) {
//       print("⚠️ Data length too short to decode weight.");
//       return 0;
//     }
//
//     // Byte 6 and Byte 5 hold the weight in Little Endian format
//     final weight = intList[6] | (intList[5] << 8);
//
//     final isNegative = intList[2] == 0x02;
//
//     return isNegative ? -weight : weight;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Bluetooth Scale'), centerTitle: true),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               ElevatedButton(
//                 // onPressed: connectAndSubscribe,
//                 onPressed: scanForScale,
//                 child: Text(
//                   'Connect and Subscribe' +
//                       '${isLoading ? " ... in Progress" : ''}',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (isConnected)
//                 ValueListenableBuilder<int>(
//                   valueListenable: currentWeight,
//                   builder: (context, weight, child) {
//                     return Text(
//                       "Current Weight: $weight",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
