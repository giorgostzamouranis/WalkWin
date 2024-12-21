import 'package:flutter/material.dart';
import 'store_page.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  _ChallengesState createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> with SingleTickerProviderStateMixin {
  Map<String, Object>? activeMessage;
  late AnimationController _controller;
  late Animation<Offset> _animation; 


@override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Set up the animation to move from the bottom to the center of the screen
    _animation = Tween<Offset>(
      begin: Offset(0, 1),  // Start from bottom (1 is out of screen)
      end: Offset(0, 0),    // End at the centered position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }




  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [


                      // Walcoins
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Text(
                            "Walcoins",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
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
                      ),


                      // Logo
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/logo.png'),
                      ),

                      
                      // Profile
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                const AssetImage('assets/images/profile.png'),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Nikos_10",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),





                // Challenges Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      child:Column(
                      children: [
                        Container(
                  width: 200,
                  height: 29,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E6B0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black, // Border color (change to your desired color)
                      width: 2.0, // Border width (higher value = more intense stroke)
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Available challenges",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // semibold
                        
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                              "Easy misiion!",
                              style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                      ),
                            ),
                    ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove default padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // Rounded edges
                              side: BorderSide(
                                color: Colors.black,
                               width: 2.0
                              ),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              activeMessage = {
                                "title":"Easy mission!",
                                "description": "Step Goal: 4,000 steps\nTime Period: 24 hours\n\nA gentle start! Perfect for beginners or a casual walk. Earn coins effortlessly while staying active.",
                                "coinValue" : 5
                              
                              };
                            });
                            // Trigger the animation when the message is active
                            _controller.forward();
                          },
                          
                          child: _buildChallengeButton("Tap to Read Challenge!", 5),
                        ),
                        const SizedBox(height: 16),
                      Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                              "Try your limits!",
                              style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                      ),
                            ),
                      ),


                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove default padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // Rounded edges
                              side: BorderSide(
                                color: Colors.black,
                               width: 2.0
                              ),
                            ),
                            
                          ),
                          onPressed: () {
                            setState(() {
                              activeMessage = {
                                "title":"Try your limits!",
                                "description": "Step Goal: 8,000 step\nTime Period: 24 hours\n\nStep it up! A challenge designed to push you further and reward your growing determination.",
                                "coinValue" : 15
                              };
                            });
                          // Trigger the animation when the message is active
                            _controller.forward();
                          },
                          child:
                              _buildChallengeButton("Tap to Read Challenge!", 10),
                        ),
                        const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                              "Not tired yet?",
                              style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                      ),
                            ),
                            ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove default padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // Rounded edges
                              side: BorderSide(
                                color: Colors.black,
                               width: 2.0
                              ),
                            ),
                            
                          ),
                          onPressed: () {
                            setState(() {
                              activeMessage = {
                                "title":"Not tired yet?",
                                "description": "Step Goal: 12,000 steps\nTime Period: 36 hoursn\n\nThink you’ve got more in the tank? Take on this tougher challenge for bigger rewards and a stronger you!",
                                "coinValue" : 15
                              };
                            });
                          // Trigger the animation when the message is active
                            _controller.forward();
                          },
                          child:
                              _buildChallengeButton("Tap to Read Challenge!", 15),
                          
                        ),
                        const SizedBox(height: 16),


                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                              "For brave ones!",
                              style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                      ),
                            ),
                            ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero, // Remove default padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // Rounded edges
                              side: BorderSide(
                                color: Colors.black,
                               width: 2.0
                              ),
                            ),
                            
                          ),
                          onPressed: () {
                            setState(() {
                              activeMessage = {
                                "title":"For brave ones!",
                                "description": "Step Goal: 18,000 steps\nTime Period: 48 hours\n\nThis is it—the ultimate test of willpower and stamina. Only the boldest will claim the reward. Are you ready?",
                                "coinValue" : 20
                              };
                            });
                          // Trigger the animation when the message is active
                            _controller.forward();
                          },
                          child:
                              _buildChallengeButton("Tap to Read Challenge!", 20),
                        ),
                      ],
                    ),
                    )
                  ),
                ),
              ],
            ),
        






/////////////////////// Active message ////////////////////////////
              if (activeMessage != null)
                Center(
                  child: SlideTransition(
                    position: _animation,
                      child: Container(
                        height: 320,
                        width: 350,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Text(
                                      activeMessage!["title"]! as String,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    activeMessage!["description"]! as String,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20), // Space between description and reward
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Reward: ${activeMessage!["coinValue"]} coins ",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/icons/coin.png', // Path to your coin image
                                        width: 30,
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        
                            
                            Positioned(
                              top: 8,
                              left: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    activeMessage = null; // Close the rectangle
                                  });
                                  // Reverse the animation when closing
                                  _controller.reverse();
                                },
                                child: Image.asset(
                                  'assets/icons/arrow_back.png',
                                  height:30,
                                  width:30
                                ),
                                ),
                              ),
                          ],
                        ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
                  
                  
                  
                  
 // Bottom Navigation Bar (same as HomePage)
      bottomNavigationBar: Container(
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
                Navigator.pop(context);
              },
            ),
            _NavButton(
              imagePath: 'assets/icons/shop_nav.png',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StorePage()),
                );
              },
            ),
            _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }

 
            
          
        



        /////////////// ChallengeButton//////////////////////////////

          Widget _buildChallengeButton(String title, int coinValue) {
            return Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF00E6B0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                    
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: [
                        Text(
                          "Win $coinValue ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.asset(
                          'assets/icons/coin.png', // Replace with your coin image path
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }






/////////////////  NavButton Widget  /////////////////

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