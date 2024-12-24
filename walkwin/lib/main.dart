import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:device_preview/device_preview.dart'; // Import DevicePreview
import 'screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/store_page.dart';
import 'screens/challenges_page.dart';
import 'screens/profile_page.dart';
import 'screens/step_goals_page.dart';
import 'screens/change_step_goals_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If Web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAASVkDIXTZ_LizUE_8bjvftPGCpFBu-ps",
        authDomain: "walkwin-5d102.firebaseapp.com",
        projectId: "walkwin-5d102",
        storageBucket: "walkwin-5d102.firebasestorage.app",
        messagingSenderId: "613299618395",
        appId: "1:613299618395:web:2d534c14cedd484e89757e",
        measurementId: "G-7R8J4RJMP2",
      ),
    );
  } else {
    // Default for mobile platforms
    await Firebase.initializeApp();
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Enable DevicePreview only in debug mode
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalkWin',
      locale: DevicePreview.locale(context), // Use DevicePreview's locale
      builder: DevicePreview.appBuilder, // Wrap widgets with DevicePreview
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/store': (context) => const StorePage(),
        '/challenges': (context) => const Challenges(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUpPage(),
        '/stepGoals': (context) => const StepGoalsPage(),
      },
    );
  }
}



/*
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/sign_in_page.dart'; // Make sure the ProfilePage is correctly imported.
import 'screens/welcome_page.dart';
import 'screens/sign_up_page.dart';


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
      home: const SignUpPage(), // Launch the ProfilePage
    );
  }
}
*/