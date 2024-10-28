
// naviagation to Bluetooth setting page and BluetoothBatteryLevelScreen page...
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:skyvoicealertlha/views/skyvoice_connecting_cle.dart';

class BluetoothButtonSample extends StatefulWidget {
  const BluetoothButtonSample({super.key});

  @override
  State<BluetoothButtonSample> createState() =>
      _BluetoothButtonSampleState();
}

class _BluetoothButtonSampleState
    extends State<BluetoothButtonSample> {
  BluetoothDevice? connectedDevice;
  bool isBluetoothOn = true; // To track Bluetooth status
  String deviceName = "No device connected"; // To store connected device name

  @override
  void initState() {
    super.initState();
    // Automatically connect to the device when this screen is shown
    _connectToPreviouslyConnectedDevice();
  }

  Future<void> _connectToPreviouslyConnectedDevice() async {
    // Get the list of connected devices (or you can use any logic to find a device)
    List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;

    if (devices.isNotEmpty) {
      setState(() {
        connectedDevice = devices.first;
        deviceName = connectedDevice!.name; // Get the connected device's name
      });
    } else {
      setState(() {
        deviceName = "No device connected";
      });
    }
  }

  // Check if Bluetooth is on
  Future<void> checkBluetoothStatus() async {
    bool isOn = await FlutterBluePlus.isOn;
    setState(() {
      isBluetoothOn = isOn;

      if (isBluetoothOn) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            BluetoothCommunicatScreenDone(),
        )
        );
      }
    });

    if (!isBluetoothOn) {
      _showBluetoothSettingsDialog();
    }
  }


  void _showBluetoothSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth is Off'),
          content: const Text('Please connect with SkyVoice.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Open Bluetooth Settings'),
              onPressed: () {
                // Corrected method for opening Bluetooth settings
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Device"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   "Device Name: $deviceName",
            //   style: const TextStyle(fontSize: 24),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkBluetoothStatus,
              child: const Text("Check Bluetooth"),
            ),
          ],
        ),
      ),
    );
  }
}
// naviagation to Bluetooth setting page and BluetoothBatteryLevelScreen page...
