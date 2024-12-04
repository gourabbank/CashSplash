import 'package:flutter/material.dart';
import 'budget_pie_chart.dart'; // Make sure to import the Pie Chart widget
import 'add_expense_screen.dart';
import 'expense_data.dart';
import 'view_expenses_screen.dart';
import 'profile_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'budget_pie_chart.dart';
import 'add_expense_screen.dart';
import 'view_expenses_screen.dart';
import 'profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double _totalBudget = 2000.0;  // Default budget
  String _userName = "User";  // Default user name

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _fetchUserProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('user_profiles/${user.uid}');
      userRef.once().then((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            _userName = data['name'] ?? _userName;
            _totalBudget = double.tryParse(data['budgetGoal'].toString()) ?? _totalBudget;
          });
        }
      }).catchError((error) {
        print("Error fetching user profile: $error");
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_userName'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref('expenses/${FirebaseAuth.instance.currentUser?.uid}').onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
                Map<dynamic, dynamic> expensesData = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                List<ExpenseData> expenses = [];
                expensesData.forEach((key, value) {
                  expenses.add(ExpenseData(category: value['category'], amount: double.parse(value['amount'].toString())));
                });
                return BudgetPieChart(totalBudget: _totalBudget, expenses: expenses);
              } else {
                return Center(child: Text('No expenses data available'));
              }
            },
          ),
          AddExpenseScreen(),
          ViewExpensesScreen(),
          ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "View Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Profile"),
        ],
      ),
    );
  }
}