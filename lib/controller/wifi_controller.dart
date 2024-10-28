import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import '../views/welcome_screen.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final WifiInfo _wifiInfo = WifiInfo();

  Future<void> checkWifiAvailability() async {
    ConnectivityResult? result;
    try {
      List<ConnectivityResult> connectivityResults =
          await _connectivity.checkConnectivity();
      if (connectivityResults.isNotEmpty) {
        result = connectivityResults.first;
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (result != null) {
      _updateConnectionStatus(result);
    } else {
      // Handle the case where connectivity check fails (optional)
      print('Failed to get connectivity status');
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          wifiName = (await _wifiInfo.getWifiName())!;
          if (wifiName != "SkyVoiceAlert500") {
            _showConnectWifiDialog();

          } else {
            final Uri _url = Uri.parse('http://192.168.20.1');
            if (!await launchUrl(
              _url,
              mode: LaunchMode.inAppBrowserView,
            )) {
              throw Exception('Could not launch $_url');
            }
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          wifiBSSID = (await _wifiInfo.getWifiBSSID())!;
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = (await _wifiInfo.getWifiIP())!;
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        break;

      case ConnectivityResult.mobile:
        _showConnectWifiDialog();
        break;

      case ConnectivityResult.none:
        _showConnectWifiDialog();
        break;

      default:
        // Handle other connectivity results if needed
        break;
    }
  }

  void _showConnectWifiDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect Wifi'),
          content: const Text("Please connect to 'SkyVoiceAlert500'"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (Platform.isIOS) {
                  const OpenSettingsPlusIOS().wifi();
                } else {
                  const OpenSettingsPlusAndroid().wifi();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Open Wi-Fi Settings'),
            ),
          ],
        );
      },
    );
  }
}
