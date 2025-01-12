import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class ChangeStepGoalsPage extends StatefulWidget {
  final Widget returnPage;

  const ChangeStepGoalsPage({Key? key, required this.returnPage}) : super(key: key);

  @override
  _ChangeStepGoalsPageState createState() => _ChangeStepGoalsPageState();
}

class _ChangeStepGoalsPageState extends State<ChangeStepGoalsPage> {
  final TextEditingController _dailyGoalController = TextEditingController();
  final TextEditingController _weeklyGoalController = TextEditingController();
  final TextEditingController _monthlyGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserGoals();
  }

  void _loadUserGoals() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _dailyGoalController.text = (userDoc['dailyGoal'] ?? 5000).toString();
          _weeklyGoalController.text = (userDoc['weeklyGoal'] ?? 35000).toString();
          _monthlyGoalController.text = (userDoc['monthlyGoal'] ?? 150000).toString();
        });
      }
    }
  }

  void _applyChanges() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'dailyGoal': int.tryParse(_dailyGoalController.text) ?? 5000,
          'weeklyGoal': int.tryParse(_weeklyGoalController.text) ?? 35000,
          'monthlyGoal': int.tryParse(_monthlyGoalController.text) ?? 150000,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goals updated successfully')),
        );

     
        Navigator.pop(context); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update goals: $e')),
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
              // Back button with animation
              IconButton(
                icon: Image.asset('assets/icons/arrow_back.png'),
                iconSize: 40,
                onPressed: () {
                  Navigator.pop(context); 
                },
              ),

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
                    "Change step goals",
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

              // Apply Changes Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _applyChanges,
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
                      "Apply changes",
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
