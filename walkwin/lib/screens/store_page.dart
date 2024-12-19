import 'package:flutter/material.dart';

class StorePage extends StatelessWidget {
  const StorePage({Key? key}) : super(key: key);

  void _showWeeklyOfferOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0xFF008374).withOpacity(0.73),
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Big box
                Container(
                  width: 329,
                  height: 275,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Top Row: Arrow on left, DESCRIPTION centered
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.asset(
                                'assets/icons/arrow_back.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  "DESCRIPTION",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 36),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          "Get 30% off underarmour.com",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600, // semibold
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Smaller box below
                GestureDetector(
                  onTap: () {
                    // Will define functionality later
                  },
                  child: Container(
                    width: 181,
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Get coupon",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, -5), 
                                child: const Text(
                                  "50",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/icons/coin.png',
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: SingleChildScrollView( // Make the screen scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Section (same as HomePage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Walcoins
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Walcoins",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
                const SizedBox(height: 16),

                // Available coupons box
                Container(
                  width: 200,
                  height: 29,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E6B0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      "Available coupons",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600, // semibold
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // 5 Carousels stacked
                // For demonstration, we'll repeat a similar carousel.
                // Each carousel will have 3 items (offers).
                // We'll show the weekly offer style logic but now more dynamic.

                for (int i = 0; i < 5; i++) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Carousel ${i+1}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),

                  _CarouselWidget(
                    onOfferTap: () {
                      _showWeeklyOfferOverlay(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],

              ],
            ),
          ),
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
                // Already on Store page
              },
            ),
            _NavButton(imagePath: 'assets/icons/target_nav.png', onTap: () {}),
            _NavButton(imagePath: 'assets/icons/friend_nav.png', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _CarouselWidget extends StatefulWidget {
  final VoidCallback onOfferTap;
  const _CarouselWidget({Key? key, required this.onOfferTap}) : super(key: key);

  @override
  __CarouselWidgetState createState() => __CarouselWidgetState();
}

class __CarouselWidgetState extends State<_CarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      // We can track page changes for dot indicators
      int newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  Widget _buildOffer(int index) {
    // If index == _currentPage, show larger box (373x111)
    // Else smaller (295x82) + overlay
    bool isCurrent = (index == _currentPage);

    double width = isCurrent ? 373 : 295;
    double height = isCurrent ? 111 : 82;
    Color overlayColor = isCurrent ? Colors.transparent : Colors.white.withOpacity(0.2);

    return GestureDetector(
      onTap: widget.onOfferTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white, // base color if needed
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (use a placeholder image)
            // If not current, we could also add a blur effect. For simplicity, just overlay.
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/weekly_offer.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: overlayColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    // 3 dots, the one that is currentPage is bigger/darker
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        bool isActive = (i == _currentPage);
        double width = isActive ? 23 : 13;
        double height = 13;
        Color color = isActive ? const Color(0xFF464646) : const Color(0xFFC0BEBE);

        return Container(
          width: width,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6.5),
          ),
        );
      }),
    );
  }




   @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170, // Enough space for the offers and transformations
          child: PageView.builder(
            controller: _pageController,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildOffer(index);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildDots(),
      ],
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