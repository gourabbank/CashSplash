import 'package:flutter/material.dart';
import 'budget_pie_chart.dart'; // Make sure to import the Pie Chart widget
import 'add_expense_screen.dart';
import 'expense_data.dart';
import 'view_expenses_screen.dart';
import 'profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    Text("Home Placeholder"), // Placeholder for actual home screen content
    AddExpenseScreen(),
    ViewExpensesScreen(),
    ProfileSettingsScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, User'), // Dynamically insert the user's name here
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _children[_currentIndex],
          ),
          if (_currentIndex == 0) // Only show pie chart on the 'Home' tab
            Expanded(
              flex: 2, // Adjust flex to control space distribution
              child: BudgetPieChart(
                totalBudget: 2000.0, // These would be dynamic based on actual data
                expenses: [
                  ExpenseData(category: "Food", amount: 450.0),
                  ExpenseData(category: "Rent", amount: 1200.0),
                ],
              ),
            ),
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