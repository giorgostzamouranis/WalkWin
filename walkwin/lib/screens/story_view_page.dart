import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoryViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories; // List of stories
  final int initialIndex; // The index to start viewing
  const StoryViewPage({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _deleteStory(BuildContext context, String storyOwnerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == storyOwnerId) {
      await FirebaseFirestore.instance.collection('stories').doc(storyOwnerId).delete();
      Navigator.pop(context); // Navigate back to FriendsPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story deleted successfully.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            final isOwner = story['uid'] == FirebaseAuth.instance.currentUser?.uid;

            return Stack(
              children: [
                // Story Image
                Center(
                  child: Image.network(
                    story['storyUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                // Username
                Positioned(
                  top: 16,
                  left: 16,
                  child: Text(
                    story['username'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Delete Button (only for owner)
                if (isOwner)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Are you sure you want to delete?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    _deleteStory(context, story['uid']);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                // Drag to return to FriendsPage
                GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 10) {
                      Navigator.pop(context); // Navigate back to FriendsPage
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
