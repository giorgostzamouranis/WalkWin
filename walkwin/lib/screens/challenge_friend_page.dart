import 'package:flutter/material.dart';

class ChallengeFriendPage extends StatelessWidget {
  const ChallengeFriendPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 40,
                ),
          
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button 1: Friends to Challenge
            ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40), // Set button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Colors.black, // Add bold border
                    width: 2.0,
                  ),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Friends to Challenge',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white, // Set button text color to white
                  fontWeight: FontWeight.bold, // Make button text bold
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button 2: Set Challenges Goal
            ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Set Challenge Goal',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white, // Set button text color to white
                  fontWeight: FontWeight.bold, // Make button text bold
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Winner's reward: 5",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black, // Set button text color to white
                    fontWeight: FontWeight.bold, // Make button text bold
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'assets/icons/coin.png',
                  width: 30, // Set the width of the coin image
                  height: 30, // Set the height of the coin image
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Start Button
            ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black, // Set button text color to white
                  fontWeight: FontWeight.bold, // Make button text bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}