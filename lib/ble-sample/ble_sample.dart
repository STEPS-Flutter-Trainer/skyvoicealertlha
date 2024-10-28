
//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
//
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   BluetoothDevice? _targetDevice;
//   final String _targetDeviceId = '2BBED641-D304-0AC3-3B63-48EA0EFB7057';
//   BluetoothCharacteristic? _controlCharacteristic;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   void _startScan() {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//       });
//       print('Scanning started');
//
//       FlutterBluePlus.scanResults.listen((results) {
//         for (ScanResult result in results) {
//           // Check if the device has the target UUID
//           if (result.device.id.toString() == _targetDeviceId) {
//             print('Target device found: ${result.device.name} (${result.device.id})');
//             _targetDevice = result.device;
//             _stopScan();
//             _connectToDevice(_targetDevice!);
//             break;
//           }
//         }
//       });
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//       print('Scanning stopped');
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       print('Connected to device: ${device.name} (${device.id})');
//
//       // Example of interacting with a characteristic
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_controlCharacteristic != null) break;
//       }
//       setState(() {}); // Refresh the UI to show buttons
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 if (_isScanning) {
//                   _stopScan();
//                 } else {
//                   _startScan();
//                 }
//               },
//               child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
//             ),
//             SizedBox(height: 20),
//             Text('Target Device ID: $_targetDeviceId'),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             SizedBox(height: 20),
//             if (_controlCharacteristic != null) ...[
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_ON'),
//                 child: Text('DEVICE_ON'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_OFF'),
//                 child: Text('DEVICE_OFF'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   BluetoothDevice? _targetDevice;
//   final String _targetDeviceId = '2BBED641-D304-0AC3-3B63-48EA0EFB7057'; // Your device ID
//   BluetoothCharacteristic? _controlCharacteristic;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   void _startScan() {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         for (ScanResult result in results) {
//           if (result.device.id.toString() == _targetDeviceId) {
//             _targetDevice = result.device;
//             _stopScan();
//             _connectToDevice(_targetDevice!);
//             break;
//           }
//         }
//       });
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_controlCharacteristic != null) break;
//       }
//       setState(() {}); // Refresh UI
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 _isScanning ? _stopScan() : _startScan();
//               },
//               child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
//             ),
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_ON'),
//                 child: Text('DEVICE_ON'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_OFF'),
//                 child: Text('DEVICE_OFF'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   void _startScan() {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults = results;
//         });
//       });
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_controlCharacteristic != null) break;
//       }
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 _isScanning ? _stopScan() : _startScan();
//               },
//               child: Text(_isScanning ? 'Stop Scan' : 'Start Scan'),
//             ),
//             SizedBox(height: 20),
//             if (_scanResults.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _scanResults.length,
//                   itemBuilder: (context, index) {
//                     final result = _scanResults[index];
//                     return ListTile(
//                       title: Text(result.device.name.isNotEmpty
//                           ? result.device.name
//                           : 'Unknown Device'),
//                       subtitle: Text(result.device.id.toString()),
//                       onTap: () {
//                         _connectToDevice(result.device);
//                         _stopScan();
//                       },
//                     );
//                   },
//                 ),
//               ),
//             SizedBox(height: 20),
//             if (_targetDevice != null) Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_ON'),
//                 child: Text('DEVICE_ON'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_OFF'),
//                 child: Text('DEVICE_OFF'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults = results;
//         });
//       });
//
//       await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_controlCharacteristic != null) break;
//       }
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) ...[
//                 Center(child: CircularProgressIndicator()),
//                 SizedBox(height: 20),
//               ],
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//                   return ListTile(
//                     title: Text(result.device.name.isNotEmpty
//                         ? result.device.name
//                         : 'Unknown Device'),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_ON'),
//                 child: Text('DEVICE_ON'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _sendCommand('DEVICE_OFF'),
//                 child: Text('DEVICE_OFF'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false; // Track the state of the device
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults = results;
//         });
//       });
//
//       await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//         if (_controlCharacteristic != null) break;
//       }
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) ...[
//                // Center(child: CircularProgressIndicator()),
//                 SizedBox(height: 20),
//               ],
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//
//                   // Skip devices without a name
//                   if (result.device.name.isEmpty) {
//                     return SizedBox.shrink(); // Return an empty widget if the device name is empty
//                   }
//
//                   return ListTile(
//                     title: Text(result.device.name),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//                 },
//                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults = results;
//         });
//       });
//
//       await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//
//         // Check for battery level characteristic in Battery Service (UUID 0x180F)
//         if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//
//         if (_controlCharacteristic != null) break;
//       }
//
//       // Request MTU size
//       _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       setState(() {
//         _batteryLevel = value[0]; // Battery level is usually in the first byte
//       });
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) ...[
//                 SizedBox(height: 20),
//               ],
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//
//                   // Skip devices without a name
//                   if (result.device.name.isEmpty) {
//                     return SizedBox.shrink();
//                   }
//
//                   return ListTile(
//                     title: Text(result.device.name),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//                 },
//                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//               ),
//               SizedBox(height: 20),
//               Text('MTU: $_mtu bytes'),
//               if (_batteryLevel != -1)
//                 Text('Battery Level: $_batteryLevel%'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults = results;
//         });
//       });
//
//       await Future.delayed(const Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         // Debugging: Print out each service UUID to check if the Battery Service exists
//         print('Service UUID: ${service.uuid.toString()}');
//
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           // Print each characteristic for debugging
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//
//         // Check for battery level characteristic in Battery Service (UUID 0x180F)
//         if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//           print('Battery Service found');
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               print('Battery Level Characteristic found');
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//
//         if (_controlCharacteristic != null) break;
//       }
//
//       // Request MTU size
//       _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       setState(() {
//         _batteryLevel = value[0]; // Battery level is usually in the first byte
//       });
//       print('Battery level: $_batteryLevel');
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) ...[
//                 SizedBox(height: 20),
//               ],
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//
//                   // Skip devices without a name
//                   if (result.device.name.isEmpty) {
//                     return SizedBox.shrink();
//                   }
//
//                   return ListTile(
//                     title: Text(result.device.name),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//                 },
//                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//               ),
//               SizedBox(height: 20),
//               Text('MTU: $_mtu bytes'),
//               if (_batteryLevel != -1)
//                 Text('Battery Level: $_batteryLevel%'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

//*******************************************
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           // Filter only connected devices, for example, by device name
//           _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//         });
//       });
//
//       await Future.delayed(const Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service i/ import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// //
// // class BluetoothScanScreen extends StatefulWidget {
// //   @override
// //   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// // }
// //
// // class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
// //   bool _isScanning = false;
// //   List<ScanResult> _scanResults = [];
// //   BluetoothDevice? _targetDevice;
// //   BluetoothCharacteristic? _controlCharacteristic;
// //   bool _isDeviceOn = false;
// //   int _mtu = 23; // Default MTU size
// //   int _batteryLevel = -1; // Battery level placeholder
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _startScan();
// //   }
// //
// //   Future<void> _startScan() async {
// //     try {
// //       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
// //       setState(() {
// //         _isScanning = true;
// //         _scanResults.clear(); // Clear previous scan results
// //       });
// //
// //       FlutterBluePlus.scanResults.listen((results) {
// //         setState(() {
// //           // Filter only connected devices, for example, by device name
// //           _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
// //         });
// //       });
// //
// //       await Future.delayed(const Duration(seconds: 10)); // Wait for scan to finish
// //       _stopScan();
// //     } catch (e) {
// //       print('Error starting scan: $e');
// //     }
// //   }
// //
// //   void _stopScan() {
// //     try {
// //       FlutterBluePlus.stopScan();
// //       setState(() {
// //         _isScanning = false;
// //       });
// //     } catch (e) {
// //       print('Error stopping scan: $e');
// //     }
// //   }
// //
// //   void _connectToDevice(BluetoothDevice device) async {
// //     try {
// //       await device.connect();
// //       List<BluetoothService> services = await device.discoverServices();
// //
// //       for (BluetoothService service in services) {
// //         print('Service UUID: ${service.uuid.toString()}');
// //         for (BluetoothCharacteristic characteristic in service.characteristics) {
// //           print('Characteristic UUID: ${characteristic.uuid.toString()}');
// //           // Check if the characteristic has write properties for controlling the device
// //           if (characteristic.properties.write) {
// //             _controlCharacteristic = characteristic;
// //           }
// //           // Check for battery level characteristic in Battery Service (UUID 0x180F)
// //           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
// //             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
// //               _readBatteryLevel(characteristic);
// //             }
// //           }
// //         }
// //       }
// //
// //       // Request MTU size
// //       _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
// //
// //       setState(() {
// //         _targetDevice = device; // Set the connected device
// //       });
// //     } catch (e) {
// //       print('Error connecting to device: $e');
// //     }
// //   }
// //
// //   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
// //     try {
// //       var value = await batteryCharacteristic.read();
// //       setState(() {
// //         _batteryLevel = value[0]; // Battery level is usually in the first byte
// //       });
// //       print('Battery level: $_batteryLevel');
// //     } catch (e) {
// //       print('Error reading battery level: $e');
// //     }
// //   }
// //
// //   void _sendCommand(String command) async {
// //     if (_controlCharacteristic != null) {
// //       try {
// //         await _controlCharacteristic!.write(utf8.encode(command));
// //         print('Command sent: $command');
// //         setState(() {
// //           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
// //         });
// //       } catch (e) {
// //         print('Error sending command: $e');
// //       }
// //     } else {
// //       print('Control characteristic not found or device not connected.');
// //     }
// //   }
// //
// //   Future<void> _refresh() async {
// //     await _startScan();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Bluetooth Communication'),
// //       ),
// //       body: RefreshIndicator(
// //         onRefresh: _refresh,
// //         child: ListView(
// //           children: <Widget>[
// //             if (_scanResults.isNotEmpty) ...[
// //               if (_isScanning) SizedBox(height: 20),
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 itemCount: _scanResults.length,
// //                 itemBuilder: (context, index) {
// //                   final result = _scanResults[index];
// //                   return ListTile(
// //                     title: Text(result.device.name),
// //                     subtitle: Text(result.device.id.toString()),
// //                     onTap: () {
// //                       _connectToDevice(result.device);
// //                       _stopScan();
// //                     },
// //                   );
// //                 },
// //               ),
// //             ] else if (!_isScanning) ...[
// //               Center(child: Text('No devices found')),
// //             ],
// //             SizedBox(height: 20),
// //             if (_targetDevice != null)
// //               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
// //             if (_controlCharacteristic != null) ...[
// //               SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: () {
// //                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
// //                 },
// //                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
// //               ),
// //               SizedBox(height: 20),
// //               Text('MTU: $_mtu bytes'),
// //               if (_batteryLevel != -1) Text('Battery Level: $_batteryLevel%'),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }n services) {
//         print('Service UUID: ${service.uuid.toString()}');
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//           // Check if the characteristic has write properties for controlling the device
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//           }
//           // Check for battery level characteristic in Battery Service (UUID 0x180F)
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//       }
//
//       // Request MTU size
//       _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       setState(() {
//         _batteryLevel = value[0]; // Battery level is usually in the first byte
//       });
//       print('Battery level: $_batteryLevel');
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) SizedBox(height: 20),
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//                   return ListTile(
//                     title: Text(result.device.name),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//                 },
//                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//               ),
//               SizedBox(height: 20),
//               Text('MTU: $_mtu bytes'),
//               if (_batteryLevel != -1) Text('Battery Level: $_batteryLevel%'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//*****************************************************

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() =>
//       _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _connectedDevices = [];
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//
//   @override
//   void initState() {
//     super.initState();
//     _getConnectedDevices();
//   }
//
//   Future<void> _getConnectedDevices() async {
//     try {
//       List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
//       setState(() {
//         _connectedDevices = devices;
//       });
//
//       if (_connectedDevices.isNotEmpty) {
//         // Automatically connect to the first device and discover services
//         _connectToDevice(_connectedDevices[0]);
//       }
//     } catch (e) {
//       print('Error fetching connected devices: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       // Discover services and characteristics on the connected device
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           // Look for the characteristic that supports write
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//             break;
//           }
//         }
//
//         // Check for battery level characteristic in Battery Service (UUID 0x180F)
//         if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//
//         if (_controlCharacteristic != null) break;
//       }
//
//       // Request MTU size
//       _mtu = await device.requestMtu(512);
//
//       setState(() {
//         // Set the connected device and characteristic for write operations
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       setState(() {
//         _batteryLevel = value[0]; // Battery level is usually in the first byte
//       });
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connected Bluetooth Devices'),
//       ),
//       body: _connectedDevices.isNotEmpty
//           ? ListView.builder(
//         itemCount: _connectedDevices.length,
//         itemBuilder: (context, index) {
//           final device = _connectedDevices[index];
//           return ListTile(
//             title: Text(device.name),
//             subtitle: Text(device.id.toString()),
//             trailing: ElevatedButton(
//               onPressed: () {
//                 _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//               },
//               child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//             ),
//           );
//         },
//       )
//           : Center(
//         child: Text('No connected devices found'),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//
//   @override
//   void initState() {
//     super.initState();
//     _startScan();
//   }
//
//   Future<void> _startScan() async {
//     try {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//       setState(() {
//         _isScanning = true;
//         _scanResults.clear(); // Clear previous scan results
//       });
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           // Filter and keep only relevant devices, e.g., by name or UUID
//           _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//         });
//       });
//
//       await Future.delayed(const Duration(seconds: 10)); // Wait for scan to finish
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//       });
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       // Check if device is already connected
//       if (device.state == BluetoothDeviceState.connected) {
//         print('Already connected to ${device.name}');
//         return;
//       }
//
//       // Connect to the device
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         print('Service UUID: ${service.uuid.toString()}');
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//           // Check if the characteristic has write properties for controlling the device
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//           }
//           // Check for battery level characteristic in Battery Service (UUID 0x180F)
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//       }
//
//       // Request MTU size
//       _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
//
//       setState(() {
//         _targetDevice = device; // Set the connected device
//       });
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       setState(() {
//         _batteryLevel = value[0]; // Battery level is usually in the first byte
//       });
//       print('Battery level: $_batteryLevel');
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_scanResults.isNotEmpty) ...[
//               if (_isScanning) SizedBox(height: 20),
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _scanResults.length,
//                 itemBuilder: (context, index) {
//                   final result = _scanResults[index];
//                   return ListTile(
//                     title: Text(result.device.name),
//                     subtitle: Text(result.device.id.toString()),
//                     onTap: () {
//                       _connectToDevice(result.device);
//                       _stopScan();
//                     },
//                   );
//                 },
//               ),
//             ] else if (!_isScanning) ...[
//               Center(child: Text('No devices found')),
//             ],
//             SizedBox(height: 20),
//             if (_targetDevice != null)
//               Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
//             if (_controlCharacteristic != null) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
//                 },
//                 child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
//               ),
//               SizedBox(height: 20),
//               Text('MTU: $_mtu bytes'),
//               if (_batteryLevel != -1) Text('Battery Level: $_batteryLevel%'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _connectedDevices = [];
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _getConnectedDevices();
//   }
//
//   Future<void> _getConnectedDevices() async {
//     try {
//       List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
//       setState(() {
//         _connectedDevices = devices;
//       });
//     } catch (e) {
//       print('Error fetching connected devices: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _getConnectedDevices();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connected Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_connectedDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _connectedDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _connectedDevices[index];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty ? device.name : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     onTap: () {
//                       // Handle device tap if needed
//                     },
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(child: Text('No connected devices found')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _connectedDevices = [];
//   Map<BluetoothDevice, DeviceDetails> _deviceDetails = {};
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _getConnectedDevices();
//   }
//
//   Future<void> _getConnectedDevices() async {
//     try {
//       List<BluetoothDevice> devices = await FlutterBluePlus.bondedDevices;
//       setState(() {
//         _connectedDevices = devices;
//       });
//
//       for (var device in devices) {
//         await _getDeviceDetails(device);
//       }
//     } catch (e) {
//       print('Error fetching connected devices: $e');
//     }
//   }
//
//   Future<void> _getDeviceDetails(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       DeviceDetails details = DeviceDetails();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
//               characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             var value = await characteristic.read();
//             details.batteryLevel = value.isNotEmpty ? value[0] : -1;
//           }
//         }
//       }
//
//       setState(() {
//         _deviceDetails[device] = details;
//       });
//     } catch (e) {
//       print('Error fetching device details: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _getConnectedDevices();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connected Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_connectedDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _connectedDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _connectedDevices[index];
//                   final details = _deviceDetails[device];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty ? device.name : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     trailing: details != null
//                         ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
//                         : null,
//                     onTap: () {
//                       // Handle device tap if needed
//                     },
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(child: Text('No connected devices found')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DeviceDetails {
//   int batteryLevel = -1; // Default battery level placeholder
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _connectedDevices = [];
//   Map<BluetoothDevice, DeviceDetails> _deviceDetails = {};
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scanForDevices();
//   }
//
//   Future<void> _scanForDevices() async {
//     try {
//       if (!_isScanning) {
//         setState(() {
//           _isScanning = true;
//           _connectedDevices.clear(); // Clear previous devices
//         });
//
//         FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//
//         FlutterBluePlus.scanResults.listen((results) {
//           setState(() {
//             _connectedDevices = results.map((result) => result.device).toList();
//           });
//
//           // Optionally, you can fetch device details here if needed
//           // for (var device in _connectedDevices) {
//           //   _getDeviceDetails(device);
//           // }
//         });
//
//         await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//         FlutterBluePlus.stopScan();
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error scanning for devices: $e');
//     }
//   }
//
//   Future<void> _getDeviceDetails(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       DeviceDetails details = DeviceDetails();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
//               characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             var value = await characteristic.read();
//             details.batteryLevel = value.isNotEmpty ? value[0] : -1;
//           }
//         }
//       }
//
//       setState(() {
//         _deviceDetails[device] = details;
//       });
//     } catch (e) {
//       print('Error fetching device details: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _scanForDevices();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connected Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_connectedDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _connectedDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _connectedDevices[index];
//                   final details = _deviceDetails[device];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty ? device.name : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     trailing: details != null
//                         ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
//                         : null,
//                     onTap: () {
//                       _getDeviceDetails(device); // Fetch details on tap if needed
//                     },
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(child: Text('No devices found')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DeviceDetails {
//   int batteryLevel = -1; // Default battery level placeholder
// }
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _filteredDevices = [];
//   Map<BluetoothDevice, DeviceDetails> _deviceDetails = {}; // To store device details
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scanForDevices();
//   }
//
//   Future<void> _scanForDevices() async {
//     try {
//       if (!_isScanning) {
//         setState(() {
//           _isScanning = true;
//           _filteredDevices.clear(); // Clear previous devices
//         });
//
//         FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//
//         FlutterBluePlus.scanResults.listen((results) {
//           setState(() {
//             _filteredDevices = results
//                 .where((result) => result.device.name == "SkyVoice")
//                 .map((result) => result.device)
//                 .toList();
//           });
//         });
//
//         await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//         FlutterBluePlus.stopScan();
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error scanning for devices: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _scanForDevices();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_filteredDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _filteredDevices[index];
//                   final details = _deviceDetails[device];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty
//                         ? device.name
//                         : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     trailing: details != null
//                         ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
//                         : null,
//                     onTap: () {
//                       // Handle device tap if needed
//                       _getDeviceDetails(device);
//                     },
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(
//                   child: Text('No devices found with the name "SkyVoice"')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _getDeviceDetails(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       DeviceDetails details = DeviceDetails();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
//               characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             var value = await characteristic.read();
//             details.batteryLevel = value.isNotEmpty ? value[0] : -1;
//           }
//
//           // Add checks for other characteristics if needed
//         }
//       }
//
//       setState(() {
//         _deviceDetails[device] = details;
//       });
//     } catch (e) {
//       print('Error fetching device details: $e');
//     } finally {
//       // Ensure disconnection even if an error occurs
//       try {
//         await device.disconnect();
//       } catch (e) {
//         print('Error disconnecting from device: $e');
//       }
//     }
//   }
// }
//
// class DeviceDetails {
//   int batteryLevel = -1; // Default battery level placeholder
//   String? firmwareVersion; // Firmware version, default is null
//   String? modelNumber; // Model number, default is null
//   String? serialNumber; // Serial number, default is null
//
//   DeviceDetails({
//     this.batteryLevel = -1,
//     this.firmwareVersion,
//     this.modelNumber,
//     this.serialNumber,
//   });
//
//   @override
//   String toString() {
//     return 'DeviceDetails(batteryLevel: $batteryLevel, firmwareVersion: $firmwareVersion, modelNumber: $modelNumber, serialNumber: $serialNumber)';
//   }
// }
//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _filteredDevices = [];
//   Map<BluetoothDevice, DeviceDetails> _deviceDetails = {}; // To store device details
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scanForDevices();
//   }
//
//   Future<void> _scanForDevices() async {
//     try {
//       if (!_isScanning) {
//         setState(() {
//           _isScanning = true;
//           _filteredDevices.clear(); // Clear previous devices
//         });
//
//         FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//
//         FlutterBluePlus.scanResults.listen((results) {
//           setState(() {
//             _filteredDevices = results
//                 .where((result) => result.device.name == "SkyVoice")
//                 .map((result) => result.device)
//                 .toList();
//           });
//         });
//
//         await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//         FlutterBluePlus.stopScan();
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error scanning for devices: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _scanForDevices();
//   }
//
//   Future<void> _getDeviceDetails(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       DeviceDetails details = DeviceDetails();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
//               characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             var value = await characteristic.read();
//             details.batteryLevel = value.isNotEmpty ? value[0] : -1;
//           }
//
//           // Add checks for other characteristics if needed
//         }
//       }
//
//       setState(() {
//         _deviceDetails[device] = details;
//       });
//     } catch (e) {
//       print('Error fetching device details: $e');
//     } finally {
//       try {
//         await device.disconnect();
//       } catch (e) {
//         print('Error disconnecting from device: $e');
//       }
//     }
//   }
//
//     BluetoothCharacteristic? _controlCharacteristic;
//
//   void _sendCommand(BluetoothDevice device,String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         setState(() {
//           command == 'DEVICE_ON'; // Update the state based on the command
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_filteredDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _filteredDevices[index];
//                   final details = _deviceDetails[device];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty
//                         ? device.name
//                         : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     trailing: details != null
//                         ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
//                         : null,
//                     onTap: () {
//                       // Handle device tap if needed
//                       _getDeviceDetails(device);
//                     },
//                     isThreeLine: true,
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                     leading: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => _sendCommand(device, 'DEVICE_ON'),
//                           child: Text('DEVICE_ON'),
//                         ),
//                         SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: () => _sendCommand(device, 'DEVICE_OFF'),
//                           child: Text('DEVICE_OFF'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(
//                   child: Text('No devices found with the name "SkyVoice"')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DeviceDetails {
//   int batteryLevel = -1; // Default battery level placeholder
//   String? firmwareVersion; // Firmware version, default is null
//   String? modelNumber; // Model number, default is null
//   String? serialNumber; // Serial number, default is null
//
//   DeviceDetails({
//     this.batteryLevel = -1,
//     this.firmwareVersion,
//     this.modelNumber,
//     this.serialNumber,
//   });
//
//   @override
//   String toString() {
//     return 'DeviceDetails(batteryLevel: $batteryLevel, firmwareVersion: $firmwareVersion, modelNumber: $modelNumber, serialNumber: $serialNumber)';
//   }
// }

//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothScanScreen extends StatefulWidget {
//   @override
//   _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
// }
//
// class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
//   List<BluetoothDevice> _filteredDevices = [];
//   Map<BluetoothDevice, DeviceDetails> _deviceDetails = {}; // To store device details
//   bool _isScanning = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _scanForDevices();
//   }
//
//   Future<void> _scanForDevices() async {
//     try {
//       if (!_isScanning) {
//         setState(() {
//           _isScanning = true;
//           _filteredDevices.clear(); // Clear previous devices
//         });
//
//         FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
//
//         FlutterBluePlus.scanResults.listen((results) {
//           setState(() {
//             _filteredDevices = results
//                 .where((result) => result.device.name == "SkyVoice")
//                 .map((result) => result.device)
//                 .toList();
//           });
//         });
//
//         await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
//         FlutterBluePlus.stopScan();
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error scanning for devices: $e');
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _scanForDevices();
//   }
//
//   Future<void> _getDeviceDetails(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       List<BluetoothService> services = await device.discoverServices();
//       DeviceDetails details = DeviceDetails();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
//               characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             var value = await characteristic.read();
//             details.batteryLevel = value.isNotEmpty ? value[0] : -1;
//           }
//
//           // Check for the command characteristic
//           if (service.uuid.toString() == "YOUR_COMMAND_SERVICE_UUID") {
//             if (characteristic.uuid.toString() == "YOUR_COMMAND_CHARACTERISTIC_UUID") {
//               details.controlCharacteristic = characteristic;
//             }
//           }
//         }
//       }
//
//       setState(() {
//         _deviceDetails[device] = details;
//       });
//     } catch (e) {
//       print('Error fetching device details: $e');
//     } finally {
//       try {
//         await device.disconnect();
//       } catch (e) {
//         print('Error disconnecting from device: $e');
//       }
//     }
//   }
//
//   Future<void> _sendCommand(BluetoothDevice device, String command) async {
//     final details = _deviceDetails[device];
//     if (details?.controlCharacteristic != null) {
//       try {
//         await device.connect();
//         await details!.controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//       } catch (e) {
//         print('Error sending command: $e');
//       } finally {
//         try {
//           await device.disconnect();
//         } catch (e) {
//           print('Error disconnecting from device: $e');
//         }
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Filtered Bluetooth Devices'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           children: <Widget>[
//             if (_filteredDevices.isNotEmpty) ...[
//               ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: _filteredDevices.length,
//                 itemBuilder: (context, index) {
//                   final device = _filteredDevices[index];
//                   final details = _deviceDetails[device];
//                   return ListTile(
//                     title: Text(device.name.isNotEmpty
//                         ? device.name
//                         : 'Unnamed Device'),
//                     subtitle: Text(device.id.toString()),
//                     trailing: details != null
//                         ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
//                         : null,
//                     onTap: () {
//                       // Handle device tap if needed
//                       _getDeviceDetails(device);
//                     },
//                     isThreeLine: true,
//                     contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                     leading: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => _sendCommand(device, 'DEVICE_ON'),
//                           child: Text('DEVICE_ON'),
//                         ),
//                         SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: () => _sendCommand(device, 'DEVICE_OFF'),
//                           child: Text('DEVICE_OFF'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ] else ...[
//               Center(
//                   child: Text('No devices found with the name "SkyVoice"')),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class DeviceDetails {
//   int batteryLevel = -1; // Default battery level placeholder
//   String? firmwareVersion; // Firmware version, default is null
//   String? modelNumber; // Model number, default is null
//   String? serialNumber; // Serial number, default is null
//   BluetoothCharacteristic? controlCharacteristic; // Added to store control characteristic
//
//   DeviceDetails({
//     this.batteryLevel = -1,
//     this.firmwareVersion,
//     this.modelNumber,
//     this.serialNumber,
//     this.controlCharacteristic,
//   });
//
//   @override
//   String toString() {
//     return 'DeviceDetails(batteryLevel: $batteryLevel, firmwareVersion: $firmwareVersion, modelNumber: $modelNumber, serialNumber: $serialNumber)';
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScanScreen extends StatefulWidget {
  @override
  _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  List<BluetoothDevice> _filteredDevices = [];
  Map<BluetoothDevice, DeviceDetails> _deviceDetails = {}; // To store device details
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  Future<void> _scanForDevices() async {
    try {
      if (!_isScanning) {
        setState(() {
          _isScanning = true;
          _filteredDevices.clear(); // Clear previous devices
        });

        FlutterBluePlus.startScan(timeout: Duration(seconds: 10));

        FlutterBluePlus.scanResults.listen((results) {
          setState(() {
            _filteredDevices = results
                .where((result) => result.device.name == "SkyVoice")
                .map((result) => result.device)
                .toList();
          });
        });

        await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
        FlutterBluePlus.stopScan();
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      print('Error scanning for devices: $e');
    }
  }

  Future<void> _refresh() async {
    await _scanForDevices();
  }

  Future<void> _getDeviceDetails(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      DeviceDetails details = DeviceDetails();

      print('Discovered services: ${services.map((s) => s.uuid.toString()).toList()}');

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print('Discovered characteristic: ${characteristic.uuid.toString()}');

          if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb" &&
              characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            details.batteryLevel = value.isNotEmpty ? value[0] : -1;
          }

          // Check for the command characteristic
          if (service.uuid.toString() == "YOUR_COMMAND_SERVICE_UUID") {
            if (characteristic.uuid.toString() == "YOUR_COMMAND_CHARACTERISTIC_UUID") {
              details.controlCharacteristic = characteristic;
            }
          }
        }
      }

      setState(() {
        _deviceDetails[device] = details;
      });
    } catch (e) {
      print('Error fetching device details: $e');
    } finally {
      try {
        await device.disconnect();
      } catch (e) {
        print('Error disconnecting from device: $e');
      }
    }
  }

  Future<void> _sendCommand(BluetoothDevice device, String command) async {
    final details = _deviceDetails[device];
    if (details?.controlCharacteristic != null) {
      try {
        await device.connect();
        await details!.controlCharacteristic!.write(utf8.encode(command));
        print('Command sent: $command');
      } catch (e) {
        print('Error sending command: $e');
      } finally {
        try {
         // await device.disconnect();
        } catch (e) {
          print('Error disconnecting from device: $e');
        }
      }
    } else {
      print('Control characteristic not found or device not connected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Bluetooth Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: <Widget>[
            if (_filteredDevices.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredDevices.length,
                itemBuilder: (context, index) {
                  final device = _filteredDevices[index];
                  final details = _deviceDetails[device];
                  return ListTile(
                    title: Text(device.name.isNotEmpty
                        ? device.name
                        : 'Unnamed Device'),
                    subtitle: Text(device.id.toString()),
                    trailing: details != null
                        ? Text('Battery: ${details.batteryLevel}%', style: TextStyle(color: Colors.blue))
                        : null,
                    onTap: () {
                      // Handle device tap if needed
                      _getDeviceDetails(device);
                    },
                    isThreeLine: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _sendCommand(device, 'DEVICE_ON'),
                          child: Text('DEVICE_ON'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _sendCommand(device, 'DEVICE_OFF'),
                          child: Text('DEVICE_OFF'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else ...[
              Center(
                  child: Text('No devices found with the name "SkyVoice"')),
            ],
          ],
        ),
      ),
    );
  }
}

class DeviceDetails {
  int batteryLevel = -1; // Default battery level placeholder
  String? firmwareVersion; // Firmware version, default is null
  String? modelNumber; // Model number, default is null
  String? serialNumber; // Serial number, default is null
  BluetoothCharacteristic? controlCharacteristic; // Added to store control characteristic

  DeviceDetails({
    this.batteryLevel = -1,
    this.firmwareVersion,
    this.modelNumber,
    this.serialNumber,
    this.controlCharacteristic,
  });

  @override
  String toString() {
    return 'DeviceDetails(batteryLevel: $batteryLevel, firmwareVersion: $firmwareVersion, modelNumber: $modelNumber, serialNumber: $serialNumber)';
  }
}
