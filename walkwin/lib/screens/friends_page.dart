import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_view_page.dart';
import 'home_page.dart';
import 'store_page.dart';
import 'challenges_page.dart';




class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> stories = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  bool isSearching = false;

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
Future<void> _searchUser(String query) async {
  if (query.isEmpty) {
    setState(() {
      searchedUser = null;
      isSearching = false;
    });
    return;
  }

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: query)
        .get();

    setState(() {
      isSearching = true;
      searchedUser = snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
    });
  } catch (e) {
    setState(() {
      isSearching = true;
      searchedUser = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching user: $e')),
    );
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

            // Search Bar
            _buildSearchBar(),

            // Search Results
            if (isSearching) _buildSearchResults(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a user...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onChanged: (query) {
          setState(() {
            isSearching = true;
          });
          _searchUser(query);
        },
      ),
    );
  }

Widget _buildSearchResults() {
  if (searchedUser == null) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'No user found',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  return ListTile(
    leading: CircleAvatar(
      backgroundImage: searchedUser!['avatar'] != null && searchedUser!['avatar'].isNotEmpty
          ? NetworkImage(searchedUser!['avatar'])
          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
    ),
    title: Text(
      searchedUser!['username'],
      style: TextStyle(
        color: Colors.white,
      ),
    ),
  );
}


  Widget _buildBottomNavigationBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF004D40),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavButton(
            imagePath: 'assets/icons/home_nav.png',
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeOut;
                    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          _NavButton(
            imagePath: 'assets/icons/shop_nav.png',
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) => const StorePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeOut;
                    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
          _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {
             Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (context, animation, secondaryAnimation) => const Challenges(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeOut;
                    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curvedAnimation),
                      child: child,
                    );
                  },
                ),
              );


          }),
          _NavButton(imagePath: 'assets/icons/friend_nav.png',
           onTap: () {
             
            },
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _NavButton({Key? key, required this.imagePath, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}