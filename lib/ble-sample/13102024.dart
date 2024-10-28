// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:open_settings_plus/core/open_settings_plus.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Bluetooth Control App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const BluetoothControlScreen(),
//     );
//   }
// }
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
//   bool isLoading = false;
//   bool isScanning = false;
//   bool isBluetoothConnected = true;
//   bool devicePowerState = false;
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothStatus();
//   }
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     setState(() {
//       isBluetoothConnected = connectedDevices.isNotEmpty;
//
//       if (isBluetoothConnected) {
//         print("Connected Devices: ${connectedDevices.toString()}");
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       setState(() {
//         isScanning = true;
//       });
//
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
//
//       FlutterBluePlus.scanResults.listen((results) async {
//         if (results.isNotEmpty) {
//           setState(() {
//             isBluetoothConnected = true;
//             connectedDevice = results.first.device;
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
//       isLoading = true;
//     });
//
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     if (connectedDevices.isEmpty) {
//       setState(() {
//         connectedDevice = null;
//         isLoading = false;
//       });
//       _showBluetoothSettingsDialog();
//     } else {
//       setState(() {
//         connectedDevice = connectedDevices.first;
//         isLoading = false;
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
//   Future<void> toggleDevicePower() async {
//     if (connectedDevice != null) {
//       try {
//         // Discover services and characteristics of the paired device
//         List<BluetoothService> services = await connectedDevice!.discoverServices();
//
//         // Replace with the actual characteristic UUID responsible for power control
//         final String powerControlCharacteristicUUID = "YOUR_CHARACTERISTIC_UUID";
//
//         BluetoothCharacteristic? controlCharacteristic;
//
//         // Search for the power control characteristic in the discovered services
//         for (BluetoothService service in services) {
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == powerControlCharacteristicUUID) {
//               controlCharacteristic = characteristic;
//               break;
//             }
//           }
//           if (controlCharacteristic != null) break;
//         }
//
//         if (controlCharacteristic != null) {
//           // Prepare the command to send to the device
//           List<int> command;
//
//           if (devicePowerState) {
//             // Send "DEVICE_OFF" command if the device is currently on
//             command = "DEVICE_OFF".codeUnits;
//             print("Sending DEVICE_OFF command to ${connectedDevice!.name}");
//           } else {
//             // Send "DEVICE_ON" command if the device is currently off
//             command = "DEVICE_ON".codeUnits;
//             print("Sending DEVICE_ON command to ${connectedDevice!.name}");
//           }
//
//           // Write the command to the characteristic
//           await controlCharacteristic.write(command, withoutResponse: true);
//
//           // Toggle the power state after sending the command
//           setState(() {
//             devicePowerState = !devicePowerState;
//           });
//         } else {
//           print("Power control characteristic not found.");
//         }
//       } catch (e) {
//         print("Error toggling power: $e");
//       }
//     } else {
//       print("No device connected.");
//     }
//   }
//
//   Future<void> discoverDeviceUUIDs() async {
//     // Get the list of currently connected devices
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     if (connectedDevices.isNotEmpty) {
//       BluetoothDevice device = connectedDevices.first; // Assuming the first connected device
//
//       print("Connected to: ${device.name} (${device.id})");
//
//       // Discover services and characteristics for the connected device
//       List<BluetoothService> services = await device.discoverServices();
//
//       for (BluetoothService service in services) {
//         print("Service UUID: ${service.uuid.toString()}");
//
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print("  Characteristic UUID: ${characteristic.uuid.toString()}");
//
//           // Optionally, check for specific properties (e.g., write, read, notify)
//           print("    Properties: ${characteristic.properties.toString()}");
//         }
//       }
//     } else {
//       print("No devices are currently connected.");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     if (connectedDevice == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _showBluetoothSettingsDialog();
//       });
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Bluetooth Control"),
//       ),
//       body: Center(
//         child: isLoading
//             ? CircularProgressIndicator()
//             : isScanning
//             ? const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text("Scanning for devices..."),
//           ],
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               connectedDevice != null
//                   ? "Connected to: ${connectedDevice!.name}"
//                   : "No device connected.",
//               style: TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             if (connectedDevice != null)
//               ElevatedButton(
//                 onPressed: toggleDevicePower,
//                 child: Text(devicePowerState ? "Turn Off" : "Turn On"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue_plus;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth Control App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothCommunicatScreenDone(),
    );
  }
}

// class BluetoothControlScreen extends StatefulWidget {
//   const BluetoothControlScreen({super.key});
//
//   @override
//   State<BluetoothControlScreen> createState() => _BluetoothControlScreenState();
// }
//
// class _BluetoothControlScreenState extends State<BluetoothControlScreen> {
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? powerControlCharacteristic;
//   bool isLoading = false;
//   bool isScanning = false;
//   bool isBluetoothConnected = true;
//   bool devicePowerState = false;
//
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothStatus();
//   }
//
//   Future<void> checkBluetoothStatus() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//
//     setState(() {
//       isBluetoothConnected = connectedDevices.any((device) => device.name == "SkyVoice");
//       if (isBluetoothConnected) {
//         connectedDevice = connectedDevices.firstWhere((device) => device.name == "SkyVoice");
//         print("Connected to SkyVoice: ${connectedDevice.toString()}");
//       }
//     });
//
//     if (!isBluetoothConnected) {
//       setState(() {
//         isScanning = true;
//       });
//
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 30));
//
//       FlutterBluePlus.scanResults.listen((results) async {
//         var skyVoiceDevice = results.firstWhere((result) => result.device.name == "SkyVoice");
//         if (skyVoiceDevice != null) {
//           setState(() {
//             isBluetoothConnected = true;
//             connectedDevice = skyVoiceDevice.device;
//           });
//
//           // Explicitly connect to the device
//           await connectedDevice!.connect();
//           print("Successfully connected to SkyVoice");
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
//
//
//   Future<void> discoverDeviceUUIDs() async {
//     if (connectedDevice != null && connectedDevice!.name == "SkyVoice") {
//       List<BluetoothService> services = await connectedDevice!.discoverServices();
//       for (BluetoothService service in services) {
//         print("Service UUID: ${service.uuid.toString()}");
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print("  Characteristic UUID: ${characteristic.uuid.toString()}");
//           print("    Properties: ${characteristic.properties.toString()}");
//         }
//       }
//     } else {
//       print("No SkyVoice device connected.");
//     }
//   }
//
//
//
//
//   Future<void> toggleDevicePower() async {
//     if (connectedDevice != null && connectedDevice!.name == "SkyVoice") {
//       try {
//         // Discover services and characteristics of SkyVoice device
//         List<BluetoothService> services = await connectedDevice!.discoverServices();
//
//         // Replace with the actual characteristic UUID responsible for power control
//         final String powerControlCharacteristicUUID = "YOUR_CHARACTERISTIC_UUID";
//
//         BluetoothCharacteristic? controlCharacteristic;
//
//         for (BluetoothService service in services) {
//           for (BluetoothCharacteristic characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == powerControlCharacteristicUUID) {
//               controlCharacteristic = characteristic;
//               break;
//             }
//           }
//           if (controlCharacteristic != null) break;
//         }
//
//         if (controlCharacteristic != null) {
//           List<int> command;
//           if (devicePowerState) {
//             command = "DEVICE_OFF".codeUnits;
//             print("Sending DEVICE_OFF command to SkyVoice");
//           } else {
//             command = "DEVICE_ON".codeUnits;
//             print("Sending DEVICE_ON command to SkyVoice");
//           }
//
//           await controlCharacteristic.write(command, withoutResponse: true);
//           setState(() {
//             devicePowerState = !devicePowerState;
//           });
//         } else {
//           print("Power control characteristic not found.");
//         }
//       } catch (e) {
//         print("Error toggling power: $e");
//       }
//     } else {
//       print("No SkyVoice device connected.");
//     }
//   }
//
//   void _showBluetoothSettingsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Device not connected!'),
//           content: const Text('Please connect to the device.'),
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
//             ? const CircularProgressIndicator()
//             : isScanning
//             ? const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text("Scanning for devices..."),
//           ],
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               connectedDevice != null
//                   ? "Connected to: ${connectedDevice!.name}"
//                   : "No device connected.",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 20),
//             if (connectedDevice != null)
//               ElevatedButton(
//                 onPressed: toggleDevicePower,
//                 child: Text(devicePowerState ? "Turn Off" : "Turn On"),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// Bluetooth Service for maintaining persistent connection
class BluetoothService {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _controlCharacteristic;
  bool _isDeviceOn = false;

  // Singleton pattern to ensure only one instance
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  // Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    if (_device == null || _device != device) {
      await device.connect(autoConnect: false);
      _device = device;
      await _discoverServices(device);
    }
  }

