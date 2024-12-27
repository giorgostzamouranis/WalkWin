import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_page.dart';

class FriendsProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendsProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<FriendsProfilePage> createState() => _FriendsProfilePageState();
}

class _FriendsProfilePageState extends State<FriendsProfilePage> {
  bool _isSendingRequest = false; // To track if the friend request is being sent

  Future<void> _sendFriendRequest() async {
    setState(() {
      _isSendingRequest = true;
    });

    try {
      // Get the logged-in user's UID and friend's UID
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final friendId = widget.user['uid'];

      if (friendId == null || currentUserId == friendId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid operation: Cannot send a request to yourself.')),
        );
        return;
      }

      // Reference to the friend's friendRequests sub-collection
      final friendRequestsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('friendRequests');

      // Debugging: Check current user and friend
      print('Current User ID: $currentUserId');
      print('Friend ID: $friendId');

      // Delete existing requests from the current user
      final querySnapshot = await friendRequestsCollection
          .where('from', isEqualTo: currentUserId)
          .get();

      for (var doc in querySnapshot.docs) {
        print('Deleting existing friend request: ${doc.id}');
        await doc.reference.delete();
      }

      // Add the new friend request
      await friendRequestsCollection.add({
        'from': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Friend request successfully written to Firestore!');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      // Debugging: Log error
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    } finally {
      setState(() {
        _isSendingRequest = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    // Handle null values for step data
    final dailySteps = widget.user['dailySteps'] ?? 0;
    final weeklySteps = widget.user['weeklySteps'] ?? 0;
    final monthlySteps = widget.user['monthlySteps'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 800),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const FriendsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween(begin: Offset.zero, end: const Offset(0, 1))
                        .animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.teal.shade700,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 95,
            backgroundImage: widget.user['avatar'] != null &&
                            widget.user['avatar'].startsWith('http')
                ? NetworkImage(widget.user['avatar'])
                : AssetImage(widget.user['avatar'] ?? 'assets/images/Avatar1.png')
                    as ImageProvider,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 216,
                height: 29,
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    widget.user['username'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _isSendingRequest
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _isSendingRequest
                          ? null
                          : () {
                              _sendFriendRequest();
                            },
                    ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStepsRow('Daily steps:', dailySteps),
          _buildStepsRow('Weekly steps:', weeklySteps),
          _buildStepsRow('Monthly steps:', monthlySteps),
        ],
      ),
    );
  }

  Widget _buildStepsRow(String label, int steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          Text(
            steps.toString(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Image.asset('assets/icons/steps.png', width: 24, height: 24),
        ],
      ),
    );
  }
}