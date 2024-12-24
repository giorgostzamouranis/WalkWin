import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_view_page.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> stories = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchStories();
  }

  Future<void> _fetchStories() async {
    final userId = _auth.currentUser?.uid;

    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance.collection('stories').get();
      setState(() {
        stories = snapshot.docs.map((doc) {
          return {
            'storyUrl': doc['storyUrl'],
            'username': doc['username'],
            'uid': doc['uid'],
          };
        }).toList();
      });
    }
  }

  Future<void> _uploadStory() async {
  if (kIsWeb) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera functionality is not supported on the web')),
    );
    return;
  }

  final ImagePicker picker = ImagePicker();
  final XFile? photo = await picker.pickImage(source: ImageSource.camera);

  if (photo != null) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final file = File(photo.path);
      final storageRef = FirebaseStorage.instance.ref().child('stories/$userId.jpg');

      await storageRef.putFile(file);
      final storyUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('stories').doc(userId).set({
        'storyUrl': storyUrl,
        'username': (await FirebaseFirestore.instance.collection('users').doc(userId).get())['username'],
        'uid': userId,
      });

      _fetchStories(); // Refresh stories
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload story: $e')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            const SizedBox(height: 16),

            // Stories Row
            _buildStoriesRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildWalcoins(),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          _buildProfile(),
        ],
      ),
    );
  }

  Widget _buildWalcoins() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Walcoins",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            'assets/icons/coin.png',
            fit: BoxFit.contain,
          ),
        ),
        Text(
          "00.00",
          style: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfile() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('No user data');
        }

        String username = snapshot.data!['username'] ?? 'No Username';
        String avatarPath = snapshot.data!['avatar'] ?? 'assets/images/profile.png';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                // Navigate to Profile
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(avatarPath),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              username,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStoriesRow() {
    return Column(
      children: [
        // Line above stories
        const Divider(
          color: Colors.black,
          thickness: 1, // Thin line
        ),
        const SizedBox(height: 8), // Add some spacing

        // Stories Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Camera Button
              GestureDetector(
                onTap: _uploadStory,
                child: Container(
                  width: 59,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004D40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/icons/camera.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stories
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stories.map((story) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryViewPage(
                                stories: stories,
                                initialIndex: stories.indexOf(story),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircleAvatar(
                            radius: 29.5,
                            backgroundImage: NetworkImage(story['storyUrl']),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8), // Add some spacing

        // Line below stories
        const Divider(
          color: Colors.black,
          thickness: 1, // Thin line
        ),
      ],
    );
  }
}