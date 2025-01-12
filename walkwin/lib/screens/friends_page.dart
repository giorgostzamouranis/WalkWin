import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'story_view_page.dart';
import 'home_page.dart';
import 'store_page.dart';
import 'profile_page.dart';
import 'challenges_page.dart';
import 'search_friends_page.dart';
import 'friends_profile_page.dart';
import 'friends_list_page.dart';
import 'incoming_friend_request_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; 
import 'package:flutter/widgets.dart';
import 'challenge_friend_page.dart';
import 'active_challenges_page.dart';
import 'scan_friends_page.dart';



class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> stories = [];
  List<Map<String, dynamic>> leaderboardData = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? searchedUser;
  bool isSearching = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchStories();
    _fetchLeaderboardData();
  }

  Future<void> _fetchStories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // 1. Get the current user's doc
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) return;

      
      final friendsIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      final allowedUids = [userId, ...friendsIds];

      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .where('uid', whereIn: allowedUids)
          .get();

      List<Map<String, dynamic>> fetchedStories = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final storyOwnerUid = data['uid'] as String?;
        if (storyOwnerUid == null) continue;

        final ownerDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(storyOwnerUid)
            .get();
        final ownerData = ownerDoc.data() ?? {};
        final avatarPath = ownerData['avatar'] ?? 'assets/images/default_avatar.png';
        final ownerUsername = ownerData['username'] ?? 'Unknown User';

        fetchedStories.add({
          'storyUrl': data['storyUrl'],    
          'uid': storyOwnerUid,
          'username': ownerUsername,
          'avatar': avatarPath,
        });
      }

      // 6. Sort so the current user's story is first
      fetchedStories.sort((a, b) {
        if (a['uid'] == userId && b['uid'] != userId) {
          return -1; 
        } else if (b['uid'] == userId && a['uid'] != userId) {
          return 1;  
        } else {
          return 0;  
        }
      });

      setState(() {
        stories = fetchedStories;
      });
    } catch (e) {
      debugPrint('Error fetching stories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching stories: $e')),
      );
    }
  }



  Future<Map<String, dynamic>> fetchRequesterData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return {
        'username': doc['username'] ?? 'Unknown User',
        'avatar': doc['avatar'] ?? 'assets/images/default_avatar.png',
        'uid': uid,
      };
    } else {
      throw Exception('User not found');
    }
  }



  Future<void> _fetchLeaderboardData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }

    try {
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return;
      }

      final currentUser = {
        'username': userDoc['username'],
        'monthlySteps': userDoc['monthlySteps'] ?? 0,
        'isCurrentUser': true, 
      };

      final friends = List<String>.from(userDoc['friends'] ?? []);

      List<Map<String, dynamic>> friendsData = [];
      if (friends.isNotEmpty) {
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: friends)
            .get();

        friendsData = friendsSnapshot.docs.map((doc) {
          return {
            'username': doc['username'],
            'monthlySteps': doc['monthlySteps'] ?? 0,
            'isCurrentUser': false,
          };
        }).toList();
      }

      final allData = [currentUser, ...friendsData];
      allData.sort((a, b) => b['monthlySteps'].compareTo(a['monthlySteps']));

      setState(() {
        leaderboardData = allData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching leaderboard: $e')),
      );
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

      setState(() => _isUploading = true);  

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

        // Refresh stories row
        await _fetchStories(); 

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload story: $e')),
        );
      }finally {
      setState(() => _isUploading = false); // Stop loading animation
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
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),
                const SizedBox(height: 1),
                // Stories Row
                _buildStoriesRow(),
                // Search Bar
                _buildSearchBar(),
                // Leaderboard Section
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3, 
                        child: _buildLeaderboard(),
                      ),
                      const SizedBox(height: 1), 
                      _buildActionButtons(), 
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Loading overlay if uploading a story
        if (_isUploading)
          Positioned.fill(
            child: Container(
              
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16), 
                  const Text(
                    "Uploading story",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  // Get the current user's ID
  final userId = FirebaseAuth.instance.currentUser?.uid;

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
      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.hasData) {
            var userData = snapshot.data!;
            // Get the coins from Firestore
            double coins = userData['coins'] ?? 0.0;

            return Text(
              coins.toStringAsFixed(2), 
              style: TextStyle(
                color: Colors.yellowAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          } else {
            return Text('No Data');
          }
        },
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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) => Profile(returnPage: const HomePage()),
                  ),
                );
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

  ImageProvider<Object> _buildAvatarImage(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    if (avatarPath.startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    return AssetImage(avatarPath);
  }


  Widget _buildStoriesRow() {
    return Column(
      children: [
        // Line above stories
        const Divider(
          color: Colors.black,
          thickness: 1, 
        ),
        const SizedBox(height: 1), 

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
                  height: 40,
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

              // Stories Scroll
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stories.map((story) {
                      return GestureDetector(
                        onTap: () {
                          // Navigate to StoryViewPage
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: _buildAvatarImage(story['avatar']),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60, 
                                child: Text(
                                  story['username'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Notification Button
              GestureDetector(
                onTap: () async {
                  try {
                    // Get the current logged-in user's UID
                    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

                    // Query the friendRequests sub-collection for this user
                    final friendRequestsSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserUid)
                        .collection('friendRequests')
                        .get();

                    if (friendRequestsSnapshot.docs.isNotEmpty) {
                      // Get the first friend request
                      final friendRequest = friendRequestsSnapshot.docs.first;
                      final requesterUid = friendRequest['from'];

                      // Fetch data for the requester
                      final requesterData = await fetchRequesterData(requesterUid);

                      // Navigate to Incoming Friend Request Page
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              IncomingFriendRequestPage(
                                requesterData: requesterData,
                              ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                                  .animate(animation),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    } else {
                      // No incoming friend requests
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No incoming friend requests')),
                      );
                    }
                  } catch (e) {
                    // Handle errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching friend requests: $e')),
                    );
                  }
                },
                child: Container(
                  width: 59,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004D40),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/notification.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: 1), 

        // Line below stories
        const Divider(
          color: Colors.black,
          thickness: 1, 
        ),
      ],
    );
  }


  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SearchFriendsPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const curve = Curves.easeInOut;
              final tween = Tween(begin: const Offset(0, 1), end: Offset.zero);
              final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

              return SlideTransition(
                position: tween.animate(curvedAnimation),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: 375, 
          height: 36,  
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.search, color: Colors.grey),
                ),
                Text(
                  'Search for a user...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }





  Widget _buildLeaderboard() {
    final currentMonth = DateTime.now().month;
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthName = monthNames[currentMonth - 1];

    return Column(
      children: [
        // Month Name Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              monthName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Leaderboard Container
        Expanded(
          child: Container(
            width: 335,
            decoration: BoxDecoration(
              color: const Color(0xFF00E6B0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Leaderboard Header
                Container(
                  color: const Color(0xFF004D40),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: const Center(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Leaderboard List
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: List.generate(leaderboardData.length, (index) {
                        final user = leaderboardData[index];
                        final backgroundColor = index % 2 == 0
                            ? const Color(0xFF00E6B0)
                            : const Color(0xFF004D40);

                        return Container(
                          color: backgroundColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Row(
                            children: [
                              // Rank
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Trophy for First Place
                              if (index == 0)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    'assets/icons/trophy.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),

                              // Username
                              Expanded(
                                child: Text(
                                  user['username'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Monthly Steps with Icon
                              Row(
                                children: [
                                  Text(
                                    '${user['monthlySteps']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/icons/steps.png',
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  
  // Method for building the action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton('Challenge Friends', 'assets/icons/globe.png', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChallengeFriendPage()),
                ); 
              }),
        const SizedBox(height: 10), 
        _buildActionButton('Active Challenges', 'assets/icons/clock_forward.png', onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActiveChallengesPage()),
                );
        }),
        const SizedBox(height: 10), 
        _buildActionButton(
          'Scan Friends',
          'assets/icons/scanner.png',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ScanFriendPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Updated Method for building a single action button
  Widget _buildActionButton(String text, String iconPath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 390,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.black, 
            width: 2.0,
          ),
        ),
        child: Stack(
          children: [
            // Icon on the left
            Positioned(
              left: 16,
              top: -4, 
              child: Image.asset(
                iconPath,
                width: 45,
                height: 45,
                color: Colors.white,
              ),
            ),
            // Centered text
            Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
                        begin: const Offset(-1, 0),
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