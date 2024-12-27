import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to handle sign-up logic
  void _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || username.isEmpty) {
      _showError('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      // Create user account in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the display name with username
      await userCredential.user!.updateDisplayName(username);

      // Get the user ID
      String userId = userCredential.user!.uid;

      // Initialize Firestore document for the user
      final now = DateTime.now();
      final today = "${now.year}-${now.month}-${now.day}";
      final weekOfYear = int.parse((now.weekday / 7).ceil().toString());
      final month = "${now.year}-${now.month}";

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'username': username,
        'avatar': 'assets/images/Avatar1.png',
        'createdAt': FieldValue.serverTimestamp(),
        'dailySteps': 0,
        'weeklySteps': 0,
        'monthlySteps': 0,
        'lastDailyReset': today,
        'lastWeeklyReset': weekOfYear,
        'lastMonthlyReset': month,
        'friends': [],
        'coins': 5.0,
        'challenges': [],
      });

      // Add challenges to the user's profile
      await _addChallengesForUser(userId);

      _showSuccess('Account created successfully!');

      // Navigate to StepGoalsPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StepGoalsPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An error occurred during sign-up.');
    }
  }

  // Helper to display error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  // Helper to display success messages
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.green))),
    );
  }

  // Method to add challenges for a new user
  Future<void> _addChallengesForUser(String userId) async {
    final challenges = [
      {
        'title': 'Easy mission!',
        'goal': 4000,
        'reward': 5,
        'completed': false,
        'description': 'A gentle start! Perfect for beginners.',
      },
      {
        'title': 'Try your limits!',
        'goal': 8000,
        'reward': 10,
        'completed': false,
        'description': 'Step it up! Push your limits.',
      },
      {
        'title': 'Not tired yet?',
        'goal': 20000,
        'reward': 15,
        'completed': false,
        'description': 'Think you’ve got more in the tank?',
      },
      {
        'title': 'For brave ones!',
        'goal': 40000,
        'reward': 20,
        'completed': false,
        'description': 'This is it—the ultimate test of willpower.',
      },
    ];

    for (var challenge in challenges) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .add(challenge);
    }
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
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/icons/arrow_back.png',
                    width: 31,
                    height: 28,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Create account',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 30),
                _buildInputBox(
                  controller: _usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                _buildInputBox(
                  controller: _emailController,
                  hintText: 'Email address',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
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
                const SizedBox(height: 15),
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
                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: 353,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
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
            offset: const Offset(0, 2),
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
                  hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
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
