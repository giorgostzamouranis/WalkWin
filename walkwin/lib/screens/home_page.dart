// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../step_tracker.dart'; // <-- Import StepTracker

// Import your other screens
import 'store_page.dart';
import 'challenges_page.dart';
import 'profile_page.dart';
import 'friends_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access StepTracker via Provider
    final stepTracker = Provider.of<StepTracker>(context);

    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            _buildTopBar(context),
            const SizedBox(height: 16),

            // Steps and Circular Widgets
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircularStepsWidget(
                    title: "Steps Today",
                    steps: stepTracker.stepsToday.toString(),
                    size: 270,
                    titleFontSize: 20,
                    stepsFontSize: 30,
                    iconSize: 50,
                    progress: stepTracker.progressToday.clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 16),




//////////////////////  TEST BUTTON TO ADD STEPS MANUALLY  //////////////////////
                  Center(
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        incrementSteps(context, 4000); // Increase steps by 4000
                      },
                      backgroundColor: Colors.white, // Background color of the button
                      elevation: 4,
                      label: const Text("Increase steps by 4000"),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircularStepsWidget(
                        title: "This Week",
                        steps: stepTracker.weeklySteps.toString(),
                        size: 180,
                        titleFontSize: 16,
                        stepsFontSize: 24,
                        iconSize: 40,
                        progress: (stepTracker.weeklySteps /
                                (stepTracker.dailyGoal * 7))
                            .clamp(0.0, 1.0),
                      ),
                      CircularStepsWidget(
                        title: "This Month",
                        steps: stepTracker.monthlySteps.toString(),
                        size: 140,
                        titleFontSize: 12,
                        stepsFontSize: 18,
                        iconSize: 30,
                        progress: (stepTracker.monthlySteps /
                                (stepTracker.dailyGoal * 30))
                            .clamp(0.0, 1.0),
                      ),

                  ],
                        ),
                        const SizedBox(height: 16), // Spacing between Row and Button
                        // Center the button below the circular widgets

                       
                      ],
                    ),
                  ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildWalcoins(context),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          _buildProfile(context),
        ],
      ),
    );
  }

  Widget _buildWalcoins(BuildContext context) {
    // Get the current user's ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Walcoins",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            'assets/icons/coin.png',
            fit: BoxFit.contain,
          ),
        ),
        // StreamBuilder to listen to the coins value in Firestore
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              var userData = snapshot.data!;
              // Get the coins from Firestore
              double coins = (userData['coins'] as num?)?.toDouble() ?? 0.0;

              return Text(
                coins.toStringAsFixed(2), // Display coins with two decimal points
                style: const TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return const Text('No Data');
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfile(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('No user data');
        }

        String username = snapshot.data!['username'] ?? 'No Username';
        String avatarPath =
            snapshot.data!['avatar'] ?? 'assets/images/Avatar1.png';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Profile(returnPage: const HomePage()),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatarPath),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              username,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF004D40),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavButton(
            imagePath: 'assets/icons/home_nav.png',
            onTap: () {},
          ),
          _NavButton(
            imagePath: 'assets/icons/shop_nav.png',
            onTap: () => _navigateTo(context, const StorePage()),
          ),
          _NavButton(
            imagePath: 'assets/icons/target_nav.png',
            onTap: () => _navigateTo(context, const Challenges()),
          ),
          _NavButton(
            imagePath: 'assets/icons/friend_nav.png',
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const FriendsPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeOut;
                    final curvedAnimation =
                        CurvedAnimation(parent: animation, curve: curve);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeOut;
          final curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }

  /////////// TEST INCREASE STEPS ////////
  // Function to simulate step increment
  Future<void> incrementSteps(BuildContext context, int incrementBy) async {
    final stepTracker = Provider.of<StepTracker>(context, listen: false);
    await stepTracker.addSteps(incrementBy); // Use the public method
  }
}

/// Custom Widget to display circular step counts
class CircularStepsWidget extends StatelessWidget {
  final String title;
  final String steps;
  final double size;
  final double titleFontSize;
  final double stepsFontSize;
  final double iconSize;
  final double progress;

  const CircularStepsWidget({
    Key? key,
    required this.title,
    required this.steps,
    required this.size,
    this.titleFontSize = 14,
    this.stepsFontSize = 20,
    this.iconSize = 30,
    required this.progress,
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
              value: progress,
              color: const Color(0xFF00E6B0),
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
                'assets/icons/steps.png',
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

/// Custom Navigation Button Widget
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
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
