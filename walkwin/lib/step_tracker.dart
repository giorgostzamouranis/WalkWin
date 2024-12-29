// lib/step_tracker.dart

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Correctly import DateFormat

class StepTracker with ChangeNotifier {
  // Step counts and goals
  int _stepsToday = 0;
  int _weeklySteps = 0;
  int _monthlySteps = 0;
  int _dailyGoal = 5000;
  double _progressToday = 0.0;
  int _previousSteps = 0;

  // Stream subscriptions
  StreamSubscription<StepCount>? _pedometerSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Flag to track the first pedometer event
  bool _isFirstPedometerEvent = true;

  // Getters to expose private variables
  int get stepsToday => _stepsToday;
  int get weeklySteps => _weeklySteps;
  int get monthlySteps => _monthlySteps;
  int get dailyGoal => _dailyGoal;
  double get progressToday => _progressToday;

  // Constructor
  StepTracker() {
    _init();
  }

  /// Initializes the StepTracker by listening to auth changes
  void _init() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out, reset step counts
        _resetLocalStepCounts();
        _cancelSubscriptions();
      } else {
        // User is signed in, initialize step tracking for the new user
        _initializeSteps(user);
      }
    });
  }

  /// Resets local step counts and notifies listeners
  void _resetLocalStepCounts() {
    _stepsToday = 0;
    _weeklySteps = 0;
    _monthlySteps = 0;
    _progressToday = 0.0;
    _previousSteps = 0;
    _isFirstPedometerEvent = true; // Reset the flag
    notifyListeners();
    debugPrint("Local step counts have been reset.");
  }

  /// Cancels existing Firestore and Pedometer subscriptions
  void _cancelSubscriptions() {
    _userDocSubscription?.cancel();
    _pedometerSubscription?.cancel();
    _userDocSubscription = null;
    _pedometerSubscription = null;
    debugPrint("Existing subscriptions have been canceled.");
  }

  /// Initializes step tracking for a given user
  Future<void> _initializeSteps(User user) async {
    final userId = user.uid;

    // Set up Firestore subscription
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _stepsToday = data['dailySteps'] ?? 0;
        _weeklySteps = data['weeklySteps'] ?? 0;
        _monthlySteps = data['monthlySteps'] ?? 0;
        _dailyGoal = data['dailyGoal'] ?? 5000;
        _progressToday =
            (_dailyGoal > 0) ? (_stepsToday / _dailyGoal) : 0.0;
        _previousSteps = data['previousSteps'] ?? 0;

        // If both dailySteps and previousSteps are 0, it's likely the first event
        if (_stepsToday == 0 && _previousSteps == 0) {
          _isFirstPedometerEvent = true;
        } else {
          _isFirstPedometerEvent = false;
        }

        notifyListeners(); // Notify listeners to update UI
        debugPrint("Step counts updated from Firestore for user $userId.");
      } else {
        // If user document does not exist, reset step counts
        _resetLocalStepCounts();
      }
    });

    // Check and request permission if not already granted
    final status = await Permission.activityRecognition.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await Permission.activityRecognition.request();
      if (!newStatus.isGranted) {
        debugPrint("Activity Recognition permission denied.");
        // Optionally, handle permission denial (e.g., notify listeners)
        return;
      }
    }

    // Start listening to pedometer
    _pedometerSubscription =
        Pedometer.stepCountStream.listen((StepCount event) {
      debugPrint("New step count from pedometer: ${event.steps}");
      _handleStepCount(event.steps);
    }, onError: (error) {
      debugPrint("Pedometer Error: $error");
      // Optionally, handle pedometer errors
    });

    debugPrint("Step tracking initialized for user $userId.");
  }

  /// Handles new step counts from the pedometer
  Future<void> _handleStepCount(int stepsFromPedometer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No authenticated user found.");
      return;
    }
    final userId = user.uid;

    // If it's the first pedometer event and both stepsToday and previousSteps are 0,
    // initialize _previousSteps without adding steps
    if (_isFirstPedometerEvent && _stepsToday == 0 && _previousSteps == 0) {
      _previousSteps = stepsFromPedometer;
      _isFirstPedometerEvent = false;
      notifyListeners();
      debugPrint("First pedometer event: previousSteps set to $stepsFromPedometer without adding steps.");
      return;
    }

    // Compute step difference
    int difference = stepsFromPedometer - _previousSteps;
    if (difference < 0) difference = 0; // Prevent negative increments

    // Update Firestore
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      debugPrint("User document does not exist.");
      return;
    }

    int currentDailySteps = userDoc['dailySteps'] ?? 0;
    int currentWeeklySteps = userDoc['weeklySteps'] ?? 0;
    int currentMonthlySteps = userDoc['monthlySteps'] ?? 0;

    // Calculate if step counters need resetting
    await _resetStepCountersIfNeeded(userDoc, userDocRef);

    // Fetch updated steps after potential reset
    final updatedUserDoc = await userDocRef.get();
    currentDailySteps = updatedUserDoc['dailySteps'] ?? 0;
    currentWeeklySteps = updatedUserDoc['weeklySteps'] ?? 0;
    currentMonthlySteps = updatedUserDoc['monthlySteps'] ?? 0;

    // Increment steps
    int newDailySteps = currentDailySteps + difference;
    int newWeeklySteps = currentWeeklySteps + difference;
    int newMonthlySteps = currentMonthlySteps + difference;

    // Write back to Firestore
    await userDocRef.update({
      'dailySteps': newDailySteps,
      'weeklySteps': newWeeklySteps,
      'monthlySteps': newMonthlySteps,
      'previousSteps': stepsFromPedometer, // Store the new pedometer reading
    });

    // Update local state
    _stepsToday = newDailySteps;
    _weeklySteps = newWeeklySteps;
    _monthlySteps = newMonthlySteps;
    _progressToday =
        (_dailyGoal > 0) ? (_stepsToday / _dailyGoal) : 0.0;
    _previousSteps = stepsFromPedometer;
    notifyListeners(); // Notify listeners to update UI

    debugPrint("Step counts updated locally and in Firestore for user $userId.");

    // Check and update challenges
    await _checkAndUpdateChallenges(newDailySteps, userDocRef, userId);
  }

  /// Public method to allow external widgets to add steps
  Future<void> addSteps(int stepsToAdd) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("No authenticated user found.");
      return;
    }
    final userId = user.uid;

    // Get the current steps from Firestore
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) {
      debugPrint("User document does not exist.");
      return;
    }

    int currentDailySteps = userDoc['dailySteps'] ?? 0;
    int currentWeeklySteps = userDoc['weeklySteps'] ?? 0;
    int currentMonthlySteps = userDoc['monthlySteps'] ?? 0;

    // Increment steps
    int newDailySteps = currentDailySteps + stepsToAdd;
    int newWeeklySteps = currentWeeklySteps + stepsToAdd;
    int newMonthlySteps = currentMonthlySteps + stepsToAdd;

    // Write back to Firestore
    await userDocRef.update({
      'dailySteps': newDailySteps,
      'weeklySteps': newWeeklySteps,
      'monthlySteps': newMonthlySteps,
      'previousSteps': newDailySteps, // Set to prevent double-counting
    });

    // Update local state
    _stepsToday = newDailySteps;
    _weeklySteps = newWeeklySteps;
    _monthlySteps = newMonthlySteps;
    _progressToday =
        (_dailyGoal > 0) ? (_stepsToday / _dailyGoal) : 0.0;
    _previousSteps = newDailySteps; // Prevent double-counting
    notifyListeners(); // Notify listeners to update UI

    debugPrint("Manually added $stepsToAdd steps for user $userId.");
  }

  /// Checks and updates challenges based on the new step count
  Future<void> _checkAndUpdateChallenges(
      int steps, DocumentReference userDocRef, String userId) async {
    // Fetch challenges where 'completed' is false
    final challengesSnapshot = await userDocRef
        .collection('challenges')
        .where('completed', isEqualTo: false)
        .get();

    if (challengesSnapshot.docs.isEmpty) {
      debugPrint('No incomplete challenges found for user $userId.');
      return;
    }

    for (var doc in challengesSnapshot.docs) {
      var challenge = doc.data();
      debugPrint('Challenge Data: $challenge'); // Debugging print

      // Ensure 'goal' field exists and is an int
      int goal = challenge['goal'] ?? 0;
      if (steps >= goal) {
        debugPrint('Challenge reached goal for user $userId!');
        // Mark challenge as completed
        await doc.reference.update({'completed': true});

        // Add coins to user's total
        double reward = (challenge['reward'] as num).toDouble();
        double currentCoins =
            (await userDocRef.get())['coins']?.toDouble() ?? 0.0;

        await userDocRef.update({'coins': currentCoins + reward});

        debugPrint('Challenge completed and coins updated for user $userId.');
      }
    }
  }

  /// Resets step counters if a new day, week, or month has started
  Future<void> _resetStepCountersIfNeeded(
      DocumentSnapshot userDoc, DocumentReference userDocRef) async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekOfYear = _computeWeekOfYear(now);
    final month = DateFormat('yyyy-MM').format(now);

    Map<String, dynamic> updates = {};

    if (userDoc['lastDailyReset'] != today) {
      updates['dailySteps'] = 0;
      updates['lastDailyReset'] = today;
    }

    if (userDoc['lastWeeklyReset'] != weekOfYear) {
      updates['weeklySteps'] = 0;
      updates['lastWeeklyReset'] = weekOfYear;
    }

    if (userDoc['lastMonthlyReset'] != month) {
      updates['monthlySteps'] = 0;
      updates['lastMonthlyReset'] = month;
    }

    if (updates.isNotEmpty) {
      await userDocRef.update(updates);
      debugPrint("Step counters reset as needed for user.");
    }
  }

  /// Helper method to compute the week of the year manually
  int _computeWeekOfYear(DateTime date) {
    // Adjust to start the week on Monday
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final firstMonday = firstDayOfYear.weekday == DateTime.monday
        ? firstDayOfYear
        : firstDayOfYear.add(Duration(days: (8 - firstDayOfYear.weekday) % 7));
    final difference = date.difference(firstMonday).inDays;
    if (difference < 0) return 1;
    return (difference / 7).floor() + 1;
  }

  /// Disposes of the stream subscriptions to prevent memory leaks
  @override
  void dispose() {
    _pedometerSubscription?.cancel();
    _userDocSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
    debugPrint("StepTracker has been disposed.");
  }
}
