import 'package:flutter/material.dart';
import 'search_friends_page.dart';

class FriendsListPage extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final String? newFriendId; // Optional new friend ID to highlight

  const FriendsListPage({Key? key, required this.friends, this.newFriendId}) : super(key: key);

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  late List<Map<String, dynamic>> friends; // Local copy of friends list
  String? newFriendId; // Local state for newFriendId

  @override
  void initState() {
    super.initState();
    friends = List.from(widget.friends); // Copy the friends list
    newFriendId = widget.newFriendId; // Initialize with the provided new friend ID
  }

  @override
  void dispose() {
    if (newFriendId != null) {
      // Remove the "New!" indicator when the user exits the page
      setState(() {
        newFriendId = null;
      });
    }
    super.dispose();
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
                    Navigator.of(context).pop(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchFriendsPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
                                .animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
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
              child: friends.isEmpty
                  ? const Center(
                      child: Text(
                        "Empty friends list",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isNewFriend = friend['uid'] == newFriendId;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(friend['avatar']),
                          ),
                          title: Text(
                            friend['username'],
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: isNewFriend
                              ? const Text(
                                  "New!",
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
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