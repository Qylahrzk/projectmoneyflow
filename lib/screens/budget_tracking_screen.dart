import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetTrackingScreen extends StatefulWidget {
  const BudgetTrackingScreen({super.key, required Map<String, double> expensesByCategory, required double totalBudget, required Map budgets, required double totalExpenses});

  @override
  // ignore: library_private_types_in_public_api
  _BudgetTrackingScreenState createState() => _BudgetTrackingScreenState();
}

class _BudgetTrackingScreenState extends State<BudgetTrackingScreen> {
  late Map<String, double> _expensesByCategory;
  late Map<String, double> _budgets;

  @override
  void initState() {
    super.initState();
    _expensesByCategory = {};
    _budgets = {};
    _loadData();
  }

  /// Load budgets and expenses from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final expensesString = prefs.getString('expensesByCategory');
    final budgetsString = prefs.getString('budgets');

    setState(() {
      _expensesByCategory = expensesString != null
          ? Map<String, double>.from(json.decode(expensesString))
          : {};

      _budgets = budgetsString != null
          ? Map<String, double>.from(json.decode(budgetsString))
          : {};
    });
  }

  /// Save budgets and expenses to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expensesByCategory', json.encode(_expensesByCategory));
    await prefs.setString('budgets', json.encode(_budgets));
  }

  /// Add a new expense
  void _addExpense(String category, double amount) {
    setState(() {
      if (_expensesByCategory.containsKey(category)) {
        _expensesByCategory[category] = _expensesByCategory[category]! + amount;
      } else {
        _expensesByCategory[category] = amount;
      }
    });
    _saveData();
  }

  /// Set or update a budget for a category
  void _setBudget(String category, double newBudget) {
    setState(() {
      _budgets[category] = newBudget;
      // Ensure any category not tracked yet is initialized in expenses
      if (!_expensesByCategory.containsKey(category)) {
        _expensesByCategory[category] = 0.0;
      }
    });
    _saveData();
  }

  /// Show a dialog to set a new budget
  Future<void> _showSetBudgetDialog() async {
    final categoryController = TextEditingController();
    final budgetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set a New Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Budget Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final category = categoryController.text.trim();
                final budget = double.tryParse(budgetController.text);

                if (category.isNotEmpty && budget != null) {
                  _setBudget(category, budget);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Show a dialog to add an expense
  Future<void> _showAddExpenseDialog() async {
    String? selectedCategory;
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _budgets.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);

                if (selectedCategory != null && amount != null) {
                  _addExpense(selectedCategory!, amount);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Clear all budgets and expenses
  Future<void> _clearData() async {
    setState(() {
      _expensesByCategory.clear();
      _budgets.clear();
    });
    _saveData();
  }

  /// Get a summary of total spent vs. total budget
  double _getTotalBudget() {
    return _budgets.values.fold(0.0, (sum, item) => sum + item);
  }

  double _getTotalSpent() {
    return _expensesByCategory.values.fold(0.0, (sum, item) => sum + item);
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = _getTotalBudget();
    final totalSpent = _getTotalSpent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearData, // Clear all budgets and expenses
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: _showSetBudgetDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Budget Summary
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: const Text('Overall Budget Summary'),
              subtitle: Text(
                'Total Budget: \$${totalBudget.toStringAsFixed(2)}\nTotal Spent: \$${totalSpent.toStringAsFixed(2)}',
              ),
              trailing: Text(
                totalSpent > totalBudget ? 'Over Budget!' : 'On Track',
                style: TextStyle(
                  color: totalSpent > totalBudget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: _budgets.isEmpty
                ? const Center(
                    child: Text('No budgets set yet. Tap the + icon to get started!'),
                  )
                : ListView(
                    children: _budgets.keys.map((category) {
                      final spent = _expensesByCategory[category] ?? 0.0;
                      final budget = _budgets[category]!;

                      return Card(
                        child: ListTile(
                          title: Text(category),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (spent / budget).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(spent > budget ? Colors.red : Colors.green),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Spent: \$${spent.toStringAsFixed(2)} / Budget: \$${budget.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _showAddExpenseDialog,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}