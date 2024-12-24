import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Load challenges from Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
        backgroundColor: Colors.teal.shade700,
      ),
      body: SafeArea(
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
                final reward = challenge['reward'].toString();  // Ensure 'reward' is a String
                final goal = challenge['goal'].toString();  // Ensure 'goal' is a String
                final isCompleted = challenge['completed'] ?? false;  // Get the completed status

                return ChallengeCard(
                  title: title,
                  reward: reward,
                  goal: goal,
                  isCompleted: isCompleted,  // Pass completed status
                  onTap: () {
                    // Handle challenge completion or more details here
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final String reward;
  final String goal;
  final bool isCompleted;  // Add a boolean to check if the challenge is completed
  final VoidCallback onTap;

  const ChallengeCard({
    Key? key,
    required this.title,
    required this.reward,
    required this.goal,
    required this.isCompleted,  // Receive the completion status
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (isCompleted)  // Show a checkmark if the challenge is completed
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Goal: $goal steps',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reward: $reward Walcoins',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              if (isCompleted)  // Optionally, show a "Completed" label
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
