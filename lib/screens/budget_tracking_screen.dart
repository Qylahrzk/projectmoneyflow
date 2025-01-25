import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetTrackingScreen extends StatefulWidget {
  const BudgetTrackingScreen({super.key, required Map expensesByCategory, required Map budgets});

  @override
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
    _loadData(); // Load data from SharedPreferences
  }

  /// Load expenses and budgets from SharedPreferences
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

  /// Save expenses and budgets to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('expensesByCategory', json.encode(_expensesByCategory));
    await prefs.setString('budgets', json.encode(_budgets));
  }

  /// Add a new expense to a category
  void _addExpense(String category, double amount) {
    setState(() {
      if (_expensesByCategory.containsKey(category)) {
        _expensesByCategory[category] = _expensesByCategory[category]! + amount;
      } else {
        _expensesByCategory[category] = amount;
      }
    });
    _saveData(); // Save updated expenses
  }

  /// Set a budget for a category
  void _setBudget(String category, double newBudget) {
    setState(() {
      _budgets[category] = newBudget;
    });
    _saveData(); // Save updated budgets
  }

  /// Show a dialog to add a new expense
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

  /// Show a dialog to set a budget
  Future<void> _showSetBudgetDialog(String category, double currentBudget) async {
    final budgetController = TextEditingController(text: currentBudget.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Budget for $category'),
          content: TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter budget'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newBudget = double.tryParse(budgetController.text);
                if (newBudget != null) {
                  _setBudget(category, newBudget);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracking'),
      ),
      body: ListView(
        children: _budgets.keys.map((category) {
          final spent = _expensesByCategory[category] ?? 0.0;
          final budget = _budgets[category] ?? 0.0;

          return Card(
            child: ListTile(
              title: Text(category),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (spent > budget) ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Spent: \$${spent.toStringAsFixed(2)} / Budget: \$${budget.toStringAsFixed(2)}',
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showSetBudgetDialog(category, budget);
                },
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
