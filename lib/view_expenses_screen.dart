import 'package:flutter/material.dart';
import 'expense_service.dart';
import 'expense_model.dart';

class ViewExpensesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Expenses")),
      body: StreamBuilder<List<Expense>>(
        stream: ExpenseService().getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No expenses found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Expense expense = snapshot.data![index];
              return ListTile(
                title: Text('\$${expense.amount.toStringAsFixed(2)} - ${expense.category}'),
                subtitle: Text('${expense.date} - ${expense.description}'),
              );
            },
          );
        },
      ),
    );
  }
}