import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:moneyflow/screens/budget_tracking_screen.dart';
import 'package:moneyflow/screens/spending_insights_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LogExpensesScreen extends StatefulWidget {
  const LogExpensesScreen({super.key});

  @override
  _LogExpensesScreenState createState() => _LogExpensesScreenState();
}

class _LogExpensesScreenState extends State<LogExpensesScreen> {
  final Box _expenseBox = Hive.box('expenses');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Map<String, double> _expensesByCategory = {};

  @override
  void initState() {
    super.initState();
    _loadExpensesByCategory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Load expenses and calculate totals by category
  void _loadExpensesByCategory() {
    final expenses = _expenseBox.values.toList();
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      if (expense is Map) {
        final category = expense['category'] ?? 'General';
        final amount = expense['amount'] ?? 0.0;

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
    }

    setState(() {
      _expensesByCategory = categoryTotals;
    });

    print('Expenses by Category: $_expensesByCategory'); // Debug log
  }

  /// Add a new expense
  void _addExpense(String title, double amount, String category) {
    final expense = {
      'title': title,
      'amount': amount,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    };

    _expenseBox.add(expense);
    _loadExpensesByCategory(); // Update category totals
  }

  /// Show dialog to add a new expense
  void _showAddExpenseDialog() {
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
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
                },
                items: ['General', 'Food', 'Transportation', 'Shopping']
                    .map((category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
              ),
            ],
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
                final title = _titleController.text.trim();
                final amountText = _amountController.text.trim();

                if (title.isNotEmpty && amountText.isNotEmpty) {
                  try {
                    final amount = double.parse(amountText);
                    _addExpense(title, amount, selectedCategory);
                    _titleController.clear();
                    _amountController.clear();
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid numeric amount.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Pick a receipt image from the gallery
  Future<void> _pickReceiptImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _scanReceipt(image);
    }
  }

  /// Scan the receipt using Google ML Kit OCR
  Future<void> _scanReceipt(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final recognizedText = await textDetector.processImage(inputImage);

    String scannedText = recognizedText.text;
    print("Scanned Text: $scannedText");

    // Show the scanned text in a dialog for verification
    _showScannedTextDialog(scannedText);
  }

  /// Show a dialog to display the scanned text and let the user decide
  void _showScannedTextDialog(String scannedText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scanned Receipt Text'),
          content: SingleChildScrollView(
            child: Text(scannedText),  // Show the recognized text
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without adding the expense
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Proceed with extracting title and amount, then add the expense
                _processScannedText(scannedText);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  /// Process the scanned text
  void _processScannedText(String text) {
    final title = _extractTitleFromText(text);  // Implement method to extract title
    final amount = _extractAmountFromText(text); // Implement method to extract amount

    if (title != null && amount != null) {
      _addExpense(title, amount, 'General');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to extract title/amount. Please try again.')),
      );
    }
  }

  /// Extract the title from the scanned text (basic implementation)
  String? _extractTitleFromText(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines[0].trim();  // Assuming the title is the first line
    }
    return null;
  }

  /// Extract the amount from the scanned text (basic implementation)
  double? _extractAmountFromText(String text) {
    final regex = RegExp(r'\d+(\.\d{1,2})?');
    final match = regex.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
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
                    expensesByCategory: _expensesByCategory, budgets: {}, totalBudget: 0.0, totalExpenses: 0.0,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights),
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
            return const Center(child: Text('No expenses logged yet!'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final expense = box.getAt(index);
              if (expense is Map) {
                return ListTile(
                  title: Text(expense['title']),
                  subtitle: Text(
                    '${expense['category']} - ${DateFormat('yyyy-MM-dd').format(DateTime.parse(expense['date']))}',
                  ),
                  trailing: Text('\$${expense['amount'].toStringAsFixed(2)}'),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
      // Add a button for scanning receipts with just an icon (camera or receipt icon)
      persistentFooterButtons: [
        IconButton(
          icon: const Icon(Icons.camera_alt),  // Camera icon for scanning receipts
          onPressed: _pickReceiptImage,
        ),
      ],
    );
  }
}
