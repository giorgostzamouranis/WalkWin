// lib/step_tracker.dart

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Correctly import DateFormat

class StepTracker with ChangeNotifier {
  // =====================
  // === General Steps ===
  // =====================
  
  // Step counts and goals
  int _stepsToday = 0;
  int _weeklySteps = 0;
  int _monthlySteps = 0;
  int _dailyGoal = 5000;
  double _progressToday = 0.0;
  int _previousSteps = 0;

  // Getters for general steps
  int get stepsToday => _stepsToday;
  int get weeklySteps => _weeklySteps;
  int get monthlySteps => _monthlySteps;
  int get dailyGoal => _dailyGoal;
  double get progressToday => _progressToday;

  // ============================
  // === Challenge Tracking ===
  // ============================

  // Stream subscriptions
  StreamSubscription<StepCount>? _pedometerSubscription;
  StreamSubscription<QuerySnapshot>? _activeChallengesSubscription;
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Current user
  User? _currentUser;

  // Previous total steps to calculate difference
  int _previousTotalSteps = 0;

  // List of active challenges IDs
  List<String> _activeChallengeIds = [];

  // Map to store steps per challenge
  Map<String, int> _stepsPerChallenge = {};

  // Flag to track the first pedometer event
  bool _isFirstPedometerEvent = true;

  // Constructor
  StepTracker() {
    _init();
  }

  /// Initializes the StepTracker by listening to auth changes
  void _init() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out, reset all data
        _resetAllData();
        _cancelSubscriptions();
      } else {
        // User is signed in, initialize step tracking
        _currentUser = user;
        _initializeStepTracking(user);
      }
      notifyListeners();
    });
  }

  /// Resets all local data
  void _resetAllData() {
    // Reset general steps
    _stepsToday = 0;
    _weeklySteps = 0;
    _monthlySteps = 0;
    _progressToday = 0.0;
    _previousSteps = 0;

    // Reset challenge tracking
    _previousTotalSteps = 0;
    _activeChallengeIds.clear();
    _stepsPerChallenge.clear();

    // Reset the flag
    _isFirstPedometerEvent = true;

    notifyListeners();
    debugPrint("All local step data has been reset.");
  }

  /// Cancels existing Firestore and Pedometer subscriptions
  void _cancelSubscriptions() {
    _activeChallengesSubscription?.cancel();
    _pedometerSubscription?.cancel();
    _userDocSubscription?.cancel();
    _activeChallengesSubscription = null;
    _pedometerSubscription = null;
    _userDocSubscription = null;
    debugPrint("Existing subscriptions have been canceled.");
  }

  /// Initializes step tracking for a given user
  Future<void> _initializeStepTracking(User user) async {
    final userId = user.uid;

    // Listen to active challenges where the user is a participant
    _activeChallengesSubscription = FirebaseFirestore.instance
        .collection('active_friend_challenges')
        .where('participants', arrayContains: userId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _handleActiveChallengesSnapshot(snapshot);
    });

    // Listen to user's general step counts
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
        debugPrint("General step counts updated from Firestore for user $userId.");
      } else {
        // If user document does not exist, reset step counts
        _resetGeneralStepCounts();
      }
    });

    // Request Activity Recognition permission
    await _requestPermission();

    // Start listening to pedometer
    _pedometerSubscription =
        Pedometer.stepCountStream.listen(onStepCount, onError: onStepCountError);

    // Initialize previousTotalSteps
    _initializePreviousSteps(userId);

    debugPrint("Step tracking initialized for user $userId.");
  }

  /// Resets general step counts and notifies listeners
  void _resetGeneralStepCounts() {
    _stepsToday = 0;
    _weeklySteps = 0;
    _monthlySteps = 0;
    _progressToday = 0.0;
    _previousSteps = 0;
    notifyListeners();
    debugPrint("General step counts have been reset.");
  }

  /// Requests Activity Recognition permission
  Future<void> _requestPermission() async {
    final status = await Permission.activityRecognition.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      final newStatus = await Permission.activityRecognition.request();
      if (!newStatus.isGranted) {
        debugPrint("Activity Recognition permission denied.");
        // Optionally, notify the user to enable permissions
      }
    }
  }

  /// Initializes the previous total steps from Firestore
  Future<void> _initializePreviousSteps(String userId) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final userDoc = await userDocRef.get();

    if (userDoc.exists) {
      _previousTotalSteps = userDoc['previousSteps'] ?? 0;
      debugPrint("Initialized previousTotalSteps: $_previousTotalSteps");
    } else {
      debugPrint("User document does not exist. Initializing steps to 0.");
      _previousTotalSteps = 0;
    }
  }

  /// Handles the active challenges snapshot
  void _handleActiveChallengesSnapshot(QuerySnapshot snapshot) {
    List<String> updatedChallengeIds = [];
    Map<String, int> updatedStepsPerChallenge = {};

    for (var doc in snapshot.docs) {
      String challengeId = doc.id;
      updatedChallengeIds.add(challengeId);
      updatedStepsPerChallenge[challengeId] = doc['steps'][_currentUser!.uid] ?? 0;
    }

    // Determine added and removed challenges
    List<String> addedChallenges =
        updatedChallengeIds.where((id) => !_activeChallengeIds.contains(id)).toList();
    List<String> removedChallenges =
        _activeChallengeIds.where((id) => !updatedChallengeIds.contains(id)).toList();

    // Update the activeChallengeIds list
    _activeChallengeIds = updatedChallengeIds;

    // Update stepsPerChallenge map
    _stepsPerChallenge = updatedStepsPerChallenge;

    notifyListeners();

    debugPrint("Active challenges updated: $_activeChallengeIds");
  }

  /// Handles new step counts from the pedometer
  Future<void> onStepCount(StepCount event) async {
    if (_currentUser == null) {
      debugPrint("No authenticated user.");
      return;
    }

    String userId = _currentUser!.uid;
    int currentTotalSteps = event.steps;

    debugPrint("Pedometer Step Count: $currentTotalSteps");

    // If previousSteps is 0, initialize it without adding steps
    if (_previousTotalSteps == 0) {
      _previousTotalSteps = currentTotalSteps;

      // Update Firestore with new previousSteps
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userDocRef.update({'previousSteps': currentTotalSteps});

      debugPrint("Initialized previousSteps to $currentTotalSteps for user $userId.");
    } else {
      // Calculate step difference
      int stepDifference = currentTotalSteps - _previousTotalSteps;
      if (stepDifference < 0) {
        // Handle step count reset (e.g., device restart)
        debugPrint("Step count reset detected.");
        stepDifference = 0;
      }

      debugPrint("Step Difference: $stepDifference");

      // Update general step counts if applicable
      if (stepDifference > 0) {
        await _updateGeneralSteps(stepDifference, userId);
      }

      // Update previousTotalSteps
      _previousTotalSteps = currentTotalSteps;

      // Update Firestore with new previousSteps
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userDocRef.update({'previousSteps': currentTotalSteps});

      notifyListeners();
    }
  }


  Future<void> _updateGeneralSteps(int stepDifference, String userId) async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Step 1: Read the user document
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

      if (!userSnapshot.exists) {
        debugPrint("User document does not exist.");
        return;
      }

      Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;

      int currentDailySteps = data['dailySteps'] ?? 0;
      int currentWeeklySteps = data['weeklySteps'] ?? 0;
      int currentMonthlySteps = data['monthlySteps'] ?? 0;

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final weekOfYear = _computeWeekOfYear(now);
      final month = DateFormat('yyyy-MM').format(now);

      Map<String, dynamic> updates = {};

      // Check and reset daily steps if needed
      if (data['lastDailyReset'] != today) {
        updates['dailySteps'] = 0;
        updates['lastDailyReset'] = today;
        currentDailySteps = 0;
      }

      // Check and reset weekly steps if needed
      if (data['lastWeeklyReset'] != weekOfYear) {
        updates['weeklySteps'] = 0;
        updates['lastWeeklyReset'] = weekOfYear;
        currentWeeklySteps = 0;
      }

      // Check and reset monthly steps if needed
      if (data['lastMonthlyReset'] != month) {
        updates['monthlySteps'] = 0;
        updates['lastMonthlyReset'] = month;
        currentMonthlySteps = 0;
      }

      // Prepare step increments
      int newDailySteps = currentDailySteps + stepDifference;
      int newWeeklySteps = currentWeeklySteps + stepDifference;
      int newMonthlySteps = currentMonthlySteps + stepDifference;

      updates.addAll({
        'dailySteps': newDailySteps,
        'weeklySteps': newWeeklySteps,
        'monthlySteps': newMonthlySteps,
        'previousSteps': stepDifference, // Assuming this is intended
      });

      // Execute all updates in a single transaction update
      transaction.update(userDocRef, updates);

      debugPrint("General step counts updated for user $userId.");
    }).catchError((error) {
      debugPrint("Failed to update general steps: $error");
    });
  }


  /// Increments steps for a specific challenge
  Future<void> _incrementChallengeSteps(String challengeId, int steps) async {
    final challengeDocRef =
        FirebaseFirestore.instance.collection('active_friend_challenges').doc(challengeId);

    // Use transaction to ensure atomicity
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot challengeSnapshot = await transaction.get(challengeDocRef);
      if (!challengeSnapshot.exists) {
        debugPrint("Challenge $challengeId does not exist.");
        return;
      }

      Map<String, dynamic> data = challengeSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> stepsMap = Map<String, dynamic>.from(data['steps'] ?? {});

      String userId = _currentUser!.uid;
      int currentSteps = stepsMap[userId] ?? 0;
      int updatedSteps = currentSteps + steps;

      // Update steps
      stepsMap[userId] = updatedSteps;
      transaction.update(challengeDocRef, {
        'steps': stepsMap,
      });

      debugPrint(
          "Challenge $challengeId: Updated steps for user $userId to $updatedSteps.");

      // Check if the challenge is completed by this user
      if (updatedSteps >= data['stepsGoal'] && data['isActive'] == true) {
        // Mark the challenge as completed for this user
        debugPrint("User $userId has met the step goal for challenge $challengeId.");

        // Example: Update a 'completedParticipants' list
        List<dynamic> completedParticipants = List.from(data['completedParticipants'] ?? []);
        if (!completedParticipants.contains(userId)) {
          completedParticipants.add(userId);
          transaction.update(challengeDocRef, {
            'completedParticipants': completedParticipants,
          });
          debugPrint("User $userId marked as completed in challenge $challengeId.");
        }

        // Optionally, check if all participants have completed the challenge
        List<dynamic> participants = data['participants'] ?? [];
        List<dynamic> allCompleted = data['completedParticipants'] ?? [];

        if (allCompleted.length >= participants.length) {
          // Mark the challenge as inactive
          transaction.update(challengeDocRef, {
            'isActive': false,
          });
          debugPrint("Challenge $challengeId has been marked as inactive.");
        }

        // Example: Award coins to the user
        // Fetch user's current coins
        DocumentSnapshot userSnapshot = await transaction.get(
            FirebaseFirestore.instance.collection('users').doc(userId));
        double currentCoins = userSnapshot['coins']?.toDouble() ?? 0.0;
        double reward = (data['winnerReward'] as num?)?.toDouble() ?? 5.0;

        // Update user's coins
        transaction.update(
            FirebaseFirestore.instance.collection('users').doc(userId),
            {'coins': currentCoins + reward});

        debugPrint("Awarded $reward coins to user $userId for completing challenge $challengeId.");
      }
    }).catchError((error) {
      debugPrint("Failed to update challenge steps: $error");
    });
  }

  /// Handles pedometer errors
  void onStepCountError(error) {
    debugPrint("Pedometer Error: $error");
    // Optionally, handle pedometer errors here
  }

  /// Public method to allow external widgets to add steps manually
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
    _previousTotalSteps = newDailySteps; // Update previousTotalSteps to prevent double-counting
    notifyListeners(); // Notify listeners to update UI

    debugPrint("Manually added $stepsToAdd steps for user $userId.");

    // Update steps in active challenges
    if (_activeChallengeIds.isNotEmpty) {
      for (String challengeId in _activeChallengeIds) {
        await _incrementChallengeSteps(challengeId, stepsToAdd);
      }
    }
  }

  /// Resets step counters if a new day, week, or month has started
  Future<void> _resetStepCountersIfNeeded(
      Map<String, dynamic> data, DocumentReference userDocRef, Transaction transaction) async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekOfYear = _computeWeekOfYear(now);
    final month = DateFormat('yyyy-MM').format(now);

    Map<String, dynamic> updates = {};

    if (data['lastDailyReset'] != today) {
      updates['dailySteps'] = 0;
      updates['lastDailyReset'] = today;
    }

    if (data['lastWeeklyReset'] != weekOfYear) {
      updates['weeklySteps'] = 0;
      updates['lastWeeklyReset'] = weekOfYear;
    }

    if (data['lastMonthlyReset'] != month) {
      updates['monthlySteps'] = 0;
      updates['lastMonthlyReset'] = month;
    }

    if (updates.isNotEmpty) {
      transaction.update(userDocRef, updates);
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
    _activeChallengesSubscription?.cancel();
    _userDocSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
    debugPrint("StepTracker has been disposed.");
  }
}