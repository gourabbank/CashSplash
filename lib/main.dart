import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      title: 'CashSplash',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/add_expense': (context) => AddExpenseScreen(),
        '/view_expenses': (context) => ViewExpensesScreen(),
      },
    );
  }
}