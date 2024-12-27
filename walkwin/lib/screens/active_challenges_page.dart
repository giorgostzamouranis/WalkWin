import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class ActiveChallengesPage extends StatefulWidget {
  const ActiveChallengesPage({Key? key}) : super(key: key);

  @override
  _ActiveChallengesPageState createState() => _ActiveChallengesPageState();
}

class _ActiveChallengesPageState extends State<ActiveChallengesPage> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>?> activeChallengeFuture;
  List<Map<String, dynamic>> participantsDetails = [];
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool showParticipants = false;

  @override
  void initState() {
    super.initState();
    activeChallengeFuture = fetchActiveChallenge();
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

  Future<Map<String, dynamic>?> fetchActiveChallenge() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user');
      return null;
    }

    String userId = user.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('active_friend_challenges')
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    } else {
      var challengeData = querySnapshot.docs.first.data();
      await fetchParticipantsDetails(challengeData['participants']);
      return challengeData;
    }
  }

  Future<void> fetchParticipantsDetails(List<dynamic> participants) async {
    participantsDetails.clear();
    for (String participantId in participants) {
      var participantSnapshot = await FirebaseFirestore.instance.collection('users').doc(participantId).get();
      if (participantSnapshot.exists) {
        participantsDetails.add({
          'id': participantId,
          'username': participantSnapshot.data()!['username'],
        });
      }
    }
    setState(() {});
  }

  void toggleParticipants() {
    setState(() {
      showParticipants = !showParticipants;
      if (showParticipants) {
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
            child: FutureBuilder<Map<String, dynamic>?>(
              future: activeChallengeFuture,
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
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text(
                    'No active challenges found.',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  Map<String, dynamic> challengeData = snapshot.data!;
                  int stepsGoal = challengeData['stepsGoal'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Challenge',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Steps Goal: $stepsGoal',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    
                                    ElevatedButton(
                                      onPressed: toggleParticipants,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 255, 218, 56),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'Show Participants',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  height: MediaQuery.of(context).size.height * 0.4,
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
                            icon: Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: toggleParticipants,
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
                            itemCount: participantsDetails.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  participantsDetails[index]['username'],
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