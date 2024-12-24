import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'store_page.dart';
import 'profile_page.dart';
import 'home_page.dart';
import 'challenges_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false; // Track if the user is searching

  // Function to perform search
  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false; // Reset searching state when query is empty
      });
      return;
    }

    setState(() {
      _isSearching = true; // Set searching state when the user starts typing
    });

    // Query Firestore for matching users
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    // Map the results
    setState(() {
      _searchResults = snapshot.docs.map((doc) {
        return {
          'username': doc['username'],
          'avatar': doc['avatar'] ?? 'assets/images/profile.png',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Upper bar (your existing work)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text('No user data');
                          }

                          // Get the username and avatar from Firestore
                          String username = snapshot.data!['username'] ?? 'No Username';
                          String avatarPath = snapshot.data!['avatar'] ?? 'assets/images/profile.png';

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
                                  pageBuilder: (context, animation, secondaryAnimation) => Profile(returnPage: const Challenges()),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    final easeOutCurve = Curves.easeOut;
                                    final slideInAnimation = Tween<Offset>(
                                      begin: const Offset(0, 1),
                                      end: Offset.zero,
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
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search users by username",
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey.shade700),
                      ),
                      onChanged: (value) {
                        _searchUsers(value.trim());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Search Results
                Expanded(
                  child: _isSearching
                      ? (_searchResults.isEmpty
                          ? Center(
                              child: Text(
                                "No users found",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final user = _searchResults[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(user['avatar']),
                                  ),
                                  title: Text(
                                    user['username'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    // Navigate to user's profile or perform an action
                                    print("Selected: ${user['username']}");
                                  },
                                );
                              },
                            ))
                      : Container(),
                ),
              ],
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar (your existing code)
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
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeOut;
                      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                            .animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
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
                        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                            .animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            _NavButton(
              imagePath: 'assets/icons/target_nav.png',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => const Challenges(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const curve = Curves.easeOut;
                      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
                            .animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            _NavButton(
              imagePath: 'assets/icons/friend_nav.png',
              onTap: () {
                // Placeholder for friend navigation
              },
            ),
          ],
        ),
      ),
    );
  }
}

// NavButton Widget
class _NavButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _NavButton({Key? key, required this.imagePath, required this.onTap}) : super(key: key);

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
