import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart'; // For pie and bar charts

class SpendingInsightsScreen extends StatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  State<SpendingInsightsScreen> createState() => _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends State<SpendingInsightsScreen> {
  final Box _expenseBox = Hive.box('expenses');

  Map<String, double> _calculateSpendingByCategory() {
    final Map<String, double> spendingByCategory = {};

    for (int i = 0; i < _expenseBox.length; i++) {
      final expense = _expenseBox.getAt(i);
      final String category = expense['category'];
      final double amount = expense['amount'];

      if (spendingByCategory.containsKey(category)) {
        spendingByCategory[category] = spendingByCategory[category]! + amount;
      } else {
        spendingByCategory[category] = amount;
      }
    }

    return spendingByCategory;
  }

  double _calculateTotalSpending() {
    return _expenseBox.values.fold(0.0, (sum, expense) => sum + expense['amount']);
  }

  @override
  Widget build(BuildContext context) {
    final spendingByCategory = _calculateSpendingByCategory();
    final totalSpending = _calculateTotalSpending();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Insights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Total Spending
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Total Spending'),
                subtitle: Text('\$${totalSpending.toStringAsFixed(2)}'),
                leading: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),

            // Spending by Category (Pie Chart)
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Spending by Category',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: spendingByCategory.entries.map((entry) {
                              final percentage = (entry.value / totalSpending) * 100;
                              return PieChartSectionData(
                                color: _getCategoryColor(entry.key),
                                value: entry.value,
                                title: '${percentage.toStringAsFixed(1)}%',
                                radius: 50,
                              );
                            }).toList(),
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spending by Category (Bar Chart)
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Spending by Category (Bar)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            barGroups: spendingByCategory.entries.map((entry) {
                              return BarChartGroupData(
                                x: spendingByCategory.keys.toList().indexOf(entry.key),
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value,
                                    color: _getCategoryColor(entry.key),
                                    width: 16,
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,getTitlesWidget: (value, _) {
                                    return Text(spendingByCategory.keys.elementAt(value.toInt()));
                                  },
                                ),
                              ),
                            ),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to assign a color to each category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Shopping':
        return Colors.pink;
      case 'General':
      default:
        return Colors.green;
    }
  }
}
