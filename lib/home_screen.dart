import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'budget_pie_chart.dart';
import 'add_expense_screen.dart';
import 'view_expenses_screen.dart';
import 'profile_settings_screen.dart';
import 'expense_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double _totalBudget = 2000.0; // Default budget
  double _remainingBudget = 2000.0; // Initialized to total budget initially
  String _userName = "User"; // Default user name

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndBudget();
  }

  void _fetchUserProfileAndBudget() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DatabaseReference userRef = FirebaseDatabase.instance.ref('user_profiles/${user.uid}');
      userRef.once().then((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            _userName = data['name'] ?? _userName;
            _totalBudget = double.tryParse(data['budgetGoal'].toString()) ?? _totalBudget;
            _remainingBudget = _totalBudget; // Reset remaining budget on data fetch
          });
          calculateRemainingBudget();
        }
      }).catchError((error) {
        print("Failed to fetch user profile: $error");
      });
    }
  }

  void calculateRemainingBudget() {
    FirebaseDatabase.instance.ref('expenses/${FirebaseAuth.instance.currentUser?.uid}').onValue.listen((event) {
      double totalSpent = 0;
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> expenses = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        totalSpent = expenses.values.fold(0, (prev, element) => prev + double.parse(element['amount'].toString()));
      }
      setState(() {
        _remainingBudget = _totalBudget - totalSpent;
      });
    });
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
        backgroundColor: Colors.teal,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          buildHomeScreenBody(),
          AddExpenseScreen(),
          ViewExpensesScreen(),
          ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "View Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Profile"),
        ],
      ),
    );
  }

  Widget buildHomeScreenBody() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Budget: \$${_totalBudget.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Remaining: \$${_remainingBudget.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, color: Colors.green)),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettingsScreen())),
                child: Text('Adjust Budget'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[300]), // Lighter button color
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseDatabase.instance
                .ref('expenses/${FirebaseAuth.instance.currentUser?.uid}')
                .onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading expenses data'));
              }
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                Map<dynamic, dynamic> expensesData = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                List<ExpenseData> expenses = [];
                expensesData.forEach((key, value) {
                  expenses.add(ExpenseData(
                    category: value['category'],
                    amount: double.tryParse(value['amount'].toString()) ?? 0.0,
                  ));
                });
                return BudgetPieChart(
                  totalBudget: _totalBudget,
                  expenses: expenses,
                );
              } else {
                return Text("No expenses data available", style: TextStyle(fontSize: 20, color: Colors.grey));
              }
            },
          ),
        ),
      ],
    );
  }
}