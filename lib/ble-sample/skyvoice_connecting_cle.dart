import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as flutter_blue_plus;



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

    setState(() {
      _isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results
            .where((result) => result.device.name == "SkyVoice")
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
              // CircularProgressIndicator(),
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
