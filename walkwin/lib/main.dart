// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:device_preview/device_preview.dart'; // Import DevicePreview
import 'package:provider/provider.dart'; // <-- Import Provider

import 'step_tracker.dart'; // <-- Import StepTracker

// Import your screens
import 'screens/welcome_page.dart';
import 'screens/home_page.dart';
import 'screens/sign_in_page.dart';
import 'screens/sign_up_page.dart';
import 'screens/store_page.dart';
import 'screens/challenges_page.dart';
import 'screens/friends_page.dart';
import 'screens/incoming_friend_request_page.dart';
import 'screens/search_friends_page.dart';
import 'screens/friends_profile_page.dart';
import 'screens/friends_list_page.dart';
import 'screens/scan_friends_page.dart'; // <--- Make sure to import your QR Scan page
import 'screens/profile_page.dart';
import 'screens/step_goals_page.dart';
import 'screens/change_step_goals_page.dart';
import 'screens/story_view_page.dart';
import 'screens/challenge_friend_page.dart';
import 'screens/active_challenges_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for Web or Mobile
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
        measurementId: "YOUR_MEASUREMENT_ID",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Enable DevicePreview only in debug mode
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider<StepTracker>(
            create: (_) => StepTracker(),
          ),
          // Add other providers here if needed
        ],
        child: const MyApp(),
      ),
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
      // Use DevicePreview
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUpPage(),
        '/store': (context) => const StorePage(),
        '/challenges': (context) => const Challenges(),
        '/friends': (context) => const FriendsPage(),
        '/searchfriendspage': (context) => const SearchFriendsPage(),
        '/challengefriend': (context) => const ChallengeFriendPage(),
        '/activechallengefriend': (context) => const ActiveChallengesPage(),
        '/stepGoals': (context) => const StepGoalsPage(),
        '/view_story': (context) => StoryViewPage(
              stories: [],
              initialIndex: 0,
            ),
        '/scanFriends': (context) => const ScanFriendPage(), // <--- For QR scanning
      },
      // For any routes that need arguments, use onGenerateRoute
      onGenerateRoute: (settings) {
        if (settings.name == '/incomingFriendRequest') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('requesterData')) {
            throw Exception(
                "Missing requesterData for IncomingFriendRequestPage");
          }
          return MaterialPageRoute(
            builder: (context) => IncomingFriendRequestPage(
              requesterData: args['requesterData'],
            ),
          );
        } else if (settings.name == '/friendsprofilepage') {
          final user = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => FriendsProfilePage(user: user),
          );
        } else if (settings.name == '/friendslistpage') {
          final friends = settings.arguments as List<Map<String, dynamic>>;
          return MaterialPageRoute(
            builder: (context) => const FriendsListPage(),
          );
        }
        return null; // Return null for unknown routes
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