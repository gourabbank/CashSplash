import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BudgetNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _hasNotified = false;

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
  }

  static Future<void> showBudgetAlert(double percentage, double remaining) async {
    if (_hasNotified) return;

    const androidDetails = AndroidNotificationDetails(
      'budget_alert',
      'Budget Alerts',
      channelDescription: 'Alerts for budget thresholds',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      0,
      'Budget Alert',
      'You have used ${percentage.toStringAsFixed(1)}% of your budget. \$${remaining.toStringAsFixed(2)} remaining.',
      const NotificationDetails(android: androidDetails),
    );

    _hasNotified = true;
  }

  static void checkBudget(double totalBudget, double totalSpent) {
    double percentageUsed = (totalSpent / totalBudget) * 100;
    double remaining = totalBudget - totalSpent;

    if (percentageUsed >= 80 && !_hasNotified) {
      showBudgetAlert(percentageUsed, remaining);
    } else if (percentageUsed < 80) {
      _hasNotified = false;
    }
  }
}