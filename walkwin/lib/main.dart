import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Walk Win Home',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Function to open the Maps app
  Future<void> _openMaps() async {
    const String googleMapsUrl = "https://www.google.com/maps";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the Maps app';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Upper Section with Walcoins, Logo, Profile, and Map Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Walcoins Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Walcoins",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "00.00",
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Logo in the Center
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  // Profile and Map Button
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            const AssetImage('assets/images/profile.png'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Nikos_10",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Map Button
                      GestureDetector(
                        onTap: _openMaps,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/map.png', // Map icon
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Map",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BOOST STEPS Button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  icon: Image.asset(
                    'assets/images/bolt.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text(
                    "BOOST STEPS X2",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Steps Today Circular Indicator
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircularStepsWidget(
                    title: "Steps Today",
                    steps: "7.586",
                    size: 270,
                    titleFontSize: 20,
                    stepsFontSize: 30,
                    iconSize: 50,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      CircularStepsWidget(
                        title: "This Week",
                        steps: "13.789",
                        size: 180,
                        titleFontSize: 16,
                        stepsFontSize: 24,
                        iconSize: 40,
                      ),
                      CircularStepsWidget(
                        title: "This Month",
                        steps: "56.672",
                        size: 140,
                        titleFontSize: 12,
                        stepsFontSize: 18,
                        iconSize: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60, // Navigation bar height
        decoration: const BoxDecoration(
          color: Color(0xFF004D40),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NavButton(imagePath: 'assets/icons/home_nav.png', onTap: () {}),
            NavButton(imagePath: 'assets/icons/shop_nav.png', onTap: () {}),
            NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {}),
            NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const NavButton({Key? key, required this.imagePath, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, // Button width
        height: 50, // Button height
        decoration: BoxDecoration(
          color: Colors.white, // Button background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath, // Custom image from assets
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class CircularStepsWidget extends StatelessWidget {
  final String title;
  final String steps;
  final double size;
  final double titleFontSize;
  final double stepsFontSize;
  final double iconSize;

  const CircularStepsWidget({
    Key? key,
    required this.title,
    required this.steps,
    required this.size,
    this.titleFontSize = 14,
    this.stepsFontSize = 20,
    this.iconSize = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF004D40),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 0.7,
              color: Color(0xFF00E6B0),
              strokeWidth: size * 0.08,
              backgroundColor: Colors.transparent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                steps,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: stepsFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/steps.png',
                width: iconSize,
                height: iconSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
