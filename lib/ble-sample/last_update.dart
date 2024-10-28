

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothScanScreen extends StatefulWidget {
  @override
  _BluetoothScanScreenState createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _targetDevice;
  BluetoothCharacteristic? _controlCharacteristic;
  bool _isDeviceOn = false;
  int _mtu = 23; // Default MTU size
  int _batteryLevel = -1; // Battery level placeholder

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      setState(() {
        _isScanning = true;
        _scanResults.clear(); // Clear previous scan results
      });

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults = results;
        });
      });

      await Future.delayed(Duration(seconds: 10)); // Wait for scan to finish
      _stopScan();
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  void _stopScan() {
    try {
      FlutterBluePlus.stopScan();
      setState(() {
        _isScanning = false;
      });
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }


  String _deviceName = '';
  String _manufacturerName = '';
  String _modelNumber = '';
  String _serialNumber = '';
  String _firmwareRevision = '';
  String _hardwareRevision = '';
  String _softwareRevision = '';
  String _systemId = '';

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
            if (_scanResults.isNotEmpty) ...[
              if (_isScanning) ...[
                SizedBox(height: 20),
              ],
              ListView.builder(
                shrinkWrap: true,
                itemCount: _scanResults.length,
                itemBuilder: (context, index) {
                  final result = _scanResults[index];

                  // Skip devices without a name
                  if (result.device.name.isEmpty) {
                    return SizedBox.shrink();
                  }

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
            ] else if (!_isScanning) ...[
              Center(child: Text('No devices found')),
            ],
            SizedBox(height: 20),
            if (_targetDevice != null) ...[
              Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
              Text('Device Name: $_deviceName'),
              Text('Manufacturer: $_manufacturerName'),
              Text('Model Number: $_modelNumber'),
              Text('Serial Number: $_serialNumber'),
              Text('Firmware Revision: $_firmwareRevision'),
              Text('Hardware Revision: $_hardwareRevision'),
              Text('Software Revision: $_softwareRevision'),
              Text('System ID: $_systemId'),
            ],
            SizedBox(height: 20),
            if (_controlCharacteristic != null) ...[
              ElevatedButton(
                onPressed: () {
                  _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
                },
                child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
              ),
              SizedBox(height: 20),
              Text('MTU: $_mtu bytes'),
              if (_batteryLevel != -1)
                Text('Battery Level: $_batteryLevel%'),
            ],
          ],
        ),
      ),
    );
  }

  // void _connectToDevice(BluetoothDevice device) async {
  //   try {
  //     await device.connect();
  //     List<BluetoothService> services = await device.discoverServices();
  //
  //     for (BluetoothService service in services) {
  //       // Debugging: Print out each service UUID to check if the Battery Service exists
  //       print('Service UUID: ${service.uuid.toString()}');
  //
  //       for (BluetoothCharacteristic characteristic in service.characteristics) {
  //         // Print each characteristic for debugging
  //         print('Characteristic UUID: ${characteristic.uuid.toString()}');
  //
  //         if (characteristic.properties.write) {
  //           _controlCharacteristic = characteristic;
  //           break;
  //         }
  //       }
  //
  //       // Check for battery level characteristic in Battery Service (UUID 0x180F)
  //       if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
  //         print('Battery Service found');
  //         for (BluetoothCharacteristic characteristic in service.characteristics) {
  //           if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
  //             print('Battery Level Characteristic found');
  //             _readBatteryLevel(characteristic);
  //           }
  //         }
  //       }
  //
  //       if (_controlCharacteristic != null) break;
  //     }
  //
  //     // Request MTU size
  //     _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support
  //
  //     setState(() {
  //       _targetDevice = device; // Set the connected device
  //     });
  //   } catch (e) {
  //     print('Error connecting to device: $e');
  //   }
  // }

  void _readBatteryLevel(BluetoothCharacteristic batteryCharacteristic) async {
    try {
      var value = await batteryCharacteristic.read();
      setState(() {
        _batteryLevel = value[0]; // Battery level is usually in the first byte
      });
      print('Battery level: $_batteryLevel');
    } catch (e) {
      print('Error reading battery level: $e');
    }
  }
  //
  void _sendCommand(String command) async {
    if (_controlCharacteristic != null) {
      try {
        await _controlCharacteristic!.write(utf8.encode(command));
        print('Command sent: $command');
        setState(() {
          _isDeviceOn = command == 'DEVICE_ON'; // Update the state based on the command
        });
      } catch (e) {
        print('Error sending command: $e');
      }
    } else {
      print('Control characteristic not found or device not connected.');
    }
  }
  //
  Future<void> _refresh() async {
    await _startScan();
  }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Bluetooth Communication'),
  //     ),
  //     body: RefreshIndicator(
  //       onRefresh: _refresh,
  //       child: ListView(
  //         children: <Widget>[
  //           if (_scanResults.isNotEmpty) ...[
  //             if (_isScanning) ...[
  //               SizedBox(height: 20),
  //             ],
  //             ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: _scanResults.length,
  //               itemBuilder: (context, index) {
  //                 final result = _scanResults[index];
  //
  //                 // Skip devices without a name
  //                 if (result.device.name.isEmpty) {
  //                   return SizedBox.shrink();
  //                 }
  //
  //                 return ListTile(
  //                   title: Text(result.device.name),
  //                   subtitle: Text(result.device.id.toString()),
  //                   onTap: () {
  //                     _connectToDevice(result.device);
  //                     _stopScan();
  //                   },
  //                 );
  //               },
  //             ),
  //           ] else if (!_isScanning) ...[
  //             Center(child: Text('No devices found')),
  //           ],
  //           SizedBox(height: 20),
  //           if (_targetDevice != null)
  //             Text('Connected to: ${_targetDevice!.name} (${_targetDevice!.id})'),
  //           if (_controlCharacteristic != null) ...[
  //             SizedBox(height: 20),
  //             ElevatedButton(
  //               onPressed: () {
  //                 _sendCommand(_isDeviceOn ? 'DEVICE_OFF' : 'DEVICE_ON');
  //               },
  //               child: Text(_isDeviceOn ? 'Turn OFF' : 'Turn ON'),
  //             ),
  //             SizedBox(height: 20),
  //             Text('MTU: $_mtu bytes'),
  //             if (_batteryLevel != -1)
  //               Text('Battery Level: $_batteryLevel%'),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }
  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();

      String deviceName = '';
      String manufacturerName = '';
      String modelNumber = '';
      String serialNumber = '';
      String firmwareRevision = '';
      String hardwareRevision = '';
      String softwareRevision = '';
      String systemId = '';

      for (BluetoothService service in services) {
        print('Service UUID: ${service.uuid.toString()}');

        for (BluetoothCharacteristic characteristic in service.characteristics) {
          print('Characteristic UUID: ${characteristic.uuid.toString()}');

          // Read and display the device information based on UUID
          if (characteristic.uuid.toString() == "00002a00-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            deviceName = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a29-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            manufacturerName = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a24-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            modelNumber = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a25-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            serialNumber = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a26-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            firmwareRevision = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a27-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            hardwareRevision = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a28-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            softwareRevision = utf8.decode(value);
          }
          if (characteristic.uuid.toString() == "00002a23-0000-1000-8000-00805f9b34fb") {
            var value = await characteristic.read();
            systemId = utf8.decode(value);
          }

          // Check for battery level characteristic in Battery Service (UUID 0x180F)
          if (service.uuid.toString() == "0000180f-0000-1000-8000-00805f9b34fb") {
            print('Battery Service found');
            for (BluetoothCharacteristic characteristic in service.characteristics) {
              if (characteristic.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
                _readBatteryLevel(characteristic);
              }
            }
          }
        }
      }

      // Request MTU size
      _mtu = await device.requestMtu(512); // Request up to 512 bytes, depending on device support

      setState(() {
        _targetDevice = device; // Set the connected device
        _deviceName = deviceName;
        _manufacturerName = manufacturerName;
        _modelNumber = modelNumber;
        _serialNumber = serialNumber;
        _firmwareRevision = firmwareRevision;
        _hardwareRevision = hardwareRevision;
        _softwareRevision = softwareRevision;
        _systemId = systemId;
      });
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

}
