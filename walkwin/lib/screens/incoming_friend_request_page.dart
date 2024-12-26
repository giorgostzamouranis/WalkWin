import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_list_page.dart';

class IncomingFriendRequestPage extends StatelessWidget {
  final Map<String, dynamic> requesterData;

  const IncomingFriendRequestPage({Key? key, required this.requesterData}) : super(key: key);

  Future<void> _acceptFriendRequest(String? requesterUid, BuildContext context) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    // Ensure current user UID and requester UID are not null
    if (currentUserUid == null) {
      debugPrint('Error: Current User UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Current user ID is invalid')),
      );
      return;
    }

    if (requesterUid == null) {
      debugPrint('Error: Requester UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Requester ID is invalid')),
      );
      return;
    }

    try {
      // Log current user ID and requester ID
      debugPrint('Current User UID: $currentUserUid');
      debugPrint('Requester UID: $requesterUid');

      // Add requester to current user's friends list
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'friends': FieldValue.arrayUnion([requesterUid]),
      });

      // Add current user to requester's friends list
      await FirebaseFirestore.instance.collection('users').doc(requesterUid).update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });

      // Remove the friend request from the friendRequests collection
      await FirebaseFirestore.instance.collection('friendRequests')
          .where('requesterUid', isEqualTo: requesterUid)
          .where('recipientUid', isEqualTo: currentUserUid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Fetch updated friends list
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
      final friends = (userSnapshot.data()?['friends'] ?? []).map<Map<String, dynamic>>((friendId) => {'id': friendId}).toList();

      // Navigate to FriendsListPage with the new friend highlighted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FriendsListPage(friends: friends, newFriendId: requesterUid),
        ),
      );
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting friend request: $e')),
      );
    }
  }

  Future<void> _declineFriendRequest(String? requesterUid, BuildContext context) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    // Ensure current user UID and requester UID are not null
    if (currentUserUid == null) {
      debugPrint('Error: Current User UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Current user ID is invalid')),
      );
      return;
    }

    if (requesterUid == null) {
      debugPrint('Error: Requester UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Requester ID is invalid')),
      );
      return;
    }

    try {
      // Log current user ID and requester ID
      debugPrint('Current User UID: $currentUserUid');
      debugPrint('Requester UID: $requesterUid');

      // Remove the friend request from the friendRequests collection
      await FirebaseFirestore.instance.collection('friendRequests')
          .where('requesterUid', isEqualTo: requesterUid)
          .where('recipientUid', isEqualTo: currentUserUid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      // Fetch updated friends list
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
      final friends = (userSnapshot.data()?['friends'] ?? []).map<Map<String, dynamic>>((friendId) => {'id': friendId}).toList();

      // Navigate to FriendsListPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FriendsListPage(friends: friends),
        ),
      );
    } catch (e) {
      debugPrint('Error declining friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining friend request: $e')),
      );
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
      body: Stack(
        children: [
          // Title
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: const Text(
              'Incoming Friend Request',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Avatar
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 95,
                backgroundImage: NetworkImage(requesterData['avatar'] ?? 'assets/images/default_avatar.png'),
              ),
            ),
          ),
          // Username
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Container(
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Buttons
          Positioned(
            top: MediaQuery.of(context).size.height * 0.50, // Adjust the top position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _acceptFriendRequest(requesterData['uid'], context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E6B0),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _declineFriendRequest(requesterData['uid'], context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}