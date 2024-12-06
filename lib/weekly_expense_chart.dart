import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeeklyExpensesChart extends StatelessWidget {
  final List<double> weeklyExpenses;  // Weekly expenses data

  const WeeklyExpensesChart({Key? key, required this.weeklyExpenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxY = weeklyExpenses.isEmpty ? 0 : weeklyExpenses.reduce(math.max) * 1.2;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()}',
                      TextStyle(color: Colors.white),
                    );
                  }
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  interval: 1,  // Ensures all days are shown
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 16.0,
                      child: Text(titles[value.toInt() % titles.length]),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(weeklyExpenses.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: weeklyExpenses[index],
                    color: Colors.lightBlueAccent,
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            }),
          ),
        ),
      ),
    );
  }
}