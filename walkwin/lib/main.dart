import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Upper Section with Walcoins, Logo, and Profile
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
                  // Profile Section
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
      // Custom Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 60, // Reduced height to avoid overflow
        decoration: const BoxDecoration(
          color: Color(0xFF004D40), // Dark green background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavButton(imagePath: 'assets/icons/home_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/shop_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _NavButton({Key? key, required this.imagePath, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, // Slightly reduced width
        height: 50, // Slightly reduced height
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
            imagePath, // Load custom image
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
          // Inner Circle - Solid Color (#004D40)
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF004D40), // Inner Circle Color
              shape: BoxShape.circle,
            ),
          ),

          // Circular Progress Bar
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 0.7, // Progress value
              color: Color(0xFF00E6B0), // Progress Bar Color
              strokeWidth: size * 0.08,
              backgroundColor: Colors.transparent,
            ),
          ),

          // Centered Content
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
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}