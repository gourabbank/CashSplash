import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ViewExpensesScreen extends StatefulWidget {
  @override
  _ViewExpensesScreenState createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  List<Map<String, dynamic>> expenses = [];
  final currencyFormatter = NumberFormat.currency(symbol: '\$');
  Map<String, String> expenseIds = {}; // Store expense IDs for deletion

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
        setState(() {
          expenseIds.clear();
          expenses.clear();

          data.forEach((key, value) {
            final expenseData = Map<String, dynamic>.from(value as Map);
            expenses.add(expenseData);
            expenseIds[expenseData['date']] = key.toString(); // Store ID with date as key
          });

          expenses.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
        });
      } else {
        setState(() {
          expenses = [];
          expenseIds.clear();
        });
      }
    }, onError: (error) {
      print("Failed to load expenses: $error");
      setState(() {
        expenses = [];
        expenseIds.clear();
      });
    });
  }

  Future<void> _deleteExpense(int index) async {
    final expense = expenses[index];
    final expenseId = expenseIds[expense['date']];

    if (expenseId == null) return;

    try {
      await FirebaseDatabase.instance
          .ref("expenses/${FirebaseAuth.instance.currentUser?.uid}/$expenseId")
          .remove();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Expense deleted successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete expense: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.orange,
      'Transport': Colors.blue,
      'Shopping': Colors.pink,
      'Entertainment': Colors.purple,
    };
    return colors[category] ?? Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: expenses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      )
          : CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  var expense = expenses[index];
                  String formattedDate = DateFormat('MMM d, y').format(DateTime.parse(expense['date']));

                  return Dismissible(
                    key: Key(expense['date']),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) => _confirmDelete(),
                    onDismissed: (direction) => _deleteExpense(index),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showReceipt(expense['receiptImage']),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expense['category'],
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(expense['category']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      currencyFormatter.format(double.parse(expense['amount'].toString())),
                                      style: TextStyle(
                                        color: _getCategoryColor(expense['category']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (expense['receiptImage'] != null)
                                    Icon(
                                      Icons.receipt_outlined,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: expenses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(String? base64Image) {
    if (base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No receipt image available"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Receipt"),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Image.memory(base64Decode(base64Image)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}