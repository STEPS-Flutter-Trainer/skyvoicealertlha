//*************************************************************************************

// import 'dart:convert';
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
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//   Timer? _keepAliveTimer;
//   bool _isAlreadyConnected = false; // Flag to track if already connected
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfDeviceIsConnected();
//     _startScan();
//   }
//
//   @override
//   void dispose() {
//     _keepAliveTimer?.cancel(); // Stop the keep-alive timer when the screen is disposed
//     super.dispose();
//   }
//
//   Future<void> _checkIfDeviceIsConnected() async {
//     // Check if any Bluetooth devices are currently connected
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     // Check if our target device ('SkyVoice') is already connected
//     for (var device in connectedDevices) {
//       if (device.name == "SkyVoice") {
//         print('Already connected to SkyVoice');
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//         _connectToDevice(device); // Reconnect to the device and load its services
//         break;
//       }
//     }
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
//       // Connect to the device only if not already connected
//       if (_isAlreadyConnected) {
//         print('Device is already connected');
//         _discoverServices(device); // Directly discover services for an already connected device
//       } else {
//         await device.connect(autoConnect: false);
//         _discoverServices(device); // Discover services after connection
//       }
//
//       setState(() {
//         _targetDevice = device;
//         _isAlreadyConnected = true; // Mark the device as connected
//       });
//
//       // Monitor device connection and handle disconnection
//       _monitorDeviceConnection(device);
//
//       // Start keep-alive communication
//       _keepAliveConnection(_controlCharacteristic);
//
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _discoverServices(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         print('Service UUID: ${service.uuid.toString()}');
//         print('Characteristic UUID: ${characteristic.uuid.toString()}');
//
//         // Check if the characteristic has write properties for controlling the device
//         if (characteristic.properties.write) {
//           _controlCharacteristic = characteristic;
//         }
//
//         // Check for battery level characteristic in Battery Service (UUID 0x180F)
//         if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//           if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//             // _readBatteryLevel(characteristic);
//           }
//         }
//       }
//     }
//
//     // Request MTU size
//     _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
//
//     setState(() {
//       _targetDevice = device; // Set the connected device
//     });
//   }
//
//   // void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//   //   try {
//   //     var value = await batteryCharacteristic.read();
//   //     setState(() {
//   //       _batteryLevel = value[0]; // Battery level is usually in the first byte
//   //     });
//   //     print('Battery level: $_batteryLevel');
//   //   } catch (e) {
//   //     print('Error reading battery level: $e');
//   //   }
//   // }
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
//   void _monitorDeviceConnection(BluetoothDevice device) {
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.disconnected) {
//         print('Device disconnected, attempting to reconnect...');
//         _connectToDevice(device); // Reconnect when disconnected
//       }
//     });
//   }
//
//   void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
//     if (characteristic != null) {
//       _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
//         try {
//           await characteristic.read();
//           print('Sent keep-alive signal');
//         } catch (e) {
//           print('Failed to send keep-alive signal: $e');
//           timer.cancel();
//         }
//       });
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
//             if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
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
//             ] else if (!_isScanning && !_isAlreadyConnected) ...[
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
// ****************************************************************************************
//
// import 'dart:convert';
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
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//   Timer? _keepAliveTimer;
//   bool _isAlreadyConnected = false; // Flag to track if already connected
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfDeviceIsConnected();
//     _startScan();
//   }
//
//   @override
//   void dispose() {
//     _keepAliveTimer?.cancel(); // Stop the keep-alive timer when the screen is disposed
//     super.dispose();
//   }
//
//   Future<void> _checkIfDeviceIsConnected() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     for (var device in connectedDevices) {
//       if (device.name == "SkyVoice") {
//         print('Already connected to SkyVoice');
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//         _connectToDevice(device); // Reconnect to the device and load its services
//         break;
//       }
//     }
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
//           _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//         });
//       });
//
//       await Future.delayed(const Duration(seconds: 10));
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
//       if (_isAlreadyConnected) {
//         print('Device is already connected');
//         _discoverServices(device);
//       } else {
//         await device.connect(autoConnect: false);
//         _discoverServices(device);
//       }
//
//       setState(() {
//         _targetDevice = device;
//         _isAlreadyConnected = true;
//       });
//
//       _monitorDeviceConnection(device);
//       _keepAliveConnection(_controlCharacteristic);
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _discoverServices(BluetoothDevice device) async {
//     try {
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print('Service UUID: ${service.uuid.toString()}');
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//           }
//
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//       }
//
//       _mtu = await device.requestMtu(512);
//
//       setState(() {
//         _targetDevice = device;
//       });
//     } catch (e) {
//       print('Error discovering services: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       if (value.isNotEmpty) {
//         setState(() {
//           _batteryLevel = value[0]; // Battery level is usually in the first byte
//         });
//         print('Battery level: $_batteryLevel');
//       } else {
//         print('Battery level characteristic read returned empty value');
//       }
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
//           _isDeviceOn = command == 'DEVICE_ON';
//         });
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   void _monitorDeviceConnection(BluetoothDevice device) {
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.disconnected) {
//         print('Device disconnected, attempting to reconnect...');
//         _connectToDevice(device);
//       }
//     });
//   }
//
//   void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
//     if (characteristic != null) {
//       _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
//         try {
//           await characteristic.read();
//           print('Sent keep-alive signal');
//         } catch (e) {
//           print('Failed to send keep-alive signal: $e');
//           timer.cancel();
//         }
//       });
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
//             if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
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
//             ] else if (!_isScanning && !_isAlreadyConnected) ...[
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

//************************************************************************
// import 'dart:convert';
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
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   // int? _mtu; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//   Timer? _keepAliveTimer;
//   bool _isAlreadyConnected = false; // Flag to track if already connected
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfDeviceIsConnected();
//     _startScan();
//   }
//
//   @override
//   void dispose() {
//     _keepAliveTimer?.cancel(); // Stop the keep-alive timer when the screen is disposed
//     super.dispose();
//   }
//
//   Future<void> _checkIfDeviceIsConnected() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     for (var device in connectedDevices) {
//       if (device.name == "SkyVoice") {
//         print('Already connected to SkyVoice');
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//         _connectToDevice(device); // Reconnect to the device and load its services
//         break;
//       }
//     }
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
//         if (mounted) {
//           setState(() {
//             _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//           });
//         }
//       });
//
//       await Future.delayed(const Duration(seconds: 10));
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       if (mounted) {
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       if (_isAlreadyConnected) {
//         print('Device is already connected');
//         _discoverServices(device);
//       } else {
//         await device.connect(autoConnect: false);
//         _discoverServices(device);
//       }
//
//       if (mounted) {
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//       }
//
//       _monitorDeviceConnection(device);
//       _keepAliveConnection(_controlCharacteristic);
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _discoverServices(BluetoothDevice device) async {
//     try {
//       // Discover services on the device
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print('Service UUID: ${service.uuid.toString()}');
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//           }
//
//           // Check if this is the Battery Service and Battery Level characteristic
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               // Read battery level characteristic
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//       }
//
//       if (mounted) {
//         setState(() {
//           _targetDevice = device;
//         });
//       }
//     } catch (e) {
//       print('Error discovering services: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       // Read the battery level characteristic
//       var value = await batteryCharacteristic.read();
//       if (value.isNotEmpty) {
//         int batteryLevel = value[0]; // Battery level is usually in the first byte
//         if (mounted) {
//           setState(() {
//             _batteryLevel = batteryLevel;
//           });
//         }
//         print('Battery level: $_batteryLevel%');
//       } else {
//         print('Battery level characteristic read returned empty value');
//       }
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
//         if (mounted) {
//           setState(() {
//             _isDeviceOn = command == 'DEVICE_ON';
//           });
//         }
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   void _monitorDeviceConnection(BluetoothDevice device) {
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.disconnected) {
//         print('Device disconnected, attempting to reconnect...');
//         _connectToDevice(device);
//       }
//     });
//   }
//
//   void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
//     if (characteristic != null) {
//       _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
//         try {
//           await characteristic.read();
//           print('Sent keep-alive signal');
//         } catch (e) {
//           print('Failed to send keep-alive signal: $e');
//           timer.cancel();
//         }
//       });
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
//             if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
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
//             ] else if (!_isScanning && !_isAlreadyConnected) ...[
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
//               // Text('MTU: $_mtu bytes'),
//               if (_batteryLevel != -1) Text('Battery Level: $_batteryLevel%'),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//*********************************************************************************

// import 'dart:convert';
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
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int? _mtu;
//   int _batteryLevel = -1; // Battery level placeholder
//   Timer? _keepAliveTimer;
//   bool _isAlreadyConnected = false; // Flag to track if already connected
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfDeviceIsConnected();
//     _startScan();
//   }
//
//   @override
//   void dispose() {
//     _keepAliveTimer?.cancel(); // Stop the keep-alive timer when the screen is disposed
//     super.dispose();
//   }
//
//   Future<void> _checkIfDeviceIsConnected() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     for (var device in connectedDevices) {
//       if (device.name == "SkyVoice") {
//         print('Already connected to SkyVoice');
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//         _connectToDevice(device); // Reconnect to the device and load its services
//         break;
//       }
//     }
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
//         if (mounted) {
//           setState(() {
//             _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//           });
//         }
//       });
//
//       await Future.delayed(const Duration(seconds: 10));
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       if (mounted) {
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       if (_isAlreadyConnected) {
//         print('Device is already connected');
//         _discoverServices(device);
//       } else {
//         await device.connect(autoConnect: false);
//
//         // Request MTU Size
//         device.requestMtu(512).then((mtu) {
//           setState(() {
//             _mtu = mtu;
//           });
//           print('Requested MTU Size: $_mtu');
//         }).catchError((e) {
//           print('Error requesting MTU Size: $e');
//         });
//
//         _discoverServices(device);
//       }
//
//       if (mounted) {
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//       }
//
//       _monitorDeviceConnection(device);
//       _keepAliveConnection(_controlCharacteristic);
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   void _discoverServices(BluetoothDevice device) async {
//     try {
//       // Discover services on the device
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print('Service UUID: ${service.uuid.toString()}');
//           print('Characteristic UUID: ${characteristic.uuid.toString()}');
//
//           if (characteristic.properties.write) {
//             _controlCharacteristic = characteristic;
//           }
//
//           // Check if this is the Battery Service and Battery Level characteristic
//           if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//             if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//               // Read battery level characteristic
//               _readBatteryLevel(characteristic);
//             }
//           }
//         }
//       }
//
//       if (mounted) {
//         setState(() {
//           _targetDevice = device;
//         });
//       }
//     } catch (e) {
//       print('Error discovering services: $e');
//     }
//   }
//
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       if (value.isNotEmpty) {
//         int batteryLevel = value[0]; // Battery level is usually in the first byte
//         if (mounted) {
//           setState(() {
//             _batteryLevel = batteryLevel;
//           });
//         }
//         print('Battery level: $_batteryLevel%');
//       } else {
//         print('Battery level characteristic read returned empty value');
//       }
//     } catch (e) {
//       print('Error reading battery level: $e');
//     }
//   }
//
//
//   void _sendCommand(String command) async {
//     if (_controlCharacteristic != null) {
//       try {
//         await _controlCharacteristic!.write(utf8.encode(command));
//         print('Command sent: $command');
//         if (mounted) {
//           setState(() {
//             _isDeviceOn = command == 'DEVICE_ON';
//           });
//         }
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   void _monitorDeviceConnection(BluetoothDevice device) {
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.disconnected) {
//         print('Device disconnected, attempting to reconnect...');
//         _connectToDevice(device);
//       }
//     });
//   }
//
//   void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
//     if (characteristic != null) {
//       _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
//         try {
//           await characteristic.read();
//           print('Sent keep-alive signal');
//         } catch (e) {
//           print('Failed to send keep-alive signal: $e');
//           timer.cancel();
//         }
//       });
//     }
//   }
//
//   Future<void> _refresh() async {
//     await _startScan();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth Communication'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: ListView(
//           padding: EdgeInsets.all(16.0),
//           children: <Widget>[
//             if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
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
//             ] else if (!_isScanning && !_isAlreadyConnected) ...[
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
//               SizedBox(height: 20),
//               if (_batteryLevel != -1) ...[
//                 Text('Battery Level: $_batteryLevel%'),
//               ] else ...[
//                 Text('Battery Level: Unknown'),
//               ],
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
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
//   bool _isScanning = false;
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _targetDevice;
//   BluetoothCharacteristic? _controlCharacteristic;
//   bool _isDeviceOn = false;
//   int _mtu = 23; // Default MTU size
//   int _batteryLevel = -1; // Battery level placeholder
//   Timer? _keepAliveTimer;
//   bool _isAlreadyConnected = false; // Flag to track if already connected
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfDeviceIsConnected();
//     _startScan();
//   }
//
//   @override
//   void dispose() {
//     _keepAliveTimer?.cancel(); // Stop the keep-alive timer when the screen is disposed
//     super.dispose();
//   }
//
//   Future<void> _checkIfDeviceIsConnected() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     for (var device in connectedDevices) {
//       if (device.name == "SkyVoice") {
//         print('Already connected to SkyVoice');
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//         _connectToDevice(device); // Reconnect to the device and load its services
//         break;
//       }
//     }
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
//         if (mounted) {
//           setState(() {
//             _scanResults = results.where((result) => result.device.name == "SkyVoice").toList();
//           });
//         }
//       });
//
//       await Future.delayed(const Duration(seconds: 10));
//       _stopScan();
//     } catch (e) {
//       print('Error starting scan: $e');
//     }
//   }
//
//   void _stopScan() {
//     try {
//       FlutterBluePlus.stopScan();
//       if (mounted) {
//         setState(() {
//           _isScanning = false;
//         });
//       }
//     } catch (e) {
//       print('Error stopping scan: $e');
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       if (_isAlreadyConnected) {
//         print('Device is already connected');
//         _discoverServices(device);
//       } else {
//         await device.connect(autoConnect: false);
//         _discoverServices(device);
//       }
//
//       if (mounted) {
//         setState(() {
//           _targetDevice = device;
//           _isAlreadyConnected = true;
//         });
//       }
//
//       _monitorDeviceConnection(device);
//       _keepAliveConnection(_controlCharacteristic);
//     } catch (e) {
//       print('Error connecting to device: $e');
//     }
//   }
//
//   // void _discoverServices(BluetoothDevice device) async {
//   //   try {
//   //     List<BluetoothService> services = await device.discoverServices();
//   //     print('Services discovered:');
//   //     for (BluetoothService service in services) {
//   //       print('Service UUID: ${service.uuid.toString()}');
//   //       for (BluetoothCharacteristic characteristic in service.characteristics) {
//   //         print('Characteristic UUID: ${characteristic.uuid.toString()}');
//   //
//   //         // Check for Battery Level characteristic
//   //         if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
//   //           print('Battery Level characteristic found');
//   //           _controlCharacteristic = characteristic; // Assign control characteristic
//   //           _readBatteryLevel(characteristic);
//   //         }
//   //
//   //         // Check if this is the Control Characteristic
//   //         if (characteristic.properties.write) {
//   //           _controlCharacteristic = characteristic;
//   //         }
//   //       }
//   //     }
//   //
//   //     if (mounted) {
//   //       setState(() {
//   //         _targetDevice = device;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('Error discovering services: $e');
//   //   }
//   // }
//   void _discoverServices(BluetoothDevice device) async {
//     try {
//       List<BluetoothService> services = await device.discoverServices();
//
//       for
//     (BluetoothService service in services) {
//     for (BluetoothCharacteristic characteristic in service.characteristics) {
//     if (characteristic.uuid.toString()
//     == "00002a19-0000-1000-8000-00805f9b34fb") {
//     // Found the standard Battery Level characteristic
//     _controlCharacteristic = characteristic;
//     _readBatteryLevel(characteristic);
//     } else if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
//     // Found the Battery Service
//     for (BluetoothCharacteristic characteristic in service.characteristics) {
//     if (characteristic.properties.read) {
//     // Found a characteristic with the read property
//     _controlCharacteristic = characteristic;
//     _readBatteryLevel(characteristic);
//     break;
//     }
//     }
//     }
//     }
//     }
//     } catch (e) {
//     print('Error discovering services: $e');
//     }
//   }
//
//   // void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//   //   try {
//   //     var value = await batteryCharacteristic.read();
//   //     print('Battery level read value: $value');
//   //     if (value.isNotEmpty) {
//   //       int batteryLevel = value[0];
//   //       setState(() {
//   //         _batteryLevel = batteryLevel;
//   //       });
//   //       print('Battery level: $_batteryLevel%');
//   //     } else {
//   //       print('Battery level characteristic read returned empty value');
//   //     }
//   //   } catch (e) {
//   //     print('Error reading battery level: $e');
//   //   }
//   // }
//   void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
//     try {
//       var value = await batteryCharacteristic.read();
//       if (value.isNotEmpty) {
//         // Extract the battery level value (adjust byte offset as needed)
//         int batteryLevel = value[0];
//         setState(() {
//           _batteryLevel = batteryLevel;
//         });
//         print('Battery level: $_batteryLevel%');
//       } else {
//         print('Battery level characteristic read returned empty value');
//       }
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
//         if (mounted) {
//           setState(() {
//             _isDeviceOn = command == 'DEVICE_ON';
//           });
//         }
//       } catch (e) {
//         print('Error sending command: $e');
//       }
//     } else {
//       print('Control characteristic not found or device not connected.');
//     }
//   }
//
//   void _monitorDeviceConnection(BluetoothDevice device) {
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.disconnected) {
//         print('Device disconnected, attempting to reconnect...');
//         _connectToDevice(device);
//       }
//     });
//   }
//
//   void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
//     if (characteristic != null) {
//       _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
//         try {
//           await characteristic.read();
//           print('Sent keep-alive signal');
//         } catch (e) {
//           print('Failed to send keep-alive signal: $e');
//           timer.cancel();
//         }
//       });
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
//             if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
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
//             ] else if (!_isScanning && !_isAlreadyConnected) ...[
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

// ************************************************************************
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothBatteryLevelScreen extends StatefulWidget {
//   const BluetoothBatteryLevelScreen({super.key});
//
//   @override
//   State<BluetoothBatteryLevelScreen> createState() =>
//       _BluetoothBatteryLevelScreenState();
// }
//
// class _BluetoothBatteryLevelScreenState
//     extends State<BluetoothBatteryLevelScreen> {
//   // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? batteryCharacteristic;
//   int batteryLevel = -1; // To store battery level
//
//   List<BluetoothDevice> devicesList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     startScan();
//   }
//
//   void startScan() {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//
//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (!devicesList.contains(result.device) && result.device.name.isNotEmpty) {
//           setState(() {
//             devicesList.add(result.device);
//           });
//         }
//       }
//     });
//
//     FlutterBluePlus.stopScan();
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     setState(() {
//       connectedDevice = device;
//     });
//
//     await device.connect();
//     print("Connected to ${device.name}");
//
//     // Discover services
//     List<BluetoothService> services = await device.discoverServices();
//
//     // Find the battery service (UUID 0x180F) and characteristic (UUID 0x2A19)
//     for (var service in services) {
//       for (var characteristic in service.characteristics) {
//         if (characteristic.uuid == Guid("00002a19-0000-1000-8000-00805f9b34fb")) {
//           batteryCharacteristic = characteristic;
//           await readBatteryLevel();
//           break;
//         }
//       }
//     }
//   }
//
//   Future<void> readBatteryLevel() async {
//     if (batteryCharacteristic != null) {
//       var value = await batteryCharacteristic!.read();
//       setState(() {
//         batteryLevel = value.first; // Battery level is typically a single byte
//       });
//       print("Battery Level: $batteryLevel%");
//     }
//   }
//
//   Widget buildDeviceList() {
//     return ListView.builder(
//       itemCount: devicesList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(devicesList[index].name.isNotEmpty
//               ? devicesList[index].name
//               : "Unknown Device"),
//           subtitle: Text(devicesList[index].id.toString()),
//           onTap: () {
//             connectToDevice(devicesList[index]);
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("BLE Get Data"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? buildDeviceList()
//                 : Center(
//               child: Text(
//                 batteryLevel >= 0
//                     ? "Battery Level: $batteryLevel%"
//                     : "Reading Battery Level...",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           if (connectedDevice != null)
//             ElevatedButton(
//               child: Text('Disconnect'),
//               onPressed: () async {
//                 await connectedDevice!.disconnect();
//                 setState(() {
//                   connectedDevice = null;
//                   batteryLevel = -1;
//                 });
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// *************************************************************

//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothBatteryLevelScreen extends StatefulWidget {
//   const BluetoothBatteryLevelScreen({super.key});
//
//   @override
//   State<BluetoothBatteryLevelScreen> createState() =>
//       _BluetoothBatteryLevelScreenState();
// }
//
// class _BluetoothBatteryLevelScreenState
//     extends State<BluetoothBatteryLevelScreen> {
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? batteryCharacteristic;
//   int batteryLevel = -1; // To store battery level
//
//   @override
//   void initState() {
//     super.initState();
//     // Automatically connect to the device when this screen is shown
//     _connectToPreviouslyConnectedDevice();
//   }
//
//   Future<void> _connectToPreviouslyConnectedDevice() async {
//     // Get the list of bonded devices (or you can use any logic to find a device)
//     List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
//
//     // Check if there are any connected devices
//     if (devices.isNotEmpty) {
//       connectedDevice = devices.first; // Select the first connected device
//       await _discoverServicesAndReadBatteryLevel();
//     }
//   }
//
//   Future<void> _discoverServicesAndReadBatteryLevel() async {
//     if (connectedDevice != null) {
//       print("Connected to ${connectedDevice!.name}");
//
//       // Discover services
//       List<BluetoothService> services = await connectedDevice!.discoverServices();
//
//       // Find the battery service (UUID 0x180F) and characteristic (UUID 0x2A19)
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid == Guid("00002a19-0000-1000-8000-00805f9b34fb")) {
//             batteryCharacteristic = characteristic;
//             await readBatteryLevel();
//             return; // Exit after reading battery level
//           }
//         }
//       }
//     }
//   }
//
//   Future<void> readBatteryLevel() async {
//     if (batteryCharacteristic != null) {
//       var value = await batteryCharacteristic!.read();
//       setState(() {
//         batteryLevel = value.first; // Battery level is typically a single byte
//       });
//       print("Battery Level: $batteryLevel%");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("BLE Get Data"),
//       ),
//       body: Center(
//         child: batteryLevel >= 0
//             ? Text(
//           "Battery Level: $batteryLevel%",
//           style: const TextStyle(fontSize: 24),
//         )
//             : const Text(
//           "Reading Battery Level...",
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//       floatingActionButton: connectedDevice != null
//           ? FloatingActionButton(
//         child: const Icon(Icons.bluetooth_disabled_outlined),
//         onPressed: () async {
//           await connectedDevice!.disconnect();
//           setState(() {
//             connectedDevice = null;
//             batteryLevel = -1;
//           });
//         },
//       )
//           : null,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothBatteryLevelScreen extends StatefulWidget {
//   const BluetoothBatteryLevelScreen({super.key});
//
//   @override
//   State<BluetoothBatteryLevelScreen> createState() =>
//       _BluetoothBatteryLevelScreenState();
// }
//
// class _BluetoothBatteryLevelScreenState
//     extends State<BluetoothBatteryLevelScreen> {
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? batteryCharacteristic;
//   int batteryLevel = -1; // To store battery level
//
//   // Define constants for device commands
//   static const List<int> DEVICE_ON = [1];  // Command to turn the device on
//   static const List<int> DEVICE_OFF = [0]; // Command to turn the device off
//
//   @override
//   void initState() {
//     super.initState();
//     // Automatically connect to the previously connected device
//     _connectToPreviouslyConnectedDevice();
//   }
//
//   Future<void> _connectToPreviouslyConnectedDevice() async {
//     // Get the list of currently connected devices
//     List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
//
//     // Check if there are any connected devices
//     if (devices.isNotEmpty) {
//       connectedDevice = devices.first; // Select the first connected device
//       await _discoverServicesAndReadBatteryLevel();
//     } else {
//       print("No connected devices found.");
//     }
//   }
//
//   Future<void> _discoverServicesAndReadBatteryLevel() async {
//     if (connectedDevice != null) {
//       print("Connected to ${connectedDevice!.name}");
//
//       // Discover services
//       List<BluetoothService> services = await connectedDevice!.discoverServices();
//
//       // Find the battery service (UUID 0x180F) and characteristic (UUID 0x2A19)
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid == Guid("00002a19-0000-1000-8000-00805f9b34fb")) {
//             batteryCharacteristic = characteristic;
//             await readBatteryLevel();
//             return; // Exit after reading battery level
//           }
//         }
//       }
//     }
//   }
//
//   Future<void> readBatteryLevel() async {
//     if (batteryCharacteristic != null) {
//       var value = await batteryCharacteristic!.read();
//       setState(() {
//         batteryLevel = value.first; // Battery level is typically a single byte
//       });
//       print("Battery Level: $batteryLevel%");
//     }
//   }
//
//   Future<void> turnDeviceOn() async {
//     if (batteryCharacteristic != null) {
//       try {
//         await batteryCharacteristic!.write(DEVICE_ON);
//         print("Device turned on.");
//       } catch (e) {
//         print("Error turning device on: $e");
//       }
//     }
//   }
//
//   Future<void> turnDeviceOff() async {
//     if (batteryCharacteristic != null) {
//       try {
//         await batteryCharacteristic!.write(DEVICE_OFF);
//         print("Device turned off.");
//       } catch (e) {
//         print("Error turning device off: $e");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("BLE Get Data"),
//       ),
//       body: Center(
//         child: connectedDevice != null
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Connected Device: ${connectedDevice!.name}",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               batteryLevel >= 0
//                   ? "Battery Level: $batteryLevel%"
//                   : "Reading Battery Level...",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: turnDeviceOn,
//               child: const Text("Turn On"),
//             ),
//             ElevatedButton(
//               onPressed: turnDeviceOff,
//               child: const Text("Turn Off"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               child: const Text('Disconnect'),
//               onPressed: () async {
//                 await connectedDevice!.disconnect();
//                 setState(() {
//                   connectedDevice = null;
//                   batteryLevel = -1;
//                 });
//               },
//             ),
//           ],
//         )
//             : const Text(
//           "No connected device found.",
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothBatteryLevelScreen extends StatefulWidget {
//   const BluetoothBatteryLevelScreen({super.key});
//
//   @override
//   State<BluetoothBatteryLevelScreen> createState() =>
//       _BluetoothBatteryLevelScreenState();
// }
//
// class _BluetoothBatteryLevelScreenState
//     extends State<BluetoothBatteryLevelScreen> {
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? batteryCharacteristic;
//   int batteryLevel = -1; // To store battery level
//
//   // Define constants for device commands
//   static const List<int> DEVICE_ON = [1];
//   static const List<int> DEVICE_OFF = [0];
//
//   @override
//   void initState() {
//     super.initState();
//     // Automatically connect to the previously connected device
//     _connectToPreviouslyConnectedDevice();
//   }
//
//   Future<void> _connectToPreviouslyConnectedDevice() async {
//     // Get the list of currently connected devices
//     List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
//
//     // Check if there are any connected devices
//     if (devices.isNotEmpty) {
//       connectedDevice = devices.first; // Select the first connected device
//       await _discoverServicesAndReadBatteryLevel();
//     } else {
//       print("No connected devices found.");
//     }
//   }
//
//   Future<void> _discoverServicesAndReadBatteryLevel() async {
//     if (connectedDevice != null) {
//       print("Connected to ${connectedDevice!.name}");
//
//       // Discover services
//       List<BluetoothService> services = await connectedDevice!.discoverServices();
//
//       // Find the battery service (UUID 0x180F) and characteristic (UUID 0x2A19)
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.uuid == Guid("00002a19-0000-1000-8000-00805f9b34fb")) {
//             batteryCharacteristic = characteristic;
//             // await readBatteryLevel();
//             return; // Exit after reading battery level
//           }
//         }
//       }
//     }
//   }
//
//   // Future<void> readBatteryLevel() async {
//   //   if (batteryCharacteristic != null) {
//   //     var value = await batteryCharacteristic!.read();
//   //     setState(() {
//   //       batteryLevel = value.first; // Battery level is typically a single byte
//   //     });
//   //     print("Battery Level: $batteryLevel%");
//   //   }
//   // }
//
//   Future<void> turnDeviceOn() async {
//     if (batteryCharacteristic != null) {
//       try {
//         await batteryCharacteristic!.write(DEVICE_ON);
//         print("Device turned on.");
//       } catch (e) {
//         print("Error turning device on: $e");
//       }
//     }
//   }
//
//   Future<void> turnDeviceOff() async {
//     if (batteryCharacteristic != null) {
//       try {
//         await batteryCharacteristic!.write(DEVICE_OFF);
//         print("Device turned off.");
//       } catch (e) {
//         print("Error turning device off: $e");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("BLE Get Data"),
//       ),
//       body: Center(
//         child: connectedDevice != null
//             ? Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Connected Device: ${connectedDevice!.name}",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               batteryLevel >= 0
//                   ? "Battery Level: $batteryLevel%"
//                   : "Reading Battery Level...",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: turnDeviceOn,
//               child: const Text("Turn On"),
//             ),
//             ElevatedButton(
//               onPressed: turnDeviceOff,
//               child: const Text("Turn Off"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               child: const Text('Disconnect'),
//               onPressed: () async {
//                 await connectedDevice!.disconnect();
//                 setState(() {
//                   connectedDevice = null;
//                   batteryLevel = -1;
//                 });
//               },
//             ),
//           ],
//         )
//             : const Text(
//           "No connected device found.",
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;
//
//   List<BluetoothDevice> devicesList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     startScan();
//   }
//
//   // Start scanning and only add devices with the name "SkyVoice"
//   void startScan() {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//
//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         // Check if the device name contains "SkyVoice"
//         if (result.device.name.contains("SkyVoice") &&
//             !devicesList.contains(result.device)) {
//           setState(() {
//             devicesList.add(result.device);
//           });
//         }
//       }
//     });
//
//     FlutterBluePlus.stopScan();
//   }
//
//   // Connect to the selected device
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     setState(() {
//       connectedDevice = device;
//     });
//
//     await device.connect();
//     print("Connected to ${device.name}");
//   }
//
//   // Disconnect from the connected device
//   Future<void> disconnectFromDevice() async {
//     if (connectedDevice != null) {
//       await connectedDevice!.disconnect();
//       print("Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null;
//       });
//     }
//   }
//
//   // Build the list of available devices (only "SkyVoice" devices)
//   Widget buildDeviceList() {
//     return ListView.builder(
//       itemCount: devicesList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(devicesList[index].name.isNotEmpty
//               ? devicesList[index].name
//               : "Unknown Device"),
//           subtitle: Text(devicesList[index].id.toString()),
//           onTap: () {
//             connectToDevice(devicesList[index]);
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? buildDeviceList()  // Show device list if not connected
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           if (connectedDevice != null)
//             ElevatedButton(
//               child: Text('Disconnect'),
//               onPressed: () {
//                 disconnectFromDevice();
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;
//   List<BluetoothDevice> devicesList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     getConnectedDevices();
//   }
//
//   // Get currently connected devices
//   Future<void> getConnectedDevices() async {
//     // Get the list of connected devices
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     // Filter the list to only include devices named "SkyVoice"
//     setState(() {
//       devicesList = connectedDevices
//           .where((device) => device.name.contains("SkyVoice"))
//           .toList();
//
//       if (devicesList.isNotEmpty) {
//         connectedDevice = devicesList.first;  // Assuming you want the first connected "SkyVoice" device
//       }
//     });
//   }
//
//   // Disconnect from the connected device
//   Future<void> disconnectFromDevice() async {
//     if (connectedDevice != null) {
//       await connectedDevice!.disconnect();
//       print("Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null;
//       });
//     }
//   }
//
//   // Build the list of connected devices
//   Widget buildDeviceList() {
//     return ListView.builder(
//       itemCount: devicesList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(devicesList[index].name.isNotEmpty
//               ? devicesList[index].name
//               : "Unknown Device"),
//           subtitle: Text(devicesList[index].id.toString()),
//           onTap: () {
//             setState(() {
//               connectedDevice = devicesList[index];
//             });
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? buildDeviceList()  // Show the list of connected devices
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           if (connectedDevice != null)
//             ElevatedButton(
//               child: Text('Disconnect'),
//               onPressed: () {
//                 disconnectFromDevice();
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;
//   List<BluetoothDevice> devicesList = [];
//   bool isDeviceConnected = false; // To check if SkyVoice is connected
//
//   @override
//   void initState() {
//     super.initState();
//     getConnectedDevices();
//   }
//
//   // Get currently connected devices
//   Future<void> getConnectedDevices() async {
//     // Get the list of connected devices
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     // Filter the list to only include devices named "SkyVoice"
//     setState(() {
//       devicesList = connectedDevices
//           .where((device) => device.name.contains("SkyVoice"))
//           .toList();
//
//       // If SkyVoice device is found, set it as connected
//       if (devicesList.isNotEmpty) {
//         connectedDevice = devicesList.first;
//         isDeviceConnected = true;
//       } else {
//         isDeviceConnected = false;
//       }
//     });
//
//     // Show warning if SkyVoice is not connected
//     if (!isDeviceConnected) {
//       _showDeviceNotConnectedWarning();
//     }
//   }
//
//   // Disconnect from the connected device
//   // Future<void> disconnectFromDevice() async {
//   //   if (connectedDevice != null) {
//   //     await connectedDevice!.disconnect();
//   //     print("Disconnected from ${connectedDevice!.name}");
//   //     setState(() {
//   //       connectedDevice = null;
//   //       isDeviceConnected = false;
//   //     });
//   //
//   //     // Show warning after disconnecting
//   //     _showDeviceNotConnectedWarning();
//   //   }
//   // }
//
//   // Toggle DEVICE_ON / DEVICE_OFF functionality
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Assuming the first "SkyVoice" device
//         await device.connect();
//         print("DEVICE_ON: Connected to ${device.name}");
//         setState(() {
//           connectedDevice = device;
//           isDeviceConnected = true;
//         });
//       } else {
//         // Show warning if no SkyVoice device is connected
//         _showDeviceNotConnectedWarning();
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect();
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null;
//         isDeviceConnected = false;
//       });
//
//       // Show warning after disconnecting
//       _showDeviceNotConnectedWarning();
//     }
//   }
//
//
//   // Show a warning dialog if SkyVoice device is not connected
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Warning"),
//           content: Text("SkyVoice device is not connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Build the list of connected devices
//   Widget buildDeviceList() {
//     return ListView.builder(
//       itemCount: devicesList.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(devicesList[index].name.isNotEmpty
//               ? devicesList[index].name
//               : "Unknown Device"),
//           subtitle: Text(devicesList[index].id.toString()),
//           onTap: () {
//             setState(() {
//               connectedDevice = devicesList[index];
//             });
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? buildDeviceList() // Show list of connected devices or warning
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           if (connectedDevice != null)
//             ElevatedButton(
//               child: Text('Disconnect'),
//               onPressed: () {
//                 toggleDeviceConnection();
//               },
//             ),
//         ],
//       ),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;
//   List<BluetoothDevice> devicesList = [];
//   bool isBluetoothOn = false;
//
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   checkBluetoothAdapterState();
//   // }
//   //
//   // // Step 1: Check the Bluetooth adapter state
//   // Future<void> checkBluetoothAdapterState() async {
//   //   bool isOn = await FlutterBluePlus.isOn;
//   //
//   //   setState(() {
//   //     isBluetoothOn = isOn;
//   //   });
//   //
//   //   if (isBluetoothOn) {
//   //     getConnectedDevices();
//   //   } else {
//   //     // Show a warning or prompt the user to enable Bluetooth
//   //     _showBluetoothDisabledWarning();
//   //   }
//   // }
//   //
//   // // Step 2: Get currently connected devices and handle reconnects
//   // Future<void> getConnectedDevices() async {
//   //   // Get the list of connected devices
//   //   List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//   //
//   //   setState(() {
//   //     // Filter the list to only include devices named "SkyVoice"
//   //     devicesList = connectedDevices
//   //         .where((device) => device.name.contains("SkyVoice"))
//   //         .toList();
//   //
//   //     if (devicesList.isNotEmpty) {
//   //       connectedDevice = devicesList.first;  // Assuming the first connected "SkyVoice" device
//   //     } else {
//   //       // No connected devices; you can handle auto-reconnect or show a warning
//   //       _showDeviceNotConnectedWarning();
//   //     }
//   //   });
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState();
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn;
//     if (isAdapterOn) {
//       // Adapter is on, proceed to check for connected devices
//       getConnectedDevices();
//     } else {
//       // Handle the case where the adapter is off (show a warning or prompt to enable Bluetooth)
//       _showBluetoothDisabledWarning();
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     if (connectedDevices.isEmpty) {
//       print("No devices connected. Reattempting connection...");
//       reconnectToPreviousDevices();
//     } else {
//       // Handle connected devices
//       setState(() {
//         devicesList = connectedDevices.where((device) => device.name.contains("SkyVoice")).toList();
//         connectedDevice = devicesList.isNotEmpty ? devicesList.first : null;
//       });
//     }
//   }
//
//   Future<void> reconnectToPreviousDevices() async {
//     // Logic to reconnect to known devices or scan for devices and connect again
//     // This could be done by scanning for specific devices (like "SkyVoice")
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//
//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (result.device.name.contains("SkyVoice")) {
//           // Attempt to reconnect to the device
//           connectToDevice(result.device);
//           break;
//         }
//       }
//     });
//
//     FlutterBluePlus.stopScan();
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect();
//     print("Connected to ${device.name}");
//     setState(() {
//       connectedDevice = device;
//     });
//   }
//
//   // void _showBluetoothDisabledWarning() {
//   //   // Show a dialog or message to the user indicating Bluetooth is disabled
//   // }
//
//
//   // Handle the situation where the Bluetooth adapter is off
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Show a warning if no SkyVoice device is connected
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Device Not Connected"),
//           content: Text("No SkyVoice device is connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // Step 3: Add additional logs and handle reconnection if no connected devices are found
//   void reconnectToDeviceIfNeeded() {
//     if (devicesList.isEmpty) {
//       print("No connected SkyVoice devices. Attempting to reconnect...");
//
//       // Optionally, you could start scanning for devices and reconnect
//       startScanAndReconnect();
//     }
//   }
//
//   // Optional: Scan for available devices and attempt to reconnect
//   Future<void> startScanAndReconnect() async {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//
//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (result.device.name.contains("SkyVoice")) {
//           connectToDevice(result.device);
//           break;
//         }
//       }
//     });
//
//     FlutterBluePlus.stopScan();
//   }
//
//   // Connect to a device
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect();
//     print("Connected to ${device.name}");
//     setState(() {
//       connectedDevice = device;
//     });
//   }
//
//   // Toggle DEVICE_ON / DEVICE_OFF functionality
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Assuming the first "SkyVoice" device
//         await device.connect();
//         print("DEVICE_ON: Connected to ${device.name}");
//         setState(() {
//           connectedDevice = device;
//         });
//       } else {
//         _showDeviceNotConnectedWarning();
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect();
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? Center(child: Text("No connected devices"))
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(connectedDevice == null ? 'Turn Device ON' : 'Turn Device OFF'),
//             onPressed: () {
//               toggleDeviceConnection();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   List<BluetoothDevice> devicesList = []; // List of discovered devices
//   bool isBluetoothOn = false; // Flag to check if Bluetooth is on
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState(); // Check Bluetooth state on initialization
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//     if (isAdapterOn) {
//       getConnectedDevices(); // Proceed to get connected devices
//     } else {
//       _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       print("No devices connected. Scanning for available devices...");
//       scanForDevices(); // Start scanning for devices if none are connected
//     } else {
//       setState(() {
//         devicesList = connectedDevices.where((device) => device.name.contains("SkyVoice")).toList();
//         connectedDevice = devicesList.isNotEmpty ? devicesList.first : null; // Set the first found device
//       });
//     }
//   }
//
//   void scanForDevices() {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Start scanning
//
//     FlutterBluePlus.scanResults.listen((results) {
//       setState(() {
//         devicesList = results.map((result) => result.device).where((device) => device.name.contains("SkyVoice")).toList();
//       });
//
//       if (devicesList.isNotEmpty) {
//         // Automatically connect to the first found "SkyVoice" device
//         connectToDevice(devicesList.first);
//       } else {
//         // Show a warning if no devices found
//         _showDeviceNotConnectedWarning();
//       }
//     });
//
//     FlutterBluePlus.stopScan(); // Stop scanning after processing results
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect(); // Connect to the selected device
//     print("Connected to ${device.name}");
//     setState(() {
//       connectedDevice = device; // Update the state with the connected device
//     });
//   }
//
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Device Not Connected"),
//           content: Text("No SkyVoice device is connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Get the first available device
//         await connectToDevice(device); // Connect to the device
//         print("DEVICE_ON: Connected to ${device.name}");
//       } else {
//         _showDeviceNotConnectedWarning(); // Show warning if no devices are available
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect(); // Disconnect from the device
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null; // Clear the connected device
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? Center(child: Text("No connected devices"))
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(connectedDevice == null ? 'Turn Device ON' : 'Turn Device OFF'),
//             onPressed: () {
//               toggleDeviceConnection(); // Toggle connection on button press
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//

//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   List<BluetoothDevice> devicesList = []; // List of discovered devices
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState(); // Check Bluetooth state on initialization
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//     if (isAdapterOn) {
//       getConnectedDevices(); // Proceed to get connected devices
//     } else {
//       // _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       print("No devices connected. Scanning for available devices...");
//       scanForDevices(); // Start scanning for devices if none are connected
//     } else {
//       setState(() {
//         devicesList = connectedDevices.where((device) => device.name.contains("SkyVoice")).toList();
//         connectedDevice = devicesList.isNotEmpty ? devicesList.first : null; // Set the first found device
//       });
//     }
//   }
//
//   void scanForDevices() {
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Start scanning
//
//     FlutterBluePlus.scanResults.listen((results) {
//       setState(() {
//         devicesList = results.map((result) => result.device).where((device) => device.name.contains("SkyVoice")).toList();
//       });
//
//       if (devicesList.isNotEmpty) {
//         // Automatically connect to the first found "SkyVoice" device
//         connectToDevice(devicesList.first);
//       } else {
//         // Show a warning if no devices found
//         // _showDeviceNotConnectedWarning();
//       }
//     });
//
//     FlutterBluePlus.stopScan(); // Stop scanning after processing results
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect(); // Connect to the selected device
//     print("Connected to ${device.name}");
//     setState(() {
//       connectedDevice = device; // Update the state with the connected device
//     });
//   }
//
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Device Not Connected"),
//           content: Text("No SkyVoice device is connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Get the first available device
//         await connectToDevice(device); // Connect to the device
//         print("DEVICE_ON: Connected to ${device.name}");
//       } else {
//         _showDeviceNotConnectedWarning(); // Show warning if no devices are available
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect(); // Disconnect from the device
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null; // Clear the connected device
//       });
//     }
//   }
//
//   // Refresh function to check the connected device and scan for new devices
//   Future<void> refreshDevices() async {
//     setState(() {
//       // devicesList.clear(); // Clear the current device list
//       connectedDevice = null; // Reset the connected device
//     });
//     await checkBluetoothAdapterState(); // Recheck Bluetooth state and fetch devices
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh), // Refresh icon
//             onPressed: refreshDevices, // Call refresh function
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: connectedDevice == null
//                 ? Center(child: Text("No connected devices"))
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(connectedDevice == null ? 'Turn Device ON' : 'Turn Device OFF'),
//             onPressed: () {
//               toggleDeviceConnection(); // Toggle connection on button press
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   List<BluetoothDevice> devicesList = []; // List of discovered devices
//   bool isLoading = false; // Loading state to show the circular indicator
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState(); // Check Bluetooth state on initialization
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//     if (isAdapterOn) {
//       getConnectedDevices(); // Proceed to get connected devices
//     } else {
//        _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       print("No devices connected. Scanning for available devices...");
//       await scanForDevices(); // Start scanning for devices if none are connected
//     } else {
//       setState(() {
//         devicesList = connectedDevices.where((device) => device.name.contains("SkyVoice")).toList();
//         connectedDevice = devicesList.isNotEmpty ? devicesList.first : null; // Set the first found device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   Future<void> scanForDevices() async {
//     setState(() {
//       isLoading = true; // Start loading when scanning
//     });
//
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Start scanning
//
//     FlutterBluePlus.scanResults.listen((results) {
//       setState(() {
//         devicesList = results.map((result) => result.device).where((device) => device.name.contains("SkyVoice")).toList();
//       });
//
//       if (devicesList.isNotEmpty) {
//         // Automatically connect to the first found "SkyVoice" device
//         connectToDevice(devicesList.first);
//       } else {
//         // Show a warning if no devices found
//         // _showDeviceNotConnectedWarning();
//       }
//     });
//
//     // Stop scanning after processing results
//     await Future.delayed(Duration(seconds: 5));
//     FlutterBluePlus.stopScan(); // Stop scanning
//     setState(() {
//       isLoading = false; // Stop loading after scanning is done
//     });
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect(); // Connect to the selected device
//     print("Connected to ${device.name}");
//     setState(() {
//       connectedDevice = device; // Update the state with the connected device
//       isLoading = false; // Stop loading
//     });
//   }
//
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Device Not Connected"),
//           content: Text("No SkyVoice device is connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Get the first available device
//         await connectToDevice(device); // Connect to the device
//         print("DEVICE_ON: Connected to ${device.name}");
//       } else {
//         _showDeviceNotConnectedWarning(); // Show warning if no devices are available
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect(); // Disconnect from the device
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       setState(() {
//         connectedDevice = null; // Clear the connected device
//       });
//     }
//   }
//
//    // Refresh function to check the connected device and scan for new devices
//   Future<void> refreshDevices() async {
//     setState(() {
//       devicesList.clear(); // Clear the current device list
//       connectedDevice = null; // Reset the connected device
//     });
//     await checkBluetoothAdapterState(); // Recheck Bluetooth state and fetch devices
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//         // actions: [
//         //   IconButton(
//         //     icon: Icon(Icons.refresh), // Refresh icon
//         //     onPressed: refreshDevices, // Call refresh function
//         //   ),
//         // ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator()) // Show loading indicator if loading
//                 : connectedDevice == null
//                 ? Center(child: Text("No connected devices"))
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(connectedDevice == null ? 'Turn Device ON' : 'Turn Device OFF'),
//             onPressed: () {
//               toggleDeviceConnection(); // Toggle connection on button press
//             },
//           ),
//           // If device is not connected and not loading, show the refresh button
//           if (!isLoading && connectedDevice == null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 child: Text('Refresh Devices'),
//                 onPressed: refreshDevices,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   List<BluetoothDevice> devicesList = []; // List of discovered devices
//   bool isLoading = false; // Loading state to show the circular indicator
//   bool isScanning = false; // Flag to track scanning status
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState(); // Check Bluetooth state on initialization
//   }
//
//   @override
//   void dispose() {
//     // Stop scanning if the widget is disposed
//     if (isScanning) {
//       FlutterBluePlus.stopScan();
//       isScanning = false;
//     }
//     super.dispose();
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//     if (isAdapterOn) {
//       getConnectedDevices(); // Proceed to get connected devices
//     } else {
//       _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       print("No devices connected. Scanning for available devices...");
//       await scanForDevices(); // Start scanning for devices if none are connected
//     } else {
//       setState(() {
//         devicesList = connectedDevices.where((device) => device.name.contains("SkyVoice")).toList();
//         connectedDevice = devicesList.isNotEmpty ? devicesList.first : null; // Set the first found device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   Future<void> scanForDevices() async {
//     setState(() {
//       isLoading = true; // Start loading when scanning
//       isScanning = true; // Set scanning flag to true
//     });
//
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Start scanning
//
//     FlutterBluePlus.scanResults.listen((results) {
//       if (!mounted) return; // Check if the widget is still mounted
//
//       setState(() {
//         devicesList = results.map((result) => result.device).where((device) => device.name.contains("SkyVoice")).toList();
//       });
//
//       if (devicesList.isNotEmpty) {
//         connectToDevice(devicesList.first); // Automatically connect to the first found "SkyVoice" device
//       }
//     });
//
//     // Stop scanning after a delay
//     await Future.delayed(Duration(seconds: 5));
//     FlutterBluePlus.stopScan(); // Stop scanning
//     if (mounted) {
//       setState(() {
//         isLoading = false; // Stop loading after scanning is done
//         isScanning = false; // Reset scanning flag
//       });
//     }
//   }
//
//   Future<void> connectToDevice(BluetoothDevice device) async {
//     await device.connect(); // Connect to the selected device
//     print("Connected to ${device.name}");
//     if (mounted) {
//       setState(() {
//         connectedDevice = device; // Update the state with the connected device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Device Not Connected"),
//           content: Text("No SkyVoice device is connected."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> toggleDeviceConnection() async {
//     if (connectedDevice == null) {
//       // DEVICE_ON: Connect to the first available "SkyVoice" device
//       if (devicesList.isNotEmpty) {
//         BluetoothDevice device = devicesList.first; // Get the first available device
//         await connectToDevice(device); // Connect to the device
//         print("DEVICE_ON: Connected to ${device.name}");
//       } else {
//         _showDeviceNotConnectedWarning(); // Show warning if no devices are available
//       }
//     } else {
//       // DEVICE_OFF: Disconnect the connected device
//       await connectedDevice!.disconnect(); // Disconnect from the device
//       print("DEVICE_OFF: Disconnected from ${connectedDevice!.name}");
//       if (mounted) {
//         setState(() {
//           connectedDevice = null; // Clear the connected device
//         });
//       }
//     }
//   }
//
//   Future<void> refreshDevices() async {
//     setState(() {
//       devicesList.clear(); // Clear the current device list
//       connectedDevice = null; // Reset the connected device
//     });
//     await checkBluetoothAdapterState(); // Recheck Bluetooth state and fetch devices
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("SkyVoice Bluetooth Control"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: isLoading
//                 ? Center(child: CircularProgressIndicator()) // Show loading indicator if loading
//                 : connectedDevice == null
//                 ? Center(child: Text("No connected devices"))
//                 : Center(
//               child: Text(
//                 "Connected to: ${connectedDevice!.name}",
//                 style: TextStyle(fontSize: 24),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             child: Text(connectedDevice == null ? 'Turn Device ON' : 'Turn Device OFF'),
//             onPressed: () {
//               toggleDeviceConnection(); // Toggle connection on button press
//             },
//           ),
//           // If device is not connected and not loading, show the refresh button
//           if (!isLoading && connectedDevice == null)
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 child: Text('Refresh Devices'),
//                 onPressed: refreshDevices,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;// Currently connected device
//   bool isLoading = false; // Loading state to show the circular indicator
//   bool isBluetoothConnected = true;
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothAdapterState(); // Check Bluetooth state on initialization
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   Future<void> checkBluetoothAdapterState() async {
//     bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//     if (isAdapterOn) {
//       getConnectedDevices(); // Proceed to get connected devices
//     } else {
//       _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//     }
//   }
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> isOn = await FlutterBluePlus.connectedDevices;
//     setState(() {
//       isBluetoothConnected = isOn as bool;
//
//       if (isBluetoothConnected) {
//         Text(isOn.toString());
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       // _showBluetoothSettingsDialog();
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       // No devices connected
//       setState(() {
//         connectedDevice = null; // Reset connected device
//         isLoading = false; // Stop loading
//       });
//       _showDeviceNotConnectedWarning(); // Show error message
//     } else {
//       // A device is connected
//       setState(() {
//         connectedDevice = connectedDevices.first; // Get the first connected device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   void _showBluetoothDisabledWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Bluetooth Disabled"),
//           content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("No Device Connected"),
//           content: Text("No device is currently connected. Please connect a device."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bluetooth Control"),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Show loading indicator if loading
//             : connectedDevice == null
//             ? Text("No device connected.") // Show error message if no device is connected
//             : Text(
//           "Connected to: ${connectedDevice!.name}", // Show the name of the connected device
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   bool isLoading = false; // Loading state to show the circular indicator
//   bool isBluetoothConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     // checkBluetoothAdapterState();// Check Bluetooth state on initialization
//     checkBluetoothStatus();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   // Future<void> checkBluetoothAdapterState() async {
//   //   bool isAdapterOn = await FlutterBluePlus.isOn; // Check if Bluetooth is enabled
//   //   if (isAdapterOn) {
//   //     getConnectedDevices(); // Proceed to get connected devices
//   //   } else {
//   //     _showBluetoothDisabledWarning(); // Show warning if Bluetooth is off
//   //   }
//   // }
//
//   // Future<void> checkBluetoothStatus() async {
//   //   List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Get the list of connected devices
//   //
//   //   setState(() {
//   //     isBluetoothConnected = connectedDevices.isNotEmpty; // Check if any device is connected
//   //
//   //     if (isBluetoothConnected) {
//   //       // Display the connected devices (if needed, here it's a simple print or UI update)
//   //       print(connectedDevices.toString());
//   //     }
//   //   });
//   //
//   //   if (!isBluetoothConnected) {
//   //     await Future.delayed(Duration(seconds: 30));
//   //      _showDeviceNotConnectedWarning(); // Show a warning dialog if no device is connected
//   //     // _showBluetoothDisabledWarning();
//   //   }
//   // }
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Get the list of currently connected devices
//
//     setState(() {
//       isBluetoothConnected = connectedDevices.isNotEmpty; // Check if any device is already connected
//
//       if (isBluetoothConnected) {
//         // Display the connected devices (if needed, here it's a simple print or UI update)
//         print("Connected Devices: ${connectedDevices.toString()}");
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       // Start scanning for devices
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
//
//       // Listen for scan results and check for any devices
//       FlutterBluePlus.scanResults.listen((results) async {
//         if (results.isNotEmpty) {
//           setState(() {
//             isBluetoothConnected = true;
//             connectedDevice = results.first.device; // Get the first found device
//           });
//         }
//       });
//
//       // Wait for 30 seconds before checking if a device was found
//       await Future.delayed(Duration(seconds: 30));
//
//       // Stop scanning after 30 seconds
//       FlutterBluePlus.stopScan();
//
//       // If no device is connected after scanning, show the warning dialog
//       if (!isBluetoothConnected) {
//         _showDeviceNotConnectedWarning();
//       }
//     }
//   }
//
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       // No devices connected
//       setState(() {
//         connectedDevice = null; // Reset connected device
//         isLoading = false; // Stop loading
//       });
//       _showDeviceNotConnectedWarning(); // Show error message
//       // _showBluetoothDisabledWarning();
//     } else {
//       // A device is connected
//       setState(() {
//         connectedDevice = connectedDevices.first; // Get the first connected device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   // void _showBluetoothDisabledWarning() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return AlertDialog(
//   //         title: Text("Bluetooth Disabled"),
//   //         content: Text("Bluetooth is turned off. Please enable Bluetooth to use this feature."),
//   //         actions: [
//   //           TextButton(
//   //             child: Text("OK"),
//   //             onPressed: () {
//   //               Navigator.of(context).pop();
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//
//   void _showDeviceNotConnectedWarning() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("No Device Connected"),
//           content: Text("No device is currently connected. Please connect a device."),
//           actions: [
//             TextButton(
//               child: Text("OK"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bluetooth Control"),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Show loading indicator if loading
//             : connectedDevice == null
//             ? Text("No device connected.") // Show error message if no device is connected
//             : Text(
//           "Connected to: ${connectedDevice!.name}", // Show the name of the connected device
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:open_settings_plus/core/open_settings_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   bool isLoading = false; // Loading state to show the circular indicator
//   bool isScanning = false; // Scanning state to track if scanning is in progress
//   bool isBluetoothConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothStatus();
//   }
//   //
//   // @override
//   // void dispose() {
//   //   super.dispose();
//   // }
//
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus
//         .connectedDevices; // Get the list of connected devices
//
//     setState(() {
//       isBluetoothConnected =
//           connectedDevices.isNotEmpty; // Check if any device is connected
//
//       if (isBluetoothConnected) {
//         // Display the connected devices (if needed, here it's a simple print or UI update)
//         print("Connected Devices: ${connectedDevices.toString()}");
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       // Start scanning for devices and show circular progress indicator
//       setState(() {
//         isScanning = true; // Start scanning state
//       });
//
//       // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
//
//       // Listen for scan results and check for any devices
//       FlutterBluePlus.scanResults.listen((results) async {
//         if (results.isNotEmpty) {
//           setState(() {
//             isBluetoothConnected = true;
//             connectedDevice =
//                 results.first.device; // Get the first found device
//           });
//         }
//       });
//
//       // Wait for 30 seconds while scanning
//       await Future.delayed(Duration(seconds: 30));
//
//       // Stop scanning after 30 seconds
//       FlutterBluePlus.stopScan();
//
//       // Stop scanning and hide circular indicator
//       setState(() {
//         isScanning = false;
//       });
//       // If no device is connected after scanning, show the warning dialog
//       if (!isBluetoothConnected) {
//         // _showDeviceNotConnectedWarning();
//         _showBluetoothSettingsDialog();
//       }
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices =
//         await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       // No devices connected
//       setState(() {
//         connectedDevice = null; // Reset connected device
//         isLoading = false; // Stop loading
//       });
//       // _showDeviceNotConnectedWarning(); // Show error message
//       _showBluetoothSettingsDialog();
//     } else {
//       // A device is connected
//       setState(() {
//         connectedDevice =
//             connectedDevices.first; // Get the first connected device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//
//   void _showBluetoothSettingsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('SkyVoice not connected!'),
//           content: const Text('Please connect with SkyVoice.'),
//           actions: <Widget>[
//             ElevatedButton(
//               child: const Text('Open Bluetooth Settings'),
//               onPressed: () {
//                 // Corrected method for opening Bluetooth settings
//                 if (Platform.isAndroid) {
//                   const OpenSettingsPlusAndroid().bluetooth();
//                 } else if (Platform.isIOS) {
//                   const OpenSettingsPlusIOS().bluetooth();
//                 }
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Bluetooth Control"),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Show loading indicator if loading
//             : isScanning
//                 ? const Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       CircularProgressIndicator(), // Show scanning progress indicator
//                       SizedBox(height: 20),
//                       Text("Scanning for devices..."),
//                     ],
//                   )
//                 : connectedDevice == null
//                     ? const Text(
//                         "No device connected.") // Show error message if no device is connected
//                     : Text(
//                         "Connected to: ${connectedDevice!.name}",
//                         // Show the name of the connected device
//                         style: TextStyle(fontSize: 24),
//                       ),
//       ),
//     );
//   }
// }


// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:open_settings_plus/core/open_settings_plus.dart';
//
// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice; // Currently connected device
//   bool isLoading = false; // Loading state to show the circular indicator
//   bool isScanning = false; // Scanning state to track if scanning is in progress
//   bool isBluetoothConnected = true;
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothStatus();
//   }
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Get the list of connected devices
//
//     setState(() {
//       isBluetoothConnected = connectedDevices.isNotEmpty; // Check if any device is connected
//
//       if (isBluetoothConnected) {
//         print("Connected Devices: ${connectedDevices.toString()}");
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       setState(() {
//         isScanning = true; // Start scanning state
//       });
//
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
//
//       FlutterBluePlus.scanResults.listen((results) async {
//         if (results.isNotEmpty) {
//           setState(() {
//             isBluetoothConnected = true;
//             connectedDevice = results.first.device; // Get the first found device
//           });
//         }
//       });
//
//       await Future.delayed(Duration(seconds: 30));
//       FlutterBluePlus.stopScan();
//
//       setState(() {
//         isScanning = false;
//       });
//
//       if (!isBluetoothConnected) {
//         _showBluetoothSettingsDialog();
//       }
//     }
//   }
//
//   Future<void> getConnectedDevices() async {
//     setState(() {
//       isLoading = true; // Start loading
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices
//
//     if (connectedDevices.isEmpty) {
//       setState(() {
//         connectedDevice = null; // Reset connected device
//         isLoading = false; // Stop loading
//       });
//       _showBluetoothSettingsDialog();
//     } else {
//       setState(() {
//         connectedDevice = connectedDevices.first; // Get the first connected device
//         isLoading = false; // Stop loading
//       });
//     }
//   }
//
//   void _showBluetoothSettingsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('SkyVoice not connected!'),
//           content: const Text('Please connect with SkyVoice.'),
//           actions: <Widget>[
//             ElevatedButton(
//               child: const Text('Open Bluetooth Settings'),
//               onPressed: () {
//                 if (Platform.isAndroid) {
//                   const OpenSettingsPlusAndroid().bluetooth();
//                 } else if (Platform.isIOS) {
//                   const OpenSettingsPlusIOS().bluetooth();
//                 }
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Bluetooth Control"),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator() // Show loading indicator if loading
//             : isScanning
//             ? const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(), // Show scanning progress indicator
//             SizedBox(height: 20),
//             Text("Scanning for devices..."),
//           ],
//         )
//             : connectedDevice == null
//             ? const Text("No device connected.") // Show error message if no device is connected
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Connected to: ${connectedDevice!.name}", // Show the name of the connected device
//               style: TextStyle(fontSize: 24),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Action to perform when the button is pressed
//                 print("Button pressed for ${connectedDevice!.name}");
//               },
//               child: const Text("Perform Action"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ***************&&&&&&&&&&&&&************%%%%%%%%%%%%%%%**********************
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';

class BluetoothControlScreen extends StatefulWidget {
  const BluetoothControlScreen({super.key});

  @override
  State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
}

class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
  BluetoothDevice? connectedDevice; // Currently connected device
  bool isLoading = false; // Loading state to show the circular indicator
  bool isScanning = false; // Scanning state to track if scanning is in progress
  bool isBluetoothConnected = true;
  bool devicePowerState = false; // Power state of the device (on/off)

  @override
  void initState() {
    super.initState();
    checkBluetoothStatus();
  }

  Future<void> checkBluetoothStatus() async {
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Get the list of connected devices

    setState(() {
      isBluetoothConnected = connectedDevices.isNotEmpty; // Check if any device is connected

      if (isBluetoothConnected) {
        print("Connected Devices: ${connectedDevices.toString()}");
      }
    });

    if (!isBluetoothConnected) {
      setState(() {
        isScanning = true; // Start scanning state
      });

      FlutterBluePlus.startScan(timeout: Duration(seconds: 30));

      FlutterBluePlus.scanResults.listen((results) async {
        if (results.isNotEmpty) {
          setState(() {
            isBluetoothConnected = true;
            connectedDevice = results.first.device; // Get the first found device
          });
        }
      });

      await Future.delayed(Duration(seconds: 30));
      FlutterBluePlus.stopScan();

      setState(() {
        isScanning = false;
      });

      if (!isBluetoothConnected) {
        _showBluetoothSettingsDialog();
      }
    }
  }

  Future<void> getConnectedDevices() async {
    setState(() {
      isLoading = true; // Start loading
    });

    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices; // Fetch connected devices

    if (connectedDevices.isEmpty) {
      setState(() {
        connectedDevice = null; // Reset connected device
        isLoading = false; // Stop loading
      });
      _showBluetoothSettingsDialog();
    } else {
      setState(() {
        connectedDevice = connectedDevices.first; // Get the first connected device
        isLoading = false; // Stop loading
      });
    }
  }

  void _showBluetoothSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('SkyVoice not connected!'),
          content: const Text('Please connect with SkyVoice.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Open Bluetooth Settings'),
              onPressed: () {
                if (Platform.isAndroid) {
                  const OpenSettingsPlusAndroid().bluetooth();
                } else if (Platform.isIOS) {
                  const OpenSettingsPlusIOS().bluetooth();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleDevicePower() async {
    // Replace with the actual method to turn on/off the device
    if (connectedDevice != null) {
      // Example: Sending command to turn the device on or off
      // Note: You need to replace this with your actual device control logic.
      if (devicePowerState) {
        // Logic to turn off the device
        print("Turning off ${connectedDevice!.name}");
        // Example: await connectedDevice.write(yourOffCommand);
      } else {
        // Logic to turn on the device
        print("Turning on ${connectedDevice!.name}");
        // Example: await connectedDevice.write(yourOnCommand);
      }

      // Update power state
      setState(() {
        devicePowerState = !devicePowerState; // Toggle power state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if no device is connected and show the dialog
    if (connectedDevice == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showBluetoothSettingsDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Control"),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading indicator if loading
            : isScanning
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Show scanning progress indicator
            SizedBox(height: 20),
            Text("Scanning for devices..."),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              connectedDevice != null
                  ? "Connected to: ${connectedDevice!.name}" // Show the name of the connected device
                  : "No device connected.",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (connectedDevice != null) // Show button only if a device is connected
              ElevatedButton(
                onPressed: toggleDevicePower, // Turn on/off the device
                child: Text(devicePowerState ? "Turn Off" : "Turn On"), // Button text changes based on power state
              ),
          ],
        ),
      ),
    );
  }
}

