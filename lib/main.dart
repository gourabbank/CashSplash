import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/profile_settings_screen.dart';
import 'package:project/view_expenses_screen.dart';

import 'add_expense_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyD2ZDdfmv0FtJ9134LDRPFf4ezV12pMQGg",
          authDomain: "cashsplash-774ca.firebaseapp.com",
          projectId: "cashsplash-774ca",
          storageBucket: "cashsplash-774ca.firebasestorage.app",
          messagingSenderId: "1079637643425",
          appId: "1:1079637643425:web:bdeaeaa5ac37ba9da320e0",
          measurementId: "G-8CYY8EZ7FV",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to the authentication state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen(); // User is not logged in, show login screen
          }
          return MainAppScreen(); // User is logged in, show the main screen
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Show a loading spinner while waiting for the auth state
          ),
        );
      },
    );
  }
}
class MainAppScreen extends StatefulWidget {
  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),  // Your actual HomeScreen widget
    ViewExpensesScreen(),  // Your ViewExpensesScreen widget
    AddExpenseScreen(),  // Your AddExpenseScreen widget
    ProfileSettingsScreen(),  // Your ProfileScreen widget
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Expense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}