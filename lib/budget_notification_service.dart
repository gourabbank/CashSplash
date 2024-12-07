import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _hasNotified = false; // Prevent multiple notifications

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tap
      },
    );
  }

  Future<void> showBudgetWarning(double percentage, double remainingAmount) async {
    if (_hasNotified) return; // Only notify once per threshold crossing

    await _notificationsPlugin.show(
      0,
      'Budget Alert',
      'You have used ${percentage.toStringAsFixed(1)}% of your budget! \$${remainingAmount.toStringAsFixed(2)} remaining.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_warning',
          'Budget Warnings',
          channelDescription: 'Notifications for budget warnings',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color(0xFF6B46C1),
        ),
      ),
    );

    _hasNotified = true;
  }

  void resetNotificationFlag() {
    _hasNotified = false;
  }

  void monitorBudget() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Listen to expenses
    FirebaseDatabase.instance
        .ref('expenses/${user.uid}')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        _calculateBudgetUsage();
      }
    });
  }

  Future<void> _calculateBudgetUsage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get budget goal
      final budgetSnapshot = await FirebaseDatabase.instance
          .ref('user_profiles/${user.uid}')
          .get();

      if (!budgetSnapshot.exists) return;

      final userData = budgetSnapshot.value as Map<dynamic, dynamic>;
      final totalBudget = double.parse(userData['budgetGoal'].toString());

      // Get total expenses
      final expensesSnapshot = await FirebaseDatabase.instance
          .ref('expenses/${user.uid}')
          .get();

      if (!expensesSnapshot.exists) return;

      final expenses = expensesSnapshot.value as Map<dynamic, dynamic>;
      double totalSpent = 0;

      expenses.forEach((key, value) {
        totalSpent += double.parse(value['amount'].toString());
      });

      // Calculate percentage used
      final percentageUsed = (totalSpent / totalBudget) * 100;
      final remaining = totalBudget - totalSpent;

      // Show warning if over 80% and haven't notified yet
      if (percentageUsed >= 80 && !_hasNotified) {
        await showBudgetWarning(percentageUsed, remaining);
      } else if (percentageUsed < 80) {
        resetNotificationFlag(); // Reset flag when back under threshold
      }
    } catch (e) {
      print('Error calculating budget usage: $e');
    }
  }
}