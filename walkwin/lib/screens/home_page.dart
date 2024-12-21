import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'store_page.dart';
import 'challenges_page.dart';
import 'profile_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _openMaps(BuildContext context) async {
    final geoUrl = Uri.parse('geo:0,0');
    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else {
      final googleMapsUrl = Uri.parse('comgooglemaps://');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        final webUrl = Uri.parse('https://www.google.com/maps');
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps.')),
          );
        }
      }
    }
  }


///////////////// Upper Bar //////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Column(
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
                      InkWell(
                        onTap: () { Navigator.push(context,MaterialPageRoute(builder: (context) => Profile()),
                        );
                        },

                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/images/profile.png'),
                        ),
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
            
            
            ///////////// Buttons Row //////////////////
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    icon: Image.asset(
                      'assets/images/bolt.png',
                      width: 24,
                      height: 24,
                    ),
                    label: const Text(
                      "BOOST STEPS X2",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => _openMaps(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E6B0),
                          fixedSize: const Size(60, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Image.asset(
                          'assets/icons/map.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Steps and Circular Widgets
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const CircularStepsWidget(
                    title: "Steps Today",
                    steps: "7.586",
                    size: 270,
                    titleFontSize: 20,
                    stepsFontSize: 30,
                    iconSize: 50,
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      CircularStepsWidget(
                        title: "This Week",
                        steps: "13.789",
                        size: 180,
                        titleFontSize: 16,
                        stepsFontSize: 24,
                        iconSize: 40,
                      ),
                      CircularStepsWidget(
                        title: "This Month",
                        steps: "56.672",
                        size: 140,
                        titleFontSize: 12,
                        stepsFontSize: 18,
                        iconSize: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),




      /////////Navigation bar////////////
      
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
              onTap: () {},
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
            _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Challenges()),
                );
            }
            ),
            _NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }
}










/////////////////  Circular Widget  /////////////////

class CircularStepsWidget extends StatelessWidget {
  final String title;
  final String steps;
  final double size;
  final double titleFontSize;
  final double stepsFontSize;
  final double iconSize;

  const CircularStepsWidget({
    Key? key,
    required this.title,
    required this.steps,
    required this.size,
    this.titleFontSize = 14,
    this.stepsFontSize = 20,
    this.iconSize = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF004D40),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 0.7,
              color: const Color(0xFF00E6B0),
              strokeWidth: size * 0.08,
              backgroundColor: Colors.transparent,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                steps,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: stepsFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/steps.png',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
            ],
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