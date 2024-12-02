import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'expense_data.dart';

class BudgetPieChart extends StatelessWidget {
  final double totalBudget;
  final List<ExpenseData> expenses;

  const BudgetPieChart({
    Key? key,
    required this.totalBudget,
    required this.expenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];

    double totalExpenses = expenses.fold(0, (sum, item) => sum + item.amount);
    double budgetLeft = totalBudget - totalExpenses > 0 ? totalBudget - totalExpenses : 0;

    expenses.forEach((expense) {
      sections.add(
        PieChartSectionData(
          color: Colors.blueGrey[200],  // More subtle color
          value: expense.amount,
          title: '${expense.amount.toStringAsFixed(1)}',
          radius: 60.0,  // Larger radius
          titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    });

    if (budgetLeft > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey[200],  // Subtle color for remaining budget
          value: budgetLeft,
          title: 'Left \$${budgetLeft.toStringAsFixed(1)}',
          radius: 60.0,
          titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );
    }

    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}