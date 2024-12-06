import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: Colors.pink[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink[200]!,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 8.0,
              runSpacing: 8.0,
              children: expenses.map((expense) => legendItem(expense)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(expenses.length, (i) {
      final bool showTitle = expenses[i].amount / totalBudget > 0.05;
      return PieChartSectionData(
        color: _getColor(i),
        value: expenses[i].amount,
        title: showTitle ? '\$${expenses[i].amount.toStringAsFixed(2)}' : '',
        radius: 120.0,
        titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600]
        ),
      );
    });
  }

  Widget legendItem(ExpenseData expense) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getColor(expenses.indexOf(expense)),
          ),
        ),
        SizedBox(width: 8),
        Text(
            expense.category + ' - \$${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14)
        ),
      ],
    );
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