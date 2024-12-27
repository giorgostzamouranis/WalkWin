import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({Key? key}) : super(key: key);

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, dynamic>> friends = []; // Local list to store friends data
  bool isLoading = true; // State to show loading indicator

  @override
  void initState() {
    super.initState();
    _fetchFriends(); // Fetch friends list on page load
  }

  Future<void> _fetchFriends() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in')),
      );
      return;
    }

    try {
      // Fetch the current user's data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User data not found')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get the list of friend UIDs
      final friendsIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      // Fetch detailed information for each friend
      final friendsDetails = await Future.wait(friendsIds.map((id) async {
        final friendDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        final data = friendDoc.data();
        return {
          'id': id,
          'username': data?['username'] ?? 'Unknown User',
          'avatar': data?['avatar'] ?? 'https://via.placeholder.com/150',
        };
      }));

      // Update the state with the fetched friends
      setState(() {
        friends = friendsDetails;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching friends list: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching friends list: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  ImageProvider<Object> _buildAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      // Fallback for null or empty
      return const AssetImage('assets/images/Avatar1.png');
    }

    // If it starts with 'http' or 'https', treat it like a network URL
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }

    // Otherwise, assume it's a local asset path, like 'assets/images/Avatar3.png'
    return AssetImage(avatarPath);
  }

  Future<void> _confirmRemoveFriend(String friendId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Friend?'),
          content: const Text('Are you sure you want to remove this friend?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // If user tapped "Yes", remove the friend
    if (confirm == true) {
      _removeFriend(friendId);
    }
  }

  Future<void> _removeFriend(String friendId) async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null) return;

    try {
      // 1. Remove the friend from the current user's friends list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .update({
        'friends': FieldValue.arrayRemove([friendId]),
      });

      // 2. Remove the current user from the friend's friends list
      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .update({
        'friends': FieldValue.arrayRemove([currentUserUid]),
      });

      // 3. Update local list so it won't show in the UI anymore
      setState(() {
        friends.removeWhere((f) => f['id'] == friendId);
      });

      // 4. Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully')),
      );
    } catch (e) {
      debugPrint('Error removing friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF008374),
      body: SafeArea(
        child: Column(
          children: [
            // Back Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              "Friends List",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Friends Table
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : friends.isEmpty
                      ? const Center(
                          child: Text(
                            "No friends found.",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            final friend = friends[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: _buildAvatarImage(friend['avatar']),
                              ),
                              title: Text(
                                friend['username'],
                                style: const TextStyle(color: Colors.black),
                              ),
                              tileColor: Colors.white,
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmRemoveFriend(friend['id']),
                              ),                              
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