// Discover services and find the control characteristic
  Future<void> _discoverServices(BluetoothDevice device) async {
    List<flutter_blue_plus.BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          _controlCharacteristic = characteristic; // Storing control characteristic
        }
      }
    }
  }




  // Send a command to the device (turn on or off)
  Future<void> sendCommand(String command) async {
    if (_controlCharacteristic != null) {
      await _controlCharacteristic!.write(utf8.encode(command));
      _isDeviceOn = command == 'DEVICE_ON';
    }
  }

  bool get isDeviceOn => _isDeviceOn;
  BluetoothDevice? get connectedDevice => _device;

  // Clear the connection state
  void clearConnection() {
    _device = null;
    _controlCharacteristic = null;
    _isDeviceOn = false;
  }
}

class BluetoothCommunicatScreenDone extends StatefulWidget {
  const BluetoothCommunicatScreenDone({super.key});

  @override
  State<BluetoothCommunicatScreenDone> createState() => _BluetoothCommunicatScreenDoneState();
}

class _BluetoothCommunicatScreenDoneState extends State<BluetoothCommunicatScreenDone> {
  static const platform = MethodChannel('bluetooth/permissions');

  BluetoothService bluetoothService = BluetoothService();
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  Timer? _keepAliveTimer;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _stopScan();
    _keepAliveTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      try {
        final bool isGranted = await platform.invokeMethod('checkPermissions');
        if (isGranted) {
          _startScan();
        } else {
          _showPermissionDialog();
        }
      } on PlatformException catch (e) {
        _showErrorDialog("Failed to check permissions: '${e.message}'");
      }
    } else if (Platform.isIOS) {
      _startScan(); // No need to request permissions on iOS
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Permissions Required'),
          content: Text('Please enable Bluetooth permissions in the app settings.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    // Check if Bluetooth is enabled
    final isBluetoothEnabled = await FlutterBluePlus.isOn;

    if (!isBluetoothEnabled) {
      _showErrorDialog('Bluetooth is not enabled. Please turn it on.');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      for (var result in results) {
        print('Found device: ${result.device.name} (${result.device.id})');
      }

      setState(() {
        _scanResults = results
            .where((result) => result.device.name.trim() == "SkyVoice")
            .toList();
      });
    });

    await Future.delayed(const Duration(seconds: 10));
    _stopScan();
  }

  void _stopScan() {
    if (_isScanning) {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await bluetoothService.connectToDevice(device);
      _keepAliveConnection();
      setState(() {});
    } catch (e) {
      _showErrorDialog('Error connecting to device: $e');
    }
  }

  void _toggleDeviceState() async {
    if (bluetoothService.isDeviceOn) {
      await bluetoothService.sendCommand('DEVICE_OFF');
    } else {
      await bluetoothService.sendCommand('DEVICE_ON');
    }
    setState(() {}); // Update UI based on device state
  }

  void _keepAliveConnection() {
    BluetoothCharacteristic? characteristic = bluetoothService._controlCharacteristic;
    if (characteristic != null) {
      _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
        try {
          await characteristic.read();
        } catch (e) {
          timer.cancel();
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = bluetoothService.connectedDevice;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Control'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _startScan,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          if (_scanResults.isNotEmpty || device != null) ...[
            if (_isScanning) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Scanning for devices...'),
            ],
            if (_scanResults.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final result = _scanResults[index];
                  return ListTile(
                    title: Text(result.device.name),
                    subtitle: Text(result.device.id.toString()),
                    onTap: () {
                      _connectToDevice(result.device);
                      _stopScan();
                    },
                  );
                },
              ),
            ],
          ] else if (!_isScanning && device == null) ...[
            Center(child: Text('No devices found')),
          ],
          SizedBox(height: 20),
          if (device != null)
            Text('Connected to: ${device.name} (${device.id})'),
          if (bluetoothService.connectedDevice != null) ...[
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleDeviceState,
              child: Text(bluetoothService.isDeviceOn ? 'Turn OFF' : 'Turn ON'),
            ),
            SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
