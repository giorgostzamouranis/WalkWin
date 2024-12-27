import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_page.dart';
import 'dart:ui';
import 'package:flutter/services.dart';  // Import for TextInputFormatter

class ChallengeFriendPage extends StatefulWidget {
  const ChallengeFriendPage({Key? key}) : super(key: key);

  @override
  _ChallengeFriendPageState createState() => _ChallengeFriendPageState();
}

class _ChallengeFriendPageState extends State<ChallengeFriendPage> with SingleTickerProviderStateMixin {
  List<String> selectedFriends = [];
  late Future<List<Map<String, dynamic>>> friendsFuture;
  int stepsGoal = 0;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool showFriendsDialog = false;
  bool showStepsGoalDialog = false;

  @override
  void initState() {
    super.initState();
    friendsFuture = fetchFriends();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return [];
    }

    String userId = user.uid;
    print('Fetching friends for user: $userId');

    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!docSnapshot.exists) {
      print('User document does not exist');
      return [];
    }

    if (!docSnapshot.data()!.containsKey('friends')) {
      print('No friends field in user document');
      return [];
    }

    final List<dynamic> friends = docSnapshot.data()!['friends'];
    print('Friends list: $friends');

    List<Map<String, dynamic>> friendsList = [];
    for (String friendId in friends) {
      final friendSnapshot = await FirebaseFirestore.instance.collection('users').doc(friendId).get();
      if (friendSnapshot.exists) {
        friendsList.add({
          'id': friendId,
          'username': friendSnapshot.data()!['username'],
        });
      }
    }

    print('Fetched friends details: $friendsList');
    return friendsList;
  }

  Future<bool> hasActiveChallenge() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return false;
    }

    String userId = user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('active_friend_challenges')
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void storeChallengeParticipants() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return;
    }

    String userId = user.uid;
    // Include the user's ID in the participants list
    List<String> participants = List.from(selectedFriends);
    participants.add(userId);

    try {
      // Fetch initial daily steps for each participant
      Map<String, int> initialSteps = {};

      for (String participantId in participants) {
        var participantSnapshot = await FirebaseFirestore.instance.collection('users').doc(participantId).get();
        initialSteps[participantId] = participantSnapshot.data()!['dailySteps'] ?? 0;
      }

      // Create the challenge document for each participant
      for (String participantId in participants) {
        await FirebaseFirestore.instance.collection('users').doc(participantId).collection('active_friend_challenges').add({
          'createdBy': userId,
          'participants': participants,
          'stepsGoal': stepsGoal,
          'initialSteps': initialSteps[participantId],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      print('Challenge participants stored successfully');

      // Navigate to FriendsPage after storing the document
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FriendsPage()),
      );
    } catch (e) {
      print('Error storing challenge participants: $e');
    }
  }

  void toggleFriendsDialog() {
    setState(() {
      showFriendsDialog = !showFriendsDialog;
      if (showFriendsDialog) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void toggleStepsGoalDialog() {
    setState(() {
      showStepsGoalDialog = !showStepsGoalDialog;
      if (showStepsGoalDialog) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Button 1: Friends to Challenge
                ElevatedButton(
                  onPressed: toggleFriendsDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40), // Set button background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Colors.black, // Add bold border
                        width: 2.0,
                      ),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Friends to Challenge',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white, // Set button text color to white
                      fontWeight: FontWeight.bold, // Make button text bold
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Button 2: Set Challenges Goal
                ElevatedButton(
                  onPressed: toggleStepsGoalDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Set Challenge Goal',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white, // Set button text color to white
                      fontWeight: FontWeight.bold, // Make button text bold
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Winner's reward: 5",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black, // Set button text color to white
                        fontWeight: FontWeight.bold, // Make button text bold
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/icons/coin.png',
                      width: 30, // Set the width of the coin image
                      height: 30, // Set the height of the coin image
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Start Button
                ElevatedButton(
                  onPressed: () {
                    // Check if there is an active challenge before starting a new one
                    hasActiveChallenge().then((activeChallengeExists) {
                      if (activeChallengeExists) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Active Challenge'),
                            content: Text('There is already an activated challenge.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (stepsGoal == 0) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Invalid Steps Goal'),
                              content: Text('The steps goal must be greater than zero.'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          storeChallengeParticipants();
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellowAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Colors.black,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Set button text color to white
                      fontWeight: FontWeight.bold, // Make button text bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showFriendsDialog || showStepsGoalDialog)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          if (showFriendsDialog)
            SlideTransition(
              position: _offsetAnimation,
              child: Visibility(
                visible: showFriendsDialog,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Column(
                        children: [
                          AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: toggleFriendsDialog,
                            ),
                            backgroundColor: Colors.teal.shade700,
                            elevation: 0,
                            title: Text(
                              'Select Friends to Challenge',
                              style: TextStyle(color: Colors.white),
                            ),
                            centerTitle: true,
                          ),
                          Expanded(
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: friendsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('No friends found.');
                                } else {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        width: double.maxFinite,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: snapshot.data!.map((friend) {
                                            return CheckboxListTile(
                                              title: Text(friend['username']),
                                              value: selectedFriends.contains(friend['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedFriends.add(friend['id']);
                                                  } else {
                                                    selectedFriends.remove(friend['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              toggleFriendsDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showStepsGoalDialog)
            SlideTransition(
              position: _offsetAnimation,
              child: Visibility(
                visible: showStepsGoalDialog,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Column(
                        children: [
                          AppBar(
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: toggleStepsGoalDialog,
                            ),
                            backgroundColor: Colors.teal.shade700,
                            elevation: 0,
                            title: Text(
                              'Set Steps Goal',
                              style: TextStyle(color: Colors.white),
                            ),
                            centerTitle: true,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  TextField(
                                    // Ensure only numbers are accepted
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    controller: TextEditingController(text: stepsGoal > 0 ? stepsGoal.toString() : ''),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Enter steps goal',
                                    ),
                                    onChanged: (value) {
                                      stepsGoal = int.tryParse(value) ?? 0;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        stepsGoal = int.tryParse(TextEditingController(text: stepsGoal > 0 ? stepsGoal.toString() : '').text) ?? 0;
                                      });
                                      toggleStepsGoalDialog();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
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
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}