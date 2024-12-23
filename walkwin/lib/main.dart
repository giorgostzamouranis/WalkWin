/*
import 'screens/challenges_page.dart';
import 'screens/profile_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/sign_in_page.dart';


void main() {
  runApp(
    DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),);
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalkWin',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/store': (context) => const StorePage(),
        '/challenges': (context) => const Challenges(),
        '/profile': (context) => const Profile(),
        '/signin': (context) => const SignIn()
      },
    );
  }
}

*/

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/sign_in_page.dart'; // Make sure the ProfilePage is correctly imported.

void main() {
  runApp(
    DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => MyApp(), // Wrap your app
  ),);
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SignIn(), // Launch the ProfilePage
    );
  }
}
