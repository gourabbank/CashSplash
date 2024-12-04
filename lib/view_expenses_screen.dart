import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'expense_service.dart';
import 'expense_model.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
        // Convert the data properly here
        final allExpenses = data.map((key, value) => MapEntry(key as String, Map<String, dynamic>.from(value as Map)));
        setState(() {
          expenses = allExpenses.values.toList();
        });
      } else {
        // Handle null or unexpected data types
        print("No data available or data is not in expected format");
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
      appBar: AppBar(title: Text("View Expenses")),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var expense = expenses[index];
          return ListTile(
            title: Text("\$${expense['amount']} - ${expense['category']}"),
            subtitle: Text("Date: ${expense['date']}"),
            trailing: IconButton(
              icon: Icon(Icons.receipt),
              onPressed: () => _showReceipt(expense['receiptImage']),
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