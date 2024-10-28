import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_settings_plus/core/open_settings_plus.dart';
import 'package:skyvoicealertlha/download-log/download-file-after-enable.dart';
import 'package:skyvoicealertlha/views/log-screen.dart';
import 'package:skyvoicealertlha/views/video_list_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:skyvoicealertlha/views/webview_screen.dart';
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:flutter/foundation.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

import '../download-log/api-controller.dart';
import '../download-log/get-files.dart';

//import 'bluetooth_button.dart';


class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  final GlobalKey webViewKey = GlobalKey();
  String _connectionStatus = 'Unknown';

  InAppWebViewController? webViewController;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final WifiInfo _wifiInfo = WifiInfo();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
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
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result!);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        try {
          if (!kIsWeb) {
            if (Platform.isIOS) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebInterface(),
                ),
              );
            } else {
              _showConnectWifiDialog();
              Navigator.of(context).pop();
            }
            if (Platform.isAndroid) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebInterface(),
                ),
              );
            } else {
              _showConnectWifiDialog();
              Navigator.of(context).pop();
            }
          }
        } on PlatformException catch (e) {
          print(e.toString());
        }

        break;

      case ConnectivityResult.mobile:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Connect Wifi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Roboto",
                ),
              ),
              content: const Text(
                "Please connect to 'SkyVoiceHolyMicro' or 'SkyVoiceAlert500'",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Roboto",
                ),
              ),
              actions: <Widget>[
                Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (Platform.isIOS) {
                          // Open iOS-specific Wi-Fi settings
                          const OpenSettingsPlusIOS().wifi();
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebInterface(),
                            ),
                          );
                        } else {
                          // Open Android-specific Wi-Fi settings
                          const OpenSettingsPlusAndroid().wifi();
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebInterface(),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Open Wi-Fi Settings',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF0C7C3C),
                        ),
                      ),
                    )),
              ],
            );
          },
        );
        break;
      case ConnectivityResult.none:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Connect Wifi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Roboto",
                ),
              ),
              content: const Text(
                "Please connect to 'SkyVoiceHolyMicro' or 'SkyVoiceAlert500'",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Roboto",
                ),
              ),
              actions: <Widget>[
                Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (Platform.isIOS) {
                          // Open iOS-specific Wi-Fi settings
                          const OpenSettingsPlusIOS().wifi();
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebInterface(),
                            ),
                          );
                        } else {
                          // Open Android-specific Wi-Fi settings
                          const OpenSettingsPlusAndroid().wifi();
                          Navigator.of(context).pop();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebInterface(),
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Open Wi-Fi Settings',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF0C7C3C),
                        ),
                      ),
                    )),
              ],
            );
          },
        );
        break;

      default:
        break;
    }
  }




  void _navigateToWebInterface() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebInterface(),
      ),
    );
  }


  void _showConnectWifiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Connect Wifi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Roboto",
            ),
          ),
          content: const Text(
            "Please connect to 'SkyVoiceHolyMicro' or 'SkyVoiceAlert500'",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Roboto",
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (Platform.isIOS) {
                    const OpenSettingsPlusIOS().wifi();
                  } else {
                    const OpenSettingsPlusAndroid().wifi();
                  }
                  Navigator.of(context).pop();
                  _navigateToWebInterface();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color(0xFF0C7C3C),
                  ),
                ),
                child: const Text(
                  'Open Wi-Fi Settings',
                  style: TextStyle(
                    fontFamily: "Roboto",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: const Size(360, 1200), minTextAdapt: true);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/image/bg.jpg', fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.only(top: isLandscape ? 20.h : 10.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Image.asset(
                        'assets/image/inner-logo.png',
                        width: isLandscape ? 100.w : 150.w,
                        height: isLandscape ? 40.h : 80.h,
                      ),
                    ),
                    Text(
                      "www.holymicro.com",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 5.sp : 15.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: isLandscape ? 5.sp : 15.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: isLandscape ? 4.w : 8.w),
                        Text(
                          "315-362-9820",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscape ? 5.sp : 15.sp,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "SkyVoice",
                      style: TextStyle(
                        fontFamily: "Roundkey",
                        fontSize: isLandscape ? 10.sp : 60.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w100,
                        color: const Color(0xFFF4EA12),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      "Holy Micro! LLC",
                      style: TextStyle(
                        fontFamily: "Roundkey",
                        fontSize: isLandscape ? 10.sp : 60.sp,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      "Version : 1.0.7",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLandscape ? 4.sp : 15.sp,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: isLandscape
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width,
                height: isLandscape
                    ? 600.h
                    : MediaQuery.of(context).size.height / 2.5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: isLandscape ? 0.h : 30.h),
                        child: SizedBox(
                          height: isLandscape ? 180.h : 100.h,
                          width: isLandscape
                              ? 200.w
                              : MediaQuery.of(context).size.width / 1.3,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF0C7C3C),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VideoList(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Introduction",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white,
                                    fontSize: isLandscape ? 8.sp : 25.sp,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Image.asset(
                                    'assets/image/arrow.png',
                                    height: isLandscape ? 30.h : 15.h,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? 30.h : 20.h),
                      Center(
                        child: SizedBox(
                          height: isLandscape ? 180.h : 100.h,
                          width: isLandscape
                              ? 200.w
                              : MediaQuery.of(context).size.width / 1.3,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF0C7C3C),
                              ),
                            ),
                            onPressed: () async {
                              await initConnectivity();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "SkyVoice Set Up",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white,
                                    fontSize: isLandscape ? 8.sp : 25.sp,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Image.asset(
                                    'assets/image/arrow.png',
                                    height: isLandscape ? 30.h : 15.h,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? 2.h : 20.h),
                      Center(
                        child: SizedBox(
                          height: isLandscape ? 180.h : 100.h,
                          width: isLandscape
                              ? 200.w
                              : MediaQuery.of(context).size.width / 1.3,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF0C7C3C),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  FileListScreen(),));
                           //   _apiController.handleRequests(context);
                            //  Navigator.push(context, MaterialPageRoute(builder: (context) =>  LogScreen(),));

                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Log Files",
                                  style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white,
                                    fontSize: isLandscape ? 8.sp : 25.sp,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Image.asset(
                                    'assets/image/arrow.png',
                                    height: isLandscape ? 30.h : 15.h,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ***********************************************
                      // Center(
                      //   child: SizedBox(
                      //     height: isLandscape ? 180.h : 100.h,
                      //     width: isLandscape
                      //         ? 200.w
                      //         : MediaQuery.of(context).size.width / 1.3,
                      //     child: ElevatedButton(
                      //       style: ButtonStyle(
                      //         backgroundColor: MaterialStateProperty.all<Color>(
                      //           const Color(0xFF0C7C3C),
                      //         ),
                      //       ),
                      //       onPressed: () {
                      //         // initBlueConnectivity();
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => BluetoothBatteryLevelScreen (),
                      //           ),
                      //         );
                      //       },
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text(
                      //             "Bluetooth Set Up",
                      //             style: TextStyle(
                      //               fontFamily: "Roboto",
                      //               color: Colors.white,
                      //               fontSize: isLandscape ? 8.sp : 25.sp,
                      //             ),
                      //           ),
                      //           Padding(
                      //             padding: EdgeInsets.only(left: 8.w),
                      //             child: Image.asset(
                      //               'assets/image/arrow.png',
                      //               height: isLandscape ? 30.h : 15.h,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // *****************************************************
                      // Center(
                      //   child: SizedBox(
                      //     height: isLandscape ? 180.h : 100.h,
                      //     width: isLandscape
                      //         ? 200.w
                      //         : MediaQuery.of(context).size.width / 1.3,
                      //     child: ElevatedButton(
                      //       style: ButtonStyle(
                      //         backgroundColor: MaterialStateProperty.all<Color>(
                      //           const Color(0xFF0C7C3C),
                      //         ),
                      //       ),
                      //       onPressed: () async {
                      //         // await initBLEConnectivity();
                      //
                      //         Navigator.push(
                      //                       context,
                      //                       MaterialPageRoute(
                      //                         builder: (context) => const BluetoothButtonSample(),
                      //                       ),
                      //                     );
                      //       },
                      //       child: Row(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         children: [
                      //           Text(
                      //             "Bluetooth Set Up",
                      //             style: TextStyle(
                      //               fontFamily: "Roboto",
                      //               color: Colors.white,
                      //               fontSize: isLandscape ? 8.sp : 25.sp,
                      //             ),
                      //           ),
                      //           Padding(
                      //             padding: EdgeInsets.only(left: 8.w),
                      //             child: Image.asset(
                      //               'assets/image/arrow.png',
                      //               height: isLandscape ? 30.h : 15.h,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: isLandscape ? 2.h : 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
