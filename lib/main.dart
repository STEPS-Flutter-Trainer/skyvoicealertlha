import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skyvoicealertlha/views/splash_screen.dart';
import 'package:upgrader/upgrader.dart';
import 'constants/app_theme.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return UpgradeAlert(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: HolyMicroTheme.themeData(),
            home:   SplashScreen(),
          ),
        );
      },
    );
  }
}

