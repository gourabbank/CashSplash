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
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                  // Handle touch interactions here
                },
                enabled: true,
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: showingSections(),
              startDegreeOffset: -90,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    double total = expenses.fold(0, (sum, item) => sum + item.amount);
    return List.generate(expenses.length, (i) {
      final isTouched = i == 0;
      final double fontSize = isTouched ? 18 : (expenses[i].amount / total > 0.1 ? 14 : 0); // No text if the section is too small
      final double radius = isTouched ? 60 : 50;

      return PieChartSectionData(
        color: _getColor(i).withOpacity(0.8),
        value: expenses[i].amount,
        title: expenses[i].amount / total > 0.1 ? '\$${expenses[i].amount.toStringAsFixed(2)}' : '',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
            color: Colors.black),
        borderSide: BorderSide(color: Colors.white, width: 2),
      );
    });
  }

  Color _getColor(int index) {
    List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.brown,
    ];

    return colors[index % colors.length];
  }
}