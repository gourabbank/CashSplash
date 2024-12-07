import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_expense_screen.dart';
import 'budget_pie_chart.dart';
import 'view_expenses_screen.dart';
import 'profile_settings_screen.dart';
import 'expense_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalBudget = 2000.0;
  double _remainingBudget = 2000.0;
  String _userName = "User";

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
            _remainingBudget = _totalBudget;
          });
          calculateRemainingBudget();
        }
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

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildModernHomeScreen(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToScreen(context, AddExpenseScreen()),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6B46C1),
      ),
    );
  }

  Widget _buildModernHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              _userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.person, color: Colors.white),
                          onPressed: () => _navigateToScreen(context, ProfileSettingsScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -30),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildBudgetCard(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expense Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _navigateToScreen(context, ViewExpensesScreen()),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildExpensesSection(),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Budget',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${_totalBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF6B46C1),
                  child: Icon(Icons.account_balance_wallet, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _remainingBudget > 0 ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Budget',
                    style: TextStyle(
                      color: _remainingBudget > 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                  Text(
                    '\$${_remainingBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _remainingBudget > 0 ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesSection() {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('expenses/${FirebaseAuth.instance.currentUser?.uid}').onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: Color(0xFF6B46C1),
          ));
        }

        if (snapshot.hasError) {
          return _buildErrorCard();
        }

        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return _buildEmptyState();
        }

        Map<dynamic, dynamic> expensesData = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
        List<ExpenseData> expenses = expensesData.entries.map((e) {
          return ExpenseData(
            category: e.value['category'],
            amount: double.tryParse(e.value['amount'].toString()) ?? 0.0,
          );
        }).toList();

        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: BudgetPieChart(
            totalBudget: _totalBudget,
            expenses: expenses,
          ),
        );
      },
    );
  }

  Widget _buildErrorCard() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.pink[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48,
                color: Colors.red[400]
            ),
            SizedBox(height: 16),
            Text(
              'Error loading expenses data',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[400],
                  fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.pink[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 48,
                color: Color(0xFF6B46C1)
            ),
            SizedBox(height: 16),
            Text(
              'No expenses recorded yet',
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B46C1),
                  fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }
}
