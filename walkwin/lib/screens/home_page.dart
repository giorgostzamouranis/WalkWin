import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'store_page.dart';
import 'challenges_page.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';




class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _openMaps(BuildContext context) async {
    final geoUrl = Uri.parse('geo:0,0');
    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else {
      final googleMapsUrl = Uri.parse('comgooglemaps://');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        final webUrl = Uri.parse('https://www.google.com/maps');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps.')),
          );
        }
      }
    }
  }

///////////////// Upper Bar //////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Walcoins
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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

                  // Logo
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),

                  // Profile
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading spinner while data is loading
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text('No user data');
                      }

                      // Get the username and avatar from Firestore
                      String username = snapshot.data!['username'] ?? 'No Username';
                      String avatarPath = snapshot.data!['avatar'] ?? 'assets/images/profile.png'; // Default avatar if none exists

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 300),
                                  reverseTransitionDuration: const Duration(milliseconds: 300),
                                  pageBuilder: (context, animation, secondaryAnimation) => Profile(returnPage: const HomePage()),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    final easeOutCurve = Curves.easeOut;
                                    final slideInAnimation = Tween<Offset>(
                                      begin: const Offset(0, 1), // Start from below
                                      end: Offset.zero, // Move to original position
                                    ).animate(CurvedAnimation(parent: animation, curve: easeOutCurve));

                                    return SlideTransition(
                                      position: slideInAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(avatarPath), // Dynamically set the avatar from Firestore
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            username,  // Display the username dynamically
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),

                ],
              ),
            ),
            const SizedBox(height: 16),

            ///////////// Buttons Row //////////////////

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _openMaps(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E6B0),
                          fixedSize: const Size(60, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Image.asset(
                          'assets/icons/map.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Steps and Circular Widgets
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const CircularStepsWidget(
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

      /////////Navigation bar////////////

      bottomNavigationBar: Container(
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
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => const StorePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeOut;
                      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

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
            _NavButton(imagePath: 'assets/icons/target_nav.png', 
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => const  Challenges(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeOut;
                      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

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
            _NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }
}









/////////////////  Circular Widget  /////////////////

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






/////////////////  NavButton Widget  /////////////////

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