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

    // Define a color map for categories
    final Map<String, Color> categoryColors = {
      'Food': Colors.blue,
      'Travel': Colors.orange,
      'Housing': Colors.green,
      'Utilities': Colors.purple,
      'Miscellaneous': Colors.red,
    };

    // Calculate total expenses and remaining budget
    double totalExpenses = expenses.fold(0, (sum, item) => sum + item.amount);
    double budgetLeft = totalBudget - totalExpenses > 0 ? totalBudget - totalExpenses : 0;

    // Add sections for each expense
    expenses.forEach((expense) {
      sections.add(
        PieChartSectionData(
          color: categoryColors[expense.category] ?? Colors.grey, // Default to grey if category not mapped
          value: expense.amount,
          title: '${expense.amount.toStringAsFixed(1)}',
          radius: 60.0,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    });

    // Add remaining budget section if applicable
    if (budgetLeft > 0) {
      sections.add(
        PieChartSectionData(
          color: Colors.grey[200], // Subtle color for remaining budget
          value: budgetLeft,
          title: 'Left \$${budgetLeft.toStringAsFixed(1)}',
          radius: 60.0,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    // Full budget section when no expenses exist
    if (expenses.isEmpty) {
      sections.add(
        PieChartSectionData(
          color: Colors.green[300], // Full budget color
          value: totalBudget,
          title: 'Budget \$${totalBudget.toStringAsFixed(1)}',
          radius: 70.0,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: sections,
      ),
    );
  }
}