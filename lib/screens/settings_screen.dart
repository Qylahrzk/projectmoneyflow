import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // To manage secure storage for passwords

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;
  String _language = 'English';

  // Load settings from Hive
  final settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _isDarkMode = settingsBox.get('darkMode', defaultValue: false);
    _isNotificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: true);
    _language = settingsBox.get('language', defaultValue: 'English');
  }

  // Save settings to Hive
  void _saveSettings() {
    settingsBox.put('darkMode', _isDarkMode);
    settingsBox.put('notificationsEnabled', _isNotificationsEnabled);
    settingsBox.put('language', _language);
  }

  // Log out user (clear user data)
  void _logOut() async {
    final userBox = Hive.box('user');
    await userBox.clear(); // Clear user data from Hive

    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen after logout
  }

  // Change password logic (can add your own logic here)
  void _changePassword() {
    // Navigate to Change Password screen (you can implement it as needed)
    Navigator.pushNamed(context, '/changePassword');
  }

  // Delete account logic (can add your own logic here)
  void _deleteAccount() async {
    final userBox = Hive.box('user');
    await userBox.clear(); // Clear user data from Hive

    // Optionally, clear sensitive information from secure storage (e.g., password)
    await _secureStorage.deleteAll();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen after account deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content & Display Section
            const Text('Content & Display', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
                _saveSettings(); // Save setting when changed
              },
            ),
            ListTile(
              title: const Text('Language'),
              subtitle: Text(_language),
              onTap: () {
                // Implement language change logic (you can add a bottom sheet or dialog for language selection)
                _showLanguageDialog();
              },
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _isNotificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isNotificationsEnabled = value;
                });
                _saveSettings(); // Save setting when changed
              },
            ),
            const SizedBox(height: 32),

            // Support & About Section
            const Text('Support & About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Terms and Policies'),
              onTap: () {
                // Navigate to terms and policies screen
                Navigator.pushNamed(context, '/termsPolicies');
              },
            ),
            ListTile(
              title: const Text('Support'),
              onTap: () {
                // Navigate to support screen
                Navigator.pushNamed(context, '/support');
              },
            ),
            const SizedBox(height: 32),

            // Login Section
            const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Log Out'),
              onTap: _logOut,
            ),
            ListTile(
              title: const Text('Change Password'),
              onTap: _changePassword,
            ),
            ListTile(
              title: const Text('Delete Account'),
              onTap: _deleteAccount,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // Show language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  setState(() {
                    _language = 'English';
                  });
                  _saveSettings(); // Save selected language
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Spanish'),
                onTap: () {
                  setState(() {
                    _language = 'Spanish';
                  });
                  _saveSettings(); // Save selected language
                  Navigator.pop(context);
                },
              ),
              // Add more languages as necessary
            ],
          ),
        );
      },
    );
  }
}
