import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'welcome_page.dart'; 
import 'change_step_goals_page.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR code generation library


class Profile extends StatefulWidget {
  final Widget returnPage; // The page to return to

  const Profile({Key? key, required this.returnPage}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // List of avatar images (replace with your own images)
  final List<String> avatars = [
    'assets/images/Avatar1.png',
    'assets/images/Avatar2.png',
    'assets/images/Avatar3.png',
    'assets/images/Avatar4.png',
    
  ];

  // Method to update the user's avatar
  Future<void> _changeAvatar(String avatarPath) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'avatar': avatarPath,
    });
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Stack(
          children: [
            // Back arrow button
            Positioned(
              top: 2,
              left: 20,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous page in the stack
                },
              ),
            ),

            // Profile section with Avatar
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 50.0),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show loading spinner while data is loading
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('No user data');
                        }

                        // Get the avatar URL from Firestore, or use a default avatar
                        String avatarPath = snapshot.data!['avatar'] ?? 'assets/images/profile.png';

                        return SizedBox(
                          height: 100,
                          width: 150,
                          child: Image.asset(
                            avatarPath, // Use the avatar path from Firestore
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(
                      width: 200,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          // Show the avatar selection bottom sheet
                          _showAvatarSelection(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Change Avatar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right-side rectangular buttons (for other profile functionalities)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0, right: 20.0),
                child: Column(
                  children: [
                    // Fetch username from Firestore
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show loading spinner while data is loading
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text('No user data');
                        }

                        // Get the username from Firestore
                        String username = snapshot.data!['username'] ?? 'No Username';

                        return Container(
                          width: 180,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004D40),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              username, // Display the dynamic username
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        final username = FirebaseAuth.instance.currentUser?.displayName ?? "No Username";
                        showQrOverlay(context, username);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                      ),
                      child: const Text(
                        "My QR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Logout button
                    SizedBox(
                      width: 150,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Sign out the user
                          await FirebaseAuth.instance.signOut();

                          // Navigate to the welcome page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => WelcomePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings section
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      "SETTINGS",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Notifications button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.notifications, size: 35, color: Colors.white),
                            Text(
                              "Notifications",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.navigate_next, size: 35, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Change Steps Goal button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  ChangeStepGoalsPage(returnPage: widget), // Use 'widget' here
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final easeOutCurve = Curves.easeOut;
                                final slideInAnimation = Tween<Offset>(
                                  begin: const Offset(1, 0), // Start from the right
                                  end: Offset.zero, // Move to the original position
                                ).animate(CurvedAnimation(parent: animation, curve: easeOutCurve));

                                return SlideTransition(
                                  position: slideInAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.score, size: 35, color: Colors.white),
                            Text(
                              "Change Steps Goal",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.navigate_next, size: 35, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Other Settings button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.settings, size: 35, color: Colors.white),
                            Text(
                              "Other Settings",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.navigate_next, size: 35, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show avatar selection bottom sheet
  void _showAvatarSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Column(
            children: [
              const Text(
                "Select an Avatar",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatars.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Update the avatar when tapped
                        _changeAvatar(avatars[index]);
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Image.asset(
                          avatars[index],
                          width: 80,
                          height: 80,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showQrOverlay(BuildContext context, String username) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    barrierLabel: 'Close',
    barrierColor: const Color(0xFF008374).withOpacity(0.73), // Transparent overlay
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation1, animation2) {
      return const SizedBox();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ));

      return SlideTransition(
        position: offsetAnimation,
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pop(context); // Close the overlay
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "SCAN ME!" text box above the QR code
                  Container(
                    width: 157,
                    height: 63,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004D40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "SCAN ME!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // QR Code box
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the QR code
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomPaint(
                      painter: QrPainter(
                        data: username,
                        version: QrVersions.auto,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ), 
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

