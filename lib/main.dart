import 'package:countease/controllers/navigation_controller.dart';
import 'package:countease/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'services/db_service.dart';
import 'services/notification_service.dart';
import 'controllers/event_controller.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Hive database
  await DatabaseService.init();

  // Initialize notification service
  await NotificationService.init();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CountEaseApp());
}

class CountEaseApp extends StatefulWidget {
  const CountEaseApp({super.key});

  @override
  State<CountEaseApp> createState() => _CountEaseAppState();
}

class _CountEaseAppState extends State<CountEaseApp> {
  @override
  Widget build(BuildContext context) {
    // Initialize Controllers
    Get.put(EventController());
    Get.put(NavigationController());

    return GetMaterialApp(
      title: 'CountEase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: DatabaseService.getDarkMode()
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const SplashScreen(),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
