import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Main Text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Go for a walk, win rewards \n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "save the environment!",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Subtext
                  Text(
                    "Walk win is here to give you \nspecial rewards reducing \nyour carbon footprint.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  // Buttons and 'or'
                  Column(
                    children: [
                      // Sign In button
                      SizedBox(
                        width: 353,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // 'or' text
                      Text(
                        'or',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Create Account button
                      SizedBox(
                        width: 353,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white, // Text color
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
