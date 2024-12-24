import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
// import 'home_page.dart';
import 'step_goals_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();  // Controller for username
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();  // Get the username

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      // Create the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save the username, user data, and default avatar in Firestore
      String userId = userCredential.user!.uid;  // Get user ID from Firebase Auth
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'username': username,  // Store the username
        'avatar': 'assets/images/Avatar1.png',  // Default avatar path
        'createdAt': FieldValue.serverTimestamp(),  // Store account creation time
      });

      _showSuccess('Account created successfully!');

      // Navigate to the home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StepGoalsPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An error occurred during sign up.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.red))));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: Colors.green))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40), // Spacing for status bar
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/icons/arrow_back.png',
                    width: 31,
                    height: 28,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Create account',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                SizedBox(height: 30),
                
                // Add Username input box
                _buildInputBox(
                  controller: _usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 15),

                _buildInputBox(
                  controller: _emailController,
                  hintText: 'Email address',
                  obscureText: false,
                ),
                SizedBox(height: 15),

                _buildInputBox(
                  controller: _passwordController,
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
                  controller: _confirmPasswordController,
                  hintText: 'Confirm password',
                  obscureText: _obscureConfirmPassword,
                  onEyePressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                SizedBox(height: 30),

                Center(
                  child: SizedBox(
                    width: 353,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Create account',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
    required TextEditingController controller,
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
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
          if (onEyePressed != null)
            IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: onEyePressed,
            ),
        ],
      ),
    );
  }
}
