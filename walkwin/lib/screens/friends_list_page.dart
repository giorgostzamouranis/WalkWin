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
                                backgroundImage: NetworkImage(friend['avatar']),
                              ),
                              title: Text(
                                friend['username'],
                                style: const TextStyle(color: Colors.black),
                              ),
                              tileColor: Colors.white,
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
