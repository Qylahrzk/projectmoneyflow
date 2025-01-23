import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _profilePicture;
  String _name = 'User Name';
  String _email = 'user@example.com';
  late Box userBox;

  @override
  void initState() {
    super.initState();
    // Open Hive box in initState
    userBox = Hive.box('user');
    _initializeUserData();
  }

  void _initializeUserData() {
    setState(() {
      _profilePicture = userBox.get('profilePicture');
      _name = userBox.get('name', defaultValue: 'User Name');
      _email = userBox.get('email', defaultValue: 'user@example.com');
    });
  }

  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = image.path;
        userBox.put('profilePicture', _profilePicture);
      });
    }
  }

  void _editProfileName() {
    TextEditingController nameController = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _name = nameController.text;
                    userBox.put('name', _name);
                  });
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

  void _showSecuritySettings() {
    Navigator.pushNamed(context, '/security');
  }

  void _toggleSync(bool value) {
    // Example: Add functionality for sync toggle
    setState(() {
      userBox.put('syncEnabled', value);
    });
  }

  void _showSortingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sorting Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date'),
              onTap: () {
                userBox.put('sorting', 'Date');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Amount'),
              onTap: () {
                userBox.put('sorting', 'Amount');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSummaryOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Summary Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Average'),
              onTap: () {
                userBox.put('summary', 'Average');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Total'),
              onTap: () {
                userBox.put('summary', 'Total');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('USD (\$)'),
              onTap: () {
                userBox.put('currency', 'USD (\$)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('EUR (€)'),
              onTap: () {
                userBox.put('currency', 'EUR (€)');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('GBP (£)'),
              onTap: () {
                userBox.put('currency', 'GBP (£)');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            GestureDetector(
              onTap: _pickProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null
                    ? FileImage(File(_profilePicture!))
                    : const AssetImage('assets/default_profile.jpg')
                        as ImageProvider,
                child: _profilePicture == null
                    ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _email,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _editProfileName,
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            // General Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'General',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _buildListTile('Security', 'Face ID', Icons.security,
                onTap: _showSecuritySettings),
            SwitchListTile(
              title: const Text('Sync'),
              subtitle: const Text('iCloud Sync'),
              value: userBox.get('syncEnabled', defaultValue: false),
              onChanged: _toggleSync,
            ),
            const SizedBox(height: 20),
            // Subscriptions Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Subscriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _buildListTile('Sorting', 'Date', Icons.sort,
                onTap: _showSortingOptions),
            _buildListTile('Summary', 'Average', Icons.summarize,
                onTap: _showSummaryOptions),
            _buildListTile('Default Currency', 'USD (\$)', Icons.monetization_on,
                onTap: _showCurrencyOptions),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
