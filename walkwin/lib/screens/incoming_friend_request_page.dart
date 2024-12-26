import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IncomingFriendRequestPage extends StatelessWidget {
  final Map<String, dynamic> requesterData;

  const IncomingFriendRequestPage({Key? key, required this.requesterData}) : super(key: key);

  Future<void> _acceptFriendRequest(String requesterUid) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Add requester to current user's friends list
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'friends': FieldValue.arrayUnion([requesterUid]),
      });

      // Add current user to requester's friends list
      await FirebaseFirestore.instance.collection('users').doc(requesterUid).update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });

      // Remove the friend request from the current user's incomingFriendRequests list
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'incomingFriendRequests': FieldValue.arrayRemove([requesterUid]),
      });

      // Optional: Show a success message
      debugPrint('Friend request accepted successfully!');
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
    }
  }

  Future<void> _declineFriendRequest(String requesterUid) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Remove the friend request from the current user's incomingFriendRequests list
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'incomingFriendRequests': FieldValue.arrayRemove([requesterUid]),
      });

      // Optional: Show a success message
      debugPrint('Friend request declined successfully!');
    } catch (e) {
      debugPrint('Error declining friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 95,
              backgroundImage: NetworkImage(requesterData['avatar'] ?? 'assets/images/default_avatar.png'),
            ),
            const SizedBox(height: 16),
            Container(
              width: 216,
              height: 29,
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  requesterData['username'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _acceptFriendRequest(requesterData['uid']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E6B0),
                  ),
                  child: const Text('Accept'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    await _declineFriendRequest(requesterData['uid']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                  ),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
