import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StepGoalsPage extends StatefulWidget {
  const StepGoalsPage({Key? key}) : super(key: key);

  @override
  _StepGoalsPageState createState() => _StepGoalsPageState();
}

class _StepGoalsPageState extends State<StepGoalsPage> {
  final TextEditingController _dailyGoalController = TextEditingController(text: "5000");
  final TextEditingController _weeklyGoalController = TextEditingController(text: "35000");
  final TextEditingController _monthlyGoalController = TextEditingController(text: "150000");

  void _saveGoals() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'dailyGoal': int.tryParse(_dailyGoalController.text) ?? 5000,
          'weeklyGoal': int.tryParse(_weeklyGoalController.text) ?? 35000,
          'monthlyGoal': int.tryParse(_monthlyGoalController.text) ?? 150000,
        });

        // Navigate to the home page
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save goals: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                height: 61,
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(
                  child: Text(
                    "Set steps goals",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Daily Goal
              _buildGoalInput("Daily goal", _dailyGoalController),
              const SizedBox(height: 10),

              // Weekly Goal
              _buildGoalInput("Weekly goal", _weeklyGoalController),
              const SizedBox(height: 10),

              // Monthly Goal
              _buildGoalInput("Monthly goal", _monthlyGoalController),
              const SizedBox(height: 30),

              // Continue Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                      shadowColor: Colors.black.withOpacity(0.4),
                      elevation: 10,
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalInput(String label, TextEditingController controller) {
    return Row(
      children: [
        Container(
          width: 240,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF004D40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
