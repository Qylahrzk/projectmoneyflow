import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LogExpensesScreen extends StatefulWidget {
  const LogExpensesScreen({super.key});

  @override
  State<LogExpensesScreen> createState() => _LogExpensesScreenState();
}

class _LogExpensesScreenState extends State<LogExpensesScreen> {
  final Box _expenseBox = Hive.box('expenses');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedCategory = 'General';
  final List<String> _categories = ['General', 'Food', 'Transportation', 'Shopping'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
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
    if (kDebugMode) print('Added expense: $expense');
  }

  /// Clear all expenses from Hive database
  void _clearExpenses() {
    setState(() {
      _expenseBox.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All expenses have been cleared!')),
    );
  }

  /// Show the dialog to add a new expense manually
  void _showAddExpenseDialog() {
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
                value: _selectedCategory,
                isExpanded: true,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
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
                    _addExpense(title, amount, _selectedCategory);
                    _titleController.clear();
                    _amountController.clear();
                    Navigator.of(context).pop();
                  } catch (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invalid amount entered!')),
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

  /// Pick and scan a receipt using ML Kit
  Future<void> _pickReceiptImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final recognizedText = await textDetector.processImage(inputImage);

      String scannedText = recognizedText.text;
      if (kDebugMode) print('Scanned Text: $scannedText');
      _showScannedTextDialog(scannedText);
    }
  }

  /// Show dialog to verify scanned receipt text
  void _showScannedTextDialog(String scannedText) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scanned Receipt'),
          content: SingleChildScrollView(
            child: Text(scannedText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _processScannedText(scannedText);
                Navigator.of(context).pop();
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  /// Extract title and amount from scanned text
  void _processScannedText(String text) {
    final title = _extractTitleFromText(text);
    final amount = _extractAmountFromText(text);

    if (title != null && amount != null) {
      _addExpense(title, amount, 'General');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to extract title/amount.')),
      );
    }
  }

  /// Basic title extraction from scanned text
  String? _extractTitleFromText(String text) {
    final lines = text.split('\n');
    return lines.isNotEmpty ? lines[0].trim() : null;
  }

  /// Extract amount with RM from scanned text
  double? _extractAmountFromText(String text) {
    final regex = RegExp(r'RM\s?\d+(\.\d{1,2})?'); // Look for "RM" followed by number
    final match = regex.firstMatch(text);
    if (match != null) {
      final cleanMatch = match.group(0)?.replaceAll(RegExp(r'[^\d.]'), ''); // Remove "RM" and spaces
      return cleanMatch != null ? double.tryParse(cleanMatch) : null;
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
            icon: const Icon(Icons.delete),
            onPressed: _clearExpenses,
          ),
          // Button to trigger receipt scanning
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _pickReceiptImage,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _expenseBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No expenses logged yet.'));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final expense = box.getAt(index);
              if (expense is Map) {
                return ListTile(
                  title: Text(expense['title']),
                  subtitle: Text(
                    '${expense['category']} - ${DateFormat.yMMMd().format(DateTime.parse(expense['date']))}',
                  ),
                  trailing: Text('RM ${expense['amount'].toStringAsFixed(2)}'), // Display amount with RM
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
    );
  }
}
