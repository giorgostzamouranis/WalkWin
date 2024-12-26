import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date and time handling
import 'package:pedometer/pedometer.dart';
import 'store_page.dart';
import 'challenges_page.dart';
import 'profile_page.dart';
import 'friends_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _stepsToday = 0;
  int _weeklySteps = 0;
  int _monthlySteps = 0;
  int _dailyGoal = 5000;
  double _progressToday = 0.0;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  Future<void> _initializeSteps() async {
    await _resetStepCountersIfNeeded(); // Reset steps if needed

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _dailyGoal = userDoc['dailyGoal'] ?? 5000;
          _stepsToday = userDoc['stepsToday'] ?? 0;
          _weeklySteps = userDoc['stepsWeek'] ?? 0;
          _monthlySteps = userDoc['stepsMonth'] ?? 0;
          _progressToday = _stepsToday / _dailyGoal;
        });
      }

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen((StepCount event) {
        _updateSteps(event.steps);
      });
    }
  }

  Future<void> _resetStepCountersIfNeeded() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekOfYear = int.parse(DateFormat('w').format(now));
    final month = DateFormat('yyyy-MM').format(now);

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    Map<String, dynamic> updates = {};

    // Daily Reset
    if (userDoc['lastDailyReset'] != today) {
      updates['stepsToday'] = 0;
      updates['lastDailyReset'] = today;
    }

    // Weekly Reset
    if (userDoc['lastWeeklyReset'] != weekOfYear.toString()) {
      updates['stepsWeek'] = 0;
      updates['lastWeeklyReset'] = weekOfYear.toString();
    }

    // Monthly Reset
    if (userDoc['lastMonthlyReset'] != month) {
      updates['stepsMonth'] = 0;
      updates['lastMonthlyReset'] = month;
    }

    if (updates.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(updates);
    }
  }

  Future<void> _updateSteps(int steps) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      setState(() {
        _stepsToday = steps;
        _progressToday = _stepsToday / _dailyGoal;
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'stepsToday': _stepsToday,
      });

      // Check and update challenges based on the steps
      await _checkAndUpdateChallenges(steps);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            _buildTopBar(),
            const SizedBox(height: 16),

            // Steps and Circular Widgets
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  CircularStepsWidget(
                    title: "Steps Today",
                    steps: _stepsToday.toString(),
                    size: 270,
                    titleFontSize: 20,
                    stepsFontSize: 30,
                    iconSize: 50,
                    progress: _progressToday.clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircularStepsWidget(
                        title: "This Week",
                        steps: _weeklySteps.toString(),
                        size: 180,
                        titleFontSize: 16,
                        stepsFontSize: 24,
                        iconSize: 40,
                        progress: (_weeklySteps / (_dailyGoal * 7)).clamp(0.0, 1.0),
                      ),
                      CircularStepsWidget(
                        title: "This Month",
                        steps: _monthlySteps.toString(),
                        size: 140,
                        titleFontSize: 12,
                        stepsFontSize: 18,
                        iconSize: 30,
                        progress: (_monthlySteps / (_dailyGoal * 30)).clamp(0.0, 1.0),
                      ),



/*
            /////////////////// TEST /////////////////

             ///////////// Add this button below the CircularStepsWidget in the body section
                      ElevatedButton(
                        onPressed: () {
                          incrementSteps(4000);  // Increase steps by 100
                        },
                        child: Text('Increase Steps by 4000'),
                      ),


*/






                    ],
                  ),
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
  // Get the current user's ID
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
      // StreamBuilder to listen to the coins value in Firestore
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
            // Get the coins from Firestore
            double coins = userData['coins'] ?? 0.0;

            return Text(
              coins.toStringAsFixed(2), // Display coins with two decimal points
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
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(returnPage: const HomePage()),
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
           onTap: ()
             {
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
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => page,
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
  }




/*

/////////// TEST INCREASE STEPS //////
// Function to simulate step increment
void incrementSteps(int incrementBy) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    // Get the current steps from Firestore
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    int currentSteps = 0;
    if (userDoc.exists) {
      currentSteps = userDoc['dailySteps'] ?? 0;  // Get current steps from Firestore (default to 0 if not available)
    }

    // Increment the steps by the specified value
    int newStepCount = currentSteps + incrementBy;

    // Update the Firestore document with the new step count
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'dailySteps': newStepCount,
    });

    // Update the local state to reflect the changes
    setState(() {
      _stepsToday = newStepCount;
      _progressToday = _stepsToday / _dailyGoal;
    });

    // You can also call _checkAndUpdateChallenges here if you'd like to check and update challenges right after increasing the steps
    await _checkAndUpdateChallenges(newStepCount);
  }
}


*/





}



////////////////////// This function checks the user's steps against the goals of their incomplete challenges. If the user meets the goal, it marks the challenge as completed and updates their total coins. /////////////////

Future<void> _checkAndUpdateChallenges(int steps) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) return;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!userDoc.exists) return;

  // Check if the user has completed any challenges
  final challengesSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('challenges')
      .where('completed', isEqualTo: false) // Only incomplete challenges
      .get();

  for (var doc in challengesSnapshot.docs) {
    var challenge = doc.data();
    if (steps >= challenge['goal']) {
      // Mark challenge as completed
      await doc.reference.update({
        'completed': true,
      });

      // Add coins to user's total
      double reward = challenge['reward'];
      double currentCoins = userDoc['coins'] ?? 0.0;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'coins': currentCoins + reward,
      });
    }
  }
}





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



