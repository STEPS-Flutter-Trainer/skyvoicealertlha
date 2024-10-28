// import 'dart:async';
// import 'dart:io';
//
// import 'package:connectivity_plus/connectivity_plus.dart'
//     show Connectivity, ConnectivityResult;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:open_settings_plus/core/open_settings_plus.dart';
// import 'package:skyvoicealertlha/views/welcome_screen.dart';
// import 'package:wifi_info_flutter/wifi_info_flutter.dart';
//
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   String _connectionStatus = 'Unknown';
//   final Connectivity _connectivity = Connectivity();
//   final WifiInfo _wifiInfo = WifiInfo();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     initConnectivity();
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
//       // Handle connectivity changes here
//     });
//   }
//
//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initConnectivity() async {
//     ConnectivityResult? result;
//     try {
//       List<ConnectivityResult> connectivityResults = await _connectivity.checkConnectivity();
//       if (connectivityResults.isNotEmpty) {
//         result = connectivityResults.first;
//       }
//     } on PlatformException catch (e) {
//       print(e.toString());
//     }
//     if (!mounted) {
//       return Future.value(null);
//     }
//
//     return _updateConnectionStatus(result!);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(context,
//         designSize: const Size(360, 690),
//         minTextAdapt: true,
//         splitScreenMode: true);
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           //Background Image
//           Image.asset(
//             'assets/image/splash.jpg', // Path to your image file
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Future<void> _updateConnectionStatus(ConnectivityResult result) async {
//     switch (result) {
//       case ConnectivityResult.wifi:
//         String wifiName, wifiBSSID, wifiIP;
//
//         try {
//           if (!kIsWeb && Platform.isIOS) {
//             LocationAuthorizationStatus status =
//             await _wifiInfo.getLocationServiceAuthorization();
//             if (status == LocationAuthorizationStatus.notDetermined) {
//               status =
//               await _wifiInfo.requestLocationServiceAuthorization();
//             }
//             if (status == LocationAuthorizationStatus.authorizedAlways ||
//                 status == LocationAuthorizationStatus.authorizedWhenInUse) {
//               wifiName = (await _wifiInfo.getWifiName()) ?? ""; // Use null-aware operator and handle null case
//               if (wifiName == "SkyVoiceAlert500") {
//                 // Navigate to the welcome page after a delay
//                print("Connected");
//               }
//               else {
//                 _showConnectWifiDialog();
//               }
//             } else {
//               wifiName = (await _wifiInfo.getWifiName()) ?? ""; // Use null-aware operator and handle null case
//
//             }
//
//           } else {
//             wifiName = (await _wifiInfo.getWifiName()) ?? ""; // Use null-aware operator and handle null case
//           }
//         } on PlatformException catch (e) {
//           print(e.toString());
//           wifiName = "Failed to get Wifi Name";
//         }
//
//         try {
//
//           wifiBSSID = (await _wifiInfo.getWifiBSSID())?? "";
//         } on PlatformException catch (e) {
//           print(e.toString());
//           wifiBSSID = "Failed to get Wifi BSSID";
//         }
//
//         try {
//           wifiIP = (await _wifiInfo.getWifiIP())!;
//         } on PlatformException catch (e) {
//           print(e.toString());
//           wifiIP = "Failed to get Wifi IP";
//         }
//
//         setState(() {
//           _connectionStatus = '$result\n'
//               'Wifi Name: $wifiName\n'
//               'Wifi BSSID: $wifiBSSID\n'
//               'Wifi IP: $wifiIP\n';
//         });
//         break;
//
//       case ConnectivityResult.mobile:
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Connect Wifi'),
//               content: const Text(
//                   "Please connect to 'SkyVoiceAlert500' and restart your app "),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     if (Platform.isIOS) {
//                       // Open iOS-specific Wi-Fi settings
//                       const OpenSettingsPlusIOS().wifi();
//                     } else {
//                       // Open Android-specific Wi-Fi settings
//                       const OpenSettingsPlusAndroid().wifi();
//                     }
//                     Future.delayed(const Duration(seconds: 2), () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => WelcomePage()));
//                     });
//                     //Navigator.of(context).pop();
//                   },
//                   child: const Text('Open Wi-Fi Settings'),
//                 ),
//               ],
//             );
//           },
//         );
//         break;
//       case ConnectivityResult.none:
//       // Show alert dialog to connect to 'SkyVoiceAlert500'
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Connect Wifi'),
//               content: const Text(
//                   "Please connect to 'SkyVoiceAlert500' and restart your app "),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     if (Platform.isIOS) {
//                       // Open iOS-specific Wi-Fi settings
//                       const OpenSettingsPlusIOS().wifi();
//                     } else {
//                       // Open Android-specific Wi-Fi settings
//                       const OpenSettingsPlusAndroid().wifi();
//                     }
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('Open Wi-Fi Settings'),
//                 ),
//               ],
//             );
//           },
//         );
//         break;
//
//       default:
//         setState(() => _connectionStatus = 'Failed to get connectivity.');
//         break;
//     }
//   }
//   void _showConnectWifiDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Connect Wifi'),
//           content: const Text("Please connect to 'SkyVoiceAlert500' and restart your app "),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 if (Platform.isIOS) {
//                   const OpenSettingsPlusIOS().wifi();
//                 } else {
//                   const OpenSettingsPlusAndroid().wifi();
//                 }
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Open Wi-Fi Settings'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skyvoicealertlha/views/welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
      Duration(seconds: 2),
      () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomePage(),
            ),
            (route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          //Background Image
          Image.asset(
            'assets/image/splash.jpg', // Path to your image file
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
