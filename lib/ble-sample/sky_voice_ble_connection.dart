import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothControlScreenDone extends StatefulWidget {
  const BluetoothControlScreenDone({super.key});

  @override
  State<BluetoothControlScreenDone> createState() => _BluetoothControlScreenDoneState();
}

class _BluetoothControlScreenDoneState extends State<BluetoothControlScreenDone> {
  static const platform = MethodChannel('bluetooth/permissions');

  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _controlCharacteristic;
  bool _isDeviceOn = false;
  int _mtu = 23; // Default MTU size
  Timer? _keepAliveTimer;
  bool _isAlreadyConnected = false;

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
    if (_isScanning) return; // Prevent starting a scan if already scanning

    try {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      setState(() {
        _isScanning = true;
        // _scanResults.clear();
      });

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results
              .where((result) => result.device.name == "SkyVoice")
              .toList();
        });
      });

      await Future.delayed(const Duration(seconds: 10));
      _stopScan();
    } catch (e) {
      print('Error starting scan: $e');
      _showErrorDialog('Error starting scan: $e');
    }
  }

  void _stopScan() {
    if (!_isScanning) return; // Prevent stopping scan if not scanning

    try {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
      });
    } catch (e) {
      print('Error stopping scan: $e');
      _showErrorDialog('Error stopping scan: $e');
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      if (!_isAlreadyConnected) {
        await device.connect(autoConnect: false);
      }

      _discoverServices(device);
      setState(() {
        _targetDevice = device;
        _isAlreadyConnected = true; // Mark the device as connected
      });

      _monitorDeviceConnection(device);
      _keepAliveConnection(_controlCharacteristic);
    } catch (e) {
      _showErrorDialog('Error connecting to device: $e');
    }
  }

  void _discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _controlCharacteristic = characteristic; // Assign control characteristic
          }
          // Check for battery level characteristic if needed
        }
      }

      _mtu = await device.requestMtu(512); // Request MTU size
      setState(() {
        _targetDevice = device;
      });
    } catch (e) {
      _showErrorDialog('Error discovering services: $e');
    }
  }

  void _sendCommand(String command) async {
    if (_controlCharacteristic != null) {
      try {
        await _controlCharacteristic!.write(utf8.encode(command));
        print('Command sent: $command');
        setState(() {
          _isDeviceOn = command == 'DEVICE_ON';
        });
      } catch (e) {
        _showErrorDialog('Error sending command: $e');
      }
    } else {
      _showErrorDialog('Control characteristic not found or device not connected.');
    }
  }


  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      try {
        final bool isGranted = await platform.invokeMethod('checkPermissions');
        if (isGranted) {
          print('Permissions granted');
          _startScan(); // Start scanning after permissions are granted
        } else {
          print('Permissions not granted');
          _showPermissionDialog();
        }
      } on PlatformException catch (e) {
        print("Failed to check permissions: '${e.message}'");
        _showErrorDialog("Failed to check permissions: '${e.message}'");
      }
    } else if (Platform.isIOS) {
      print('No need to request permissions on iOS.');
      _startScan(); // Proceed to scan directly on iOS
    }
  }

  void _monitorDeviceConnection(BluetoothDevice device) {
    device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        print('Device disconnected');
        _showDisconnectionDialog(device);
      }
    });
  }

  void _showDisconnectionDialog(BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Disconnected'),
          content: Text('The device has been disconnected. Would you like to reconnect?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _connectToDevice(device);
              },
              child: Text('Reconnect'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _keepAliveConnection(BluetoothCharacteristic? characteristic) {
    if (characteristic != null) {
      _keepAliveTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
        try {
          await characteristic.read();
          print('Sent keep-alive signal');
        } catch (e) {
          print('Failed to send keep-alive signal: $e');
          timer.cancel();
        }
      });
    }
  }

  Future<void> _refresh() async {
    _stopScan(); // Stop scanning before refreshing
    await _startScan();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Communication'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: <Widget>[
            if (_scanResults.isNotEmpty || _isAlreadyConnected) ...[
              if (_isScanning) SizedBox(height: 20),
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
            ] else if (!_isScanning && !_isAlreadyConnected) ...[
              Center(child: Text('No devices found')),
            ],
            SizedBox(height: 20),
            if (_targetDevice != null)
              Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
            if (_controlCharacteristic != null) ...[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
                },
                child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
              ),
              SizedBox(height: 20),
            ],
            if (_isScanning) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Scanning for devices...'),
            ],
          ],
        ),
      ),
    );
  }
}