import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'authentication/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Request location permission if not granted
  await _requestLocationPermission();

  runApp(const MyApp());
}

// Function to handle location permission requests
Future<void> _requestLocationPermission() async {
  final status = await Permission.locationWhenInUse.status;
  if (status.isDenied) {
    // Request permission if it's denied
    final result = await Permission.locationWhenInUse.request();
    if (result.isGranted) {
      print("Location permission granted");
    } else if (result.isPermanentlyDenied) {
      // Handle permanently denied permission (optional)
      print("Location permission permanently denied. Please enable it in settings.");
      // Optionally, redirect the user to the app settings
      openAppSettings();
    }
  } else if (status.isGranted) {
    print("Location permission already granted");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}
