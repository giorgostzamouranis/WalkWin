
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/store_page.dart';
import 'screens/challenges_page.dart';

void main() {
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WalkWin',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/store': (context) => const StorePage(),
        '/challenges': (context) => const Challenges()
      },
    );
  }
}

