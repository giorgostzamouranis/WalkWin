import 'package:flutter/material.dart';
import 'dart:ui';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Stack(
          children: [

            // Back arrow button over the avatar
            Positioned(
              top: 2,
              left: 20,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.pop(context); // This will navigate back to the previous screen
                },
              ),
            ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 50.0),
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Change avatar button
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                          child:Container(
                          width: 200,  
                          height: 30,  
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004D40), // Button background color (same as original container)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(color: Colors.black, width: 2.0), // Border color and width (same as original container)
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Change Avatar",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 20, // Font size
                                  fontWeight: FontWeight.bold, // Font weight
                                ),
                              ),
                            ),
                          ),
                        ),
                        ),

                    ],
                  ),
                ),


///////////////// 3 rectangulars on the right ////////////
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 40.0,right:60),
                        child: Column(
                        children: [
                        // First rectangle
                        Container(
                          width: 220,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF004D40),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                            color: Colors.black, // Border color (change to your desired color)
                            width: 2.0, // Border width (higher value = more intense stroke)
                    ),
                          ),
                          child: const Center(
                            child: Text(
                                  "Nikos_10",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold   
                      ),
                          ),
                          )
                        ),
                        const SizedBox(height: 10),
                      //Second Rectangular
                        SizedBox(
                          width: 120,  // Match the width of the original container
                          height: 40,  // Match the height of the original container
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your desired action here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004D40), // Button background color (same as original container)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(color: Colors.black, width: 2.0), // Border color and width (same as original container)
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "My QR",
                                style: TextStyle(
                                  color: Colors.white, // Text color
                                  fontSize: 20, // Font size
                                  fontWeight: FontWeight.bold, // Font weight
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        
                        // Third rectangle
                        SizedBox(
                          width: 150,
                          height: 40,
                          child:ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // Button background color
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                              ),
                                ),
                          child: const Center(
                            child: Text(
                                  "Log out",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold   
                      ),
                          ),
                          )
                        ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
            
            Positioned(
              top: 300, 
              child:Column(
                children:[

                  //Settings
                  Text(
                  "SETTINGS",
                  style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold   
                  ),
                ),
                SizedBox(height:10),

                //Notifications
                SizedBox(
                          width: 550,
                          height: 40,
                          child:ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004D40), // Button background color (same as original container)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(color: Colors.black, width: 2.0), // Border color and width (same as original container)
                              ),
                                ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            
                            //Notifications icon
                            Icon(
                              Icons.notifications,
                              size: 35, // Set the size of the icon (adjust as needed)
                              color: Colors.white, // Optional: Set the color of the icon
                            ),

                          //Text
                                 Text(
                                  "Notifications",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold   
                      ),
                          ),
                          
                            
                            //navigate icon
                            Icon(
                              Icons.navigate_next,
                              size: 35, // Set the size of the icon (adjust as needed)
                              color: Colors.white, // Optional: Set the color of the icon
                            )
                            ]
                          )
                        ),
                        ),
                        SizedBox(height:10),

                //Steps goals
                SizedBox(
                          width: 550,
                          height: 40,
                          child:ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004D40), // Button background color (same as original container)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(color: Colors.black, width: 2.0), // Border color and width (same as original container)
                              ),
                                ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            
                            //score icon
                            Icon(
                              Icons.score,
                              size: 35, // Set the size of the icon (adjust as needed)
                              color: Colors.white, // Optional: Set the color of the icon
                            ),

                           
                            Text(
                                  "Change steps goal",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold   
                      ),
                          ),
                          

                          //navigate icon
                            Icon(
                              Icons.navigate_next,
                              size: 35, // Set the size of the icon (adjust as needed)
                              color: Colors.white, // Optional: Set the color of the icon
                            )

                        ],
                          ),
                        ),
                        ),
                        SizedBox(height:10),

                //Other settings
                SizedBox(
                          width: 550,
                          height: 40,
                          child:ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF004D40), // Button background color (same as original container)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                side: BorderSide(color: Colors.black, width: 2.0), // Border color and width (same as original container)
                              ),
                                ),

                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            
                            //settings icon
                            Icon(
                              Icons.settings,
                              size: 35, 
                              color: Colors.white, 
                            ),


                            Text(
                                  "Other Settings",
                                  style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold   
                      ),
                          ),

                                                    //navigate icon
                            Icon(
                              Icons.navigate_next,
                              size: 35, // Set the size of the icon (adjust as needed)
                              color: Colors.white, // Optional: Set the color of the icon
                            )

                            ],
                              )
                        ),
                        ),

                ],
            ),
            )
          ],
        ),
      ),
    );
  }
}