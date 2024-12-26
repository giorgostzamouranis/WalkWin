import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_list_page.dart';
import 'friends_page.dart';

class FriendsProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const FriendsProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<FriendsProfilePage> createState() => _FriendsProfilePageState();
}

class _FriendsProfilePageState extends State<FriendsProfilePage> {
  bool _isAddingFriend = false; // To track if the friend is being added

  Future<void> _addFriend() async {
    setState(() {
      _isAddingFriend = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final friendId = widget.user['uid']; // Friend's UID

      if (friendId == null || currentUserId == friendId) {
        return; // Do not add self as a friend or invalid ID
      }

      // Start a Firestore batch operation to ensure atomicity
      final batch = FirebaseFirestore.instance.batch();

      // Add the friend to the current user's friends list
      final currentUserDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      batch.update(currentUserDoc, {
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Add the current user to the friend's friends list
      final friendUserDoc = FirebaseFirestore.instance.collection('users').doc(friendId);
      batch.update(friendUserDoc, {
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      // Commit the batch
      await batch.commit();

      // Fetch the updated friends list for the current user
      final currentUserSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final updatedFriends = List<String>.from(currentUserSnapshot['friends']);

      // Wait for 1 second
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to FriendsListPage with updated friends list
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => FriendsListPage(
              friends: updatedFriends.map((friendId) => {'uid': friendId}).toList(),
              newFriendId: friendId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding friend: $e')),
      );
    } finally {
      setState(() {
        _isAddingFriend = false;
      });
    }
  }



  Future<List<Map<String, dynamic>>> _getFriendsList(String currentUserId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final friendsIds = List<String>.from(snapshot.data()?['friends'] ?? []);

      final friendsSnapshots = await Future.wait(
        friendsIds.map((id) =>
            FirebaseFirestore.instance.collection('users').doc(id).get()),
      );

      return friendsSnapshots
          .where((snap) => snap.exists)
          .map((snap) => {
                'uid': snap.id,
                'username': snap['username'] ?? 'Unknown',
                'avatar': snap['avatar'] ?? 'assets/images/default_avatar.png',
              })
          .toList();
    } catch (e) {
      print('Error fetching friends list: $e');
      return [];
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
            backgroundImage:
                NetworkImage(widget.user['avatar'] ?? 'assets/images/default_avatar.png'),
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
              _isAddingFriend
                  ? Image.asset(
                      'assets/icons/check_small.png',
                      width: 30,
                      height: 30,
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _isAddingFriend
                          ? null
                          : () {
                              _addFriend();
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
