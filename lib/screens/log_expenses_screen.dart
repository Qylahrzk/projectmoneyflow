// File: log_expenses_screen.dart

import 'package:flutter/material.dart';
import 'package:moneyflow/screens/budget_tracking_screen.dart';
import 'package:moneyflow/screens/receipt_scanner_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// ignore: unnecessary_import
import 'package:hive/hive.dart';
// ignore: unused_import
import 'package:moneyflow/models/expense_model.dart';
// ignore: unused_import
import 'package:moneyflow/screens/spending_insights_screen.dart';

import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';


class LogExpensesScreen extends StatefulWidget {
  const LogExpensesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogExpensesScreenState createState() => _LogExpensesScreenState();
}

class _LogExpensesScreenState extends State<LogExpensesScreen> {
  final Box _expenseBox = Hive.box('expenses');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Map<String, double> _budgets = {};

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  // Method to load budgets from SharedPreferences
  Future<void> _loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? budgetsString = prefs.getString('budgets');
    if (budgetsString != null) {
      final Map<String, dynamic> decodedBudgets = jsonDecode(budgetsString);
      setState(() {
        _budgets = decodedBudgets.map((key, value) => MapEntry(key, value.toDouble()));
      });
    } else {
      setState(() {
        _budgets = {}; // Default empty budgets if none are saved
      });
    }
  }

  // Method to calculate total expenses by category
  Map<String, double> _calculateExpenseByCategory() {
    final Map<String, double> expensesByCategory = {};

    for (int i = 0; i < _expenseBox.length; i++) {
      final expense = _expenseBox.getAt(i);
      final String category = expense['category'];
      final double amount = expense['amount'];

      if (expensesByCategory.containsKey(category)) {
        expensesByCategory[category] = expensesByCategory[category]! + amount;
      } else {
        expensesByCategory[category] = amount;
      }
    }

    return expensesByCategory;
  }

  void _addExpense(String title, double amount, String category) {
    final expense = {
      'title': title,
      'amount': amount,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    };
    _expenseBox.add(expense);
    setState(() {});
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = 'General'; // Local state for category
        return AlertDialog(
          title: const Text('Add Expense'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });

                      print(selectedCategory);
                    },
                    items: ['General', 'Food', 'Transportation', 'Shopping']
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty) {
                  _addExpense(
                    _titleController.text,
                    double.parse(_amountController.text),
                    selectedCategory,
                  );
                  _titleController.clear();
                  _amountController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetTrackingScreen(
                    expensesByCategory: _calculateExpenseByCategory(),
                    budgets: _budgets
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights), // Add Insights Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpendingInsightsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _expenseBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No expenses logged yet!'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final expense = box.getAt(index);
              return ListTile(
                title: Text(expense['title']),
                subtitle: Text(
                  '${expense['category']} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['date']))}',
                ),
                trailing: Text('\$${expense['amount'].toStringAsFixed(2)}'),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_manual',
            onPressed: _showAddExpenseDialog,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'scan_receipt',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiptScannerScreen()),
                );
                if (result != null && result is Map<String, dynamic>) {
                  _addExpense(result['title'], result['amount'], 'General');
                }
              },
              child: const Icon(Icons.receipt),
            ),
          ],
        ),
      );
    }
  }
