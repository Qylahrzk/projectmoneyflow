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
            primarySwatch: Colors.teal,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.teal,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.teal,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: isLoggedIn ? '/home' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/home': (context) => const HomeScreen(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
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
    const BudgetTrackingScreen(expensesByCategory: {}, budgets: {}),
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
                  : 'Account',
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
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
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
