import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class ActiveChallengesPage extends StatefulWidget {
  const ActiveChallengesPage({Key? key}) : super(key: key);

  @override
  _ActiveChallengesPageState createState() => _ActiveChallengesPageState();
}

class _ActiveChallengesPageState extends State<ActiveChallengesPage>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> activeChallengesFuture;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool showParticipants = false;
  List<Map<String, dynamic>> selectedChallengeParticipants = [];
  String selectedChallengeName = '';
  int selectedChallengeStepsGoal = 0;

  @override
  void initState() {
    super.initState();
    activeChallengesFuture = fetchActiveChallenges();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
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


  Future<List<Map<String, dynamic>>> fetchActiveChallenges() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return [];
    }

    String userId = user.uid;

    try {
      QuerySnapshot challengesSnapshot = await FirebaseFirestore.instance
          .collection('active_challenges')
          .where('participants', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> challenges = [];

      for (var doc in challengesSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String challengeId = doc.id;
        String challengeName = data['challengeName'] ?? 'No Name';
        int stepsGoal = data['stepsGoal'] ?? 0;
        List<String> participants = List<String>.from(data['participants'] ?? []);

        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        int userDailySteps = 0;
        if (userSnapshot.exists) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          print('User Data for $userId: $userData'); 

          if (userData.containsKey('dailySteps')) {
            var stepsField = userData['dailySteps'];
            if (stepsField is int) {
              userDailySteps = stepsField;
            } else if (stepsField is double) {
              userDailySteps = stepsField.toInt();
            } else {
              print('Unexpected type for dailySteps field: ${stepsField.runtimeType}');
            }
          } else {
            print('No "dailySteps" field found for userId: $userId');
          }
        } else {
          print('User document does not exist for userId: $userId');
        }

        challenges.add({
          'challengeId': challengeId,
          'challengeName': challengeName,
          'stepsGoal': stepsGoal,
          'steps': userDailySteps, 
          'participants': participants,
        });
      }

      print('Fetched active challenges: $challenges'); 
      return challenges;
    } catch (e) {
      print('Error fetching active challenges: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching active challenges: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }


  void toggleParticipantsOverlay(
      String challengeId, String challengeName, int stepsGoal) async {
    if (challengeId.isEmpty) return;

    try {

      DocumentSnapshot challengeSnapshot = await FirebaseFirestore.instance
          .collection('active_challenges')
          .doc(challengeId)
          .get();

      if (!challengeSnapshot.exists) {
        print('Challenge document does not exist');
        return;
      }

      var challengeData = challengeSnapshot.data() as Map<String, dynamic>;
      List<String> participants = List<String>.from(challengeData['participants'] ?? []);

      List<Map<String, dynamic>> participantsDetails = [];

      List<Future<Map<String, dynamic>>> fetchUserFutures = participants.map((participantId) async {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(participantId)
            .get();

        if (userSnapshot.exists) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          String username = userData['username'] ?? 'Unknown';
          int participantDailySteps = 0;

          if (userData.containsKey('dailySteps')) {
            var stepsField = userData['dailySteps'];
            if (stepsField is int) {
              participantDailySteps = stepsField;
            } else if (stepsField is double) {
              participantDailySteps = stepsField.toInt();
            } else {
              print('Unexpected type for dailySteps field: ${stepsField.runtimeType}');
            }
          } else {
            print('No "dailySteps" field found for participantId: $participantId');
          }

          print('Participant: $participantId, Username: $username, Daily Steps: $participantDailySteps'); 

          return {
            'username': username,
            'steps': participantDailySteps, 
          };
        } else {
          print('User document not found for participantId: $participantId');
          return {
            'username': 'Unknown',
            'steps': 0,
          };
        }
      }).toList();

      participantsDetails = await Future.wait(fetchUserFutures);

      setState(() {
        selectedChallengeParticipants = participantsDetails;
        selectedChallengeName = challengeName;
        selectedChallengeStepsGoal = stepsGoal;
        showParticipants = true;
        _controller.forward();
      });
    } catch (e) {
      print('Error fetching participants details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching participants details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void closeParticipantsOverlay() {
    setState(() {
      showParticipants = false;
      selectedChallengeParticipants = [];
      selectedChallengeName = '';
      selectedChallengeStepsGoal = 0;
      _controller.reverse();
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
        title: Text(
          'Active Challenges',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: activeChallengesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No active challenges found.',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  List<Map<String, dynamic>> challenges = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      var challenge = challenges[index];
                      return Card(
                        color: Color(0xFF004D40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Challenge Name
                              Text(
                                challenge['challengeName'],
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Steps: a / b with icon
                              Row(
                                children: [
                                  Text(
                                    'Steps: ${challenge['steps']} / ${challenge['stepsGoal']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    'assets/icons/steps.png',
                                    width: 24,
                                    height: 24,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Show Participants Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    toggleParticipantsOverlay(
                                      challenge['challengeId'],
                                      challenge['challengeName'],
                                      challenge['stepsGoal'],
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 218, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Show Participants',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (showParticipants)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          SlideTransition(
            position: _offsetAnimation,
            child: Visibility(
              visible: showParticipants,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Card(
                    color: Color(0xFF004D40),
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
                            onPressed: closeParticipantsOverlay,
                          ),
                          backgroundColor: Color(0xFF004D40),
                          elevation: 0,
                          title: Text(
                            'Participants',
                            style: TextStyle(color: Colors.white),
                          ),
                          centerTitle: true,
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: selectedChallengeParticipants.length,
                            itemBuilder: (context, index) {
                              var participant = selectedChallengeParticipants[index];
                              return ListTile(
                                leading: Image.asset(
                                  'assets/icons/steps.png',
                                  width: 24,
                                  height: 24,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  '${participant['username']}: ${participant['steps']} / $selectedChallengeStepsGoal',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
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
