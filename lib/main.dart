import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moneyflow/screens/log_expenses_screen.dart';
import 'package:moneyflow/screens/account_screen.dart';
import 'package:moneyflow/screens/login_screen.dart';
import 'package:moneyflow/screens/edit_profile_screen.dart';
import 'package:moneyflow/screens/settings_screen.dart';
import 'package:moneyflow/screens/signup_screen.dart';
import 'package:moneyflow/screens/budget_tracking_screen.dart';
import 'package:moneyflow/screens/security_screen.dart';
import 'package:moneyflow/screens/spending_insights_screen.dart'; // New route for Security

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open necessary boxes
  await Hive.initFlutter();
  await Hive.openBox('expenses');
  await Hive.openBox('user');
  await Hive.openBox('settings');

  runApp(const MoneyFlowApp());
}

class MoneyFlowApp extends StatelessWidget {
  const MoneyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    bool isDarkMode = settingsBox.get('darkMode', defaultValue: false);

    final userBox = Hive.box('user');
    bool isLoggedIn = userBox.containsKey('email');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, box, child) {
        isDarkMode = box.get('darkMode', defaultValue: false);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MoneyFlow',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.purple,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.purpleAccent,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: isLoggedIn ? '/home' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/edit-profile': (context) => const EditProfileScreen(currentName: '',),
            '/settings': (context) => const SettingsScreen(),
            '/security': (context) => const SecurityScreen(), // Add Security route
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LogExpensesScreen(),
    const BudgetTrackingScreen(expensesByCategory: {}, budgets: {}, totalBudget: 0.0, totalExpenses: 0.0,),
    const SpendingInsightsScreen(), // New Spending Insights screen
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'MoneyFlow - Expenses'
              : _selectedIndex == 1
                  ? 'Budget Tracking'
                  : _selectedIndex == 2
                      ? 'Spending Insight'
                      : 'Account',
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purpleAccent, // Highlight selected icon
        unselectedItemColor: Colors.grey,      // Dim unselected icons
        backgroundColor: Colors.white,         // Ensure it stands out (or Colors.black in dark mode)
        elevation: 10.0,                        // Add shadow for separation
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Budget Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}