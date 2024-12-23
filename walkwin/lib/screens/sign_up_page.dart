import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40), // Spacing for status bar

                // Back arrow
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/icons/arrow_back.png',
                    width: 31,
                    height: 28,
                  ),
                ),

                SizedBox(height: 30),

                // Title
                Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 30),

                // Input boxes
                _buildInputBox(
                  hintText: 'Email address',
                  obscureText: false,
                ),

                SizedBox(height: 15),

                _buildInputBox(
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  onEyePressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                SizedBox(height: 15),

                _buildInputBox(
                  hintText: 'Confirm password',
                  obscureText: _obscureConfirmPassword,
                  onEyePressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                SizedBox(height: 30),

                // Create account button
                Center(
                  child: SizedBox(
                    width: 353,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Create account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox({
    required String hintText,
    required bool obscureText,
    VoidCallback? onEyePressed,
  }) {
    return Container(
      width: 353,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          if (onEyePressed != null)
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onEyePressed,
            ),
        ],
      ),
    );
  }
}
