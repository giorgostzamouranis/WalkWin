
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_page.dart';
import 'active_challenges_page.dart';
import 'dart:ui';
import 'package:flutter/services.dart'; 

class ChallengeFriendPage extends StatefulWidget {
  const ChallengeFriendPage({Key? key}) : super(key: key);

  @override
  _ChallengeFriendPageState createState() => _ChallengeFriendPageState();
}

class _ChallengeFriendPageState extends State<ChallengeFriendPage>
    with SingleTickerProviderStateMixin {
  List<String> selectedFriends = [];
  late Future<List<Map<String, dynamic>>> friendsFuture;
  String challengeName = '';
  int stepsGoal = 0;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool showFriendsDialog = false;
  bool showDetailsDialog = false;

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

    final docSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

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
      final friendSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(friendId).get();
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

  void storeChallengeParticipants(String challengeName, int stepsGoal) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return;
    }

    String userId = user.uid;
    // Include the user's ID in the participants list
    List<String> participants = List.from(selectedFriends);
    participants.add(userId); // Ensure the creator is included

    try {
      // Prepare steps data for each participant
      Map<String, dynamic> stepsData = {};
      for (String participantId in participants) {
        stepsData[participantId] = 0; // Initialize steps to 0
      }

      // Create the challenge document in 'active_challenges' collection
      DocumentReference challengeRef =
          FirebaseFirestore.instance.collection('active_challenges').doc();

      await challengeRef.set({
        'challengeName': challengeName,
        'stepsGoal': stepsGoal,
        'participants': participants,
        'steps': stepsData, // Tracks steps per participant
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'winnerReward': 5.0, 
      });

      print('Challenge stored successfully with ID: ${challengeRef.id}');

      // Add this challenge to each participant's active challenges
      for (String participantId in participants) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(participantId)
            .collection('active_friend_challenges')
            .doc(challengeRef.id)
            .set({
          'challengeName': challengeName,
          'stepsGoal': stepsGoal,
          'participants': participants,
          'steps': 0, 
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'winnerReward': 5.0, 
        });
      }



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error storing challenge participants: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating challenge: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  void toggleDetailsDialog() {
    setState(() {
      showDetailsDialog = !showDetailsDialog;
      if (showDetailsDialog) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void showSetChallengeDetailsDialog() {
    final _formKey = GlobalKey<FormState>();
    String tempChallengeName = '';
    String tempStepsGoal = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Challenge Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Set Challenge Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Set Challenge Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      tempChallengeName = value.trim();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a challenge name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // Set Steps Goal
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Set Steps Goal',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      tempStepsGoal = value.trim();
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a steps goal';
                      }
                      if (int.tryParse(value.trim()) == null ||
                          int.parse(value.trim()) <= 0) {
                        return 'Please enter a valid number greater than zero';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Check for duplicate challenges
                  bool duplicateExists =
                      await checkForDuplicateChallenges(tempChallengeName);

                  if (duplicateExists) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'A challenge with this name already exists in your active challenges.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    storeChallengeParticipants(
                        tempChallengeName, int.parse(tempStepsGoal));
                    Navigator.of(context).pop(); 
                  }
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
        );
      },
    );
  }

  Future<bool> checkForDuplicateChallenges(String challengeName) async {
    // Fetch all active challenges of the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return false;
    }

    String userId = user.uid;

    QuerySnapshot userChallengesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('active_friend_challenges')
        .where('challengeName', isEqualTo: challengeName)
        .get();

    if (userChallengesSnapshot.docs.isNotEmpty) {
      // A challenge with the same name exists
      return true;
    }

    return false;
  }


  void showSetChallengeDetails() {
    if (selectedFriends.isEmpty) {
      // Show error if no friends selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one friend to challenge.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show the Set Challenge Details Dialog
    showSetChallengeDetailsDialog();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool canStartChallenge =
        selectedFriends.isNotEmpty && challengeName.isNotEmpty && stepsGoal > 0;

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // button Friends to Challenge
                  ElevatedButton(
                    onPressed: toggleFriendsDialog,
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
                      'Friends to Challenge',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Button to Set Challenge Details
                  ElevatedButton(
                    onPressed: showSetChallengeDetails,
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
                      'Set Challenge Details',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
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
                          color: Colors.black, 
                          fontWeight: FontWeight.bold, 
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset(
                        'assets/icons/coin.png',
                        width: 30, 
                        height: 30, 
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Start Button
                  ElevatedButton(
                    onPressed: () async {
                      if (!canStartChallenge) {
                        // Show error if prerequisites are not met
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Please select friends and set challenge details before starting.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Check if there is an active challenge before starting a new one
                      bool activeChallengeExists = await hasActiveChallenge();
                      if (activeChallengeExists) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Active Challenge'),
                            content: Text(
                                'There is already an active challenge. Please complete it before starting a new one.'),
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
                        // Navigate to Active Challenges Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ActiveChallengesPage()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canStartChallenge
                          ? Colors.yellowAccent
                          : Colors.grey, // Disable color if not ready
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black, 
                        fontWeight: FontWeight.bold, 
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showFriendsDialog)
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
                              icon:
                                  Icon(Icons.arrow_back, color: Colors.black),
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
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Text(
                                    'No friends found.',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  );
                                } else {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        width: double.maxFinite,
                                        child: ListView(
                                          shrinkWrap: true,
                                          children:
                                              snapshot.data!.map((friend) {
                                            return CheckboxListTile(
                                              title: Text(friend['username']),
                                              value: selectedFriends
                                                  .contains(friend['id']),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    selectedFriends
                                                        .add(friend['id']);
                                                  } else {
                                                    selectedFriends
                                                        .remove(friend['id']);
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
        ],
      ),
    );
  }
}
