import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'store_page.dart';
import 'home_page.dart';
import 'friends_page.dart'; 

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  _ChallengesState createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  late Stream<QuerySnapshot> _challengesStream;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  void _loadChallenges() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _challengesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .snapshots();
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildWalcoins(),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          _buildProfile(),
        ],
      ),
    );
  }

  Widget _buildWalcoins() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
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
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.hasData) {
              var userData = snapshot.data!;
              double coins = userData['coins'] ?? 0.0;

              return Text(
                coins.toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Text('No Data');
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('No user data');
        }

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
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(returnPage: const Challenges()),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildTopBar(),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
  stream: _challengesStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('No challenges available.'));
    }

    final challenges = snapshot.data!.docs;

    return ListView.builder(
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        final title = challenge['title'];
        final reward = challenge['reward'].toString();
        final goal = challenge['goal'].toString();
        final isCompleted = challenge['completed'] ?? false;
        final description = challenge['description'] ?? 'No description provided'; // Get the description

        return ChallengeCard(
          title: title,
          reward: reward,
          goal: goal,
          isCompleted: isCompleted,
          description: description,  // Pass the description
          onTap: () {},
        );
      },
    );
  },
)

            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
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
                        position: Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(curvedAnimation),
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
                        position: Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(curvedAnimation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/friend_nav.png',
             onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) => const FriendsPage(),
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
          ],
        ),
      ),
    );
  }
}

// ChallengeCard Widget
class ChallengeCard extends StatelessWidget {
  final String title;
  final String reward;
  final String goal;
  final bool isCompleted;
  final String description;  // Add description field
  final VoidCallback onTap;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.reward,
    required this.goal,
    required this.isCompleted,
    required this.description,  // Receive description
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and checkmark if completed
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (isCompleted) 
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Goal
              Text(
                'Goal: $goal steps',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Reward
Row(
                children: [
                  Text(
                    '$reward',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),

                  Image.asset(
                    'assets/icons/coin.png',  // Use the coin asset
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  
                  
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 3,  // Limit to 3 lines, expand with ellipsis if too long
                overflow: TextOverflow.ellipsis,
              ),
              if (isCompleted) 
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// NavButton Widget
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
