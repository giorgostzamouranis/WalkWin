import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_list_page.dart';
import 'friends_page.dart';

class IncomingFriendRequestPage extends StatelessWidget {
  final Map<String, dynamic> requesterData;

  const IncomingFriendRequestPage({Key? key, required this.requesterData}) : super(key: key);

  Future<void> _deleteFriendRequest(String requesterUid, String recipientUid) async {
    try {
      // Reference the recipient's friendRequests sub-collection
      final friendRequestsCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(recipientUid)
          .collection('friendRequests');

      // Query the friendRequests sub-collection for the specific request
      final querySnapshot = await friendRequestsCollection
          .where('from', isEqualTo: requesterUid)
          .get();

      // Delete all matching documents
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('Friend request successfully deleted');
    } catch (e) {
      debugPrint('Error deleting friend request: $e');
    }
  }


Future<void> _acceptFriendRequest(String? requesterUid, BuildContext context) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null || requesterUid == null) {
      debugPrint('Error: Current User UID or Requester UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid User or Requester ID')),
      );
      return;
    }

    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');

      // Add requester to current user's friends list
      await usersCollection.doc(currentUserUid).update({
        'friends': FieldValue.arrayUnion([requesterUid]),
      });

      // Add current user to requester's friends list
      await usersCollection.doc(requesterUid).update({
        'friends': FieldValue.arrayUnion([currentUserUid]),
      });

      // Delete the friend request
      await _deleteFriendRequest(requesterUid, currentUserUid);

      // Show success message and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request accepted'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FriendsListPage()),
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

    if (currentUserUid == null || requesterUid == null) {
      debugPrint('Error: Current User UID or Requester UID is null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid User or Requester ID')),
      );
      return;
    }

    try {
      // Delete the friend request
      await _deleteFriendRequest(requesterUid, currentUserUid);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend request declined'),
          backgroundColor: Colors.red,
        ),
      );

      // Navigate to FriendsPage with a move-in animation
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const FriendsPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1), 
                end: Offset.zero, 
              ).animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800), 
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
            top: MediaQuery.of(context).size.height * 0.1, 
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
            top: MediaQuery.of(context).size.height * 0.2, 
            left: 0,
            right: 0,
            child: Center(
              child: CircleAvatar(
                radius: 95,
                backgroundImage: requesterData['avatar'] != null &&
                                requesterData['avatar'].toString().startsWith('http')
                    ? NetworkImage(requesterData['avatar'])
                    : AssetImage(
                        requesterData['avatar'] ?? 'assets/images/Avatar1.png',
                      ) as ImageProvider,
              ),
            ),
          ),
          // Username
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45, 
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
            top: MediaQuery.of(context).size.height * 0.50, 
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
