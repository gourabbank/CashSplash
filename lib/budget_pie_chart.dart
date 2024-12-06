import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'expense_data.dart';

class BudgetPieChart extends StatefulWidget {
  final double totalBudget;
  final List<ExpenseData> expenses;

  const BudgetPieChart({
    Key? key,
    required this.totalBudget,
    required this.expenses,
  }) : super(key: key);

  @override
  State<BudgetPieChart> createState() => _BudgetPieChartState();
}

class _BudgetPieChartState extends State<BudgetPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 300,
            width: double.infinity,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Expense Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),
                ...widget.expenses.map((expense) => legendItem(expense)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.expenses.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 20 : 16;
      final double radius = isTouched ? 130 : 120;

      final double percentage = (widget.expenses[i].amount / widget.totalBudget) * 100;

      return PieChartSectionData(
        color: _getColor(i).withOpacity(isTouched ? 1 : 0.9),
        value: widget.expenses[i].amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  Widget legendItem(ExpenseData expense) {
    final index = widget.expenses.indexOf(expense);
    final isSelected = index == touchedIndex;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor(index),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: _getColor(index).withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 2,
                )
              ] : [],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.category,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? _getColor(index) : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    List<Color> colors = [
      Color(0xFF2196F3), // Blue
      Color(0xFF4CAF50), // Green
      Color(0xFFFFA726), // Orange
      Color(0xFF9C27B0), // Purple
      Color(0xFFE91E63), // Pink
      Color(0xFF00BCD4), // Cyan
    ];
    return colors[index % colors.length];
  }
}