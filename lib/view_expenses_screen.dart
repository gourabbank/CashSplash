import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class ViewExpensesScreen extends StatefulWidget {
  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  List<Map<dynamic, dynamic>> expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref("expenses/${FirebaseAuth.instance.currentUser?.uid}");
    dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        final allExpenses = data.map((key, value) => MapEntry(key as String, Map<String, dynamic>.from(value as Map)));
        setState(() {
          expenses = allExpenses.values.toList();
        });
      } else {
        setState(() {
          expenses = [];
        });
      }
    }, onError: (error) {
      print("Failed to load expenses: $error");
      setState(() {
        expenses = [];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Expenses"),
        // backgroundColor: Colors.deepPurple, // Enhanced AppBar color
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var expense = expenses[index];
          return Card( // Use Card for better UI
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("\$${expense['amount']} - ${expense['category']}", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Date: ${DateTime.parse(expense['date']).toLocal()}"), // Improved date formatting
              trailing: IconButton(
                icon: Icon(Icons.visibility), // Changed icon for better understanding
                onPressed: () => _showReceipt(expense['receiptImage']),
                color: Colors.purple, // Matching icon color with AppBar
              ),
            ),
          );
        },
      ),
    );
  }

  void _showReceipt(String? base64Image) {
    if (base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No receipt image available.")));
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Receipt Image"),
          content: Image.memory(base64Decode(base64Image)),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}