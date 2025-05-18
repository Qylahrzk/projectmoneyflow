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
  late Box userBox;
  String? _profilePicture;
  String _name = 'John Doe';
  String _email = 'j-doe@gmail.com';
  String _defaultCurrency = 'USD (\$)';
  String _sorting = 'Date';
  String _summary = 'Average';
  bool _syncEnabled = false;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box('user');
    _loadUserData();
  }

  // Load user data from Hive
  void _loadUserData() {
    setState(() {
      _profilePicture = userBox.get('profilePicture');
      _name = userBox.get('name', defaultValue: 'Admin');
      _email = userBox.get('email', defaultValue: 'nuraqilahnur@gmail.com');
      _defaultCurrency = userBox.get('defaultCurrency', defaultValue: 'MYR (RM)');
      _sorting = userBox.get('sorting', defaultValue: 'Date');
      _summary = userBox.get('summary', defaultValue: 'Average');
      _syncEnabled = userBox.get('syncEnabled', defaultValue: false);
    });
  }

  // Pick and save a new profile picture
  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = image.path;
        userBox.put('profilePicture', _profilePicture);
      });
    }
  }

  // Edit profile (name and email) dialog
  Future<void> _editProfile() async {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController emailController = TextEditingController(text: _email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    emailController.text.contains('@')) {
                  setState(() {
                    _name = nameController.text;
                    _email = emailController.text;
                    userBox.put('name', _name);
                    userBox.put('email', _email);
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

  // General selection dialog for options like currency, sorting, etc.
  Future<void> _selectOption({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
    required String currentSelection,
  }) async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select $title'),
        children: options
            .map(
              (option) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, option),
                child: Text(option),
              ),
            )
            .toList(),
      ),
    );

    if (selectedOption != null && selectedOption != currentSelection) {
      onSelected(selectedOption);
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: GestureDetector(
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
            ),
            const SizedBox(height: 16),

            // User Info
            Center(
              child: Column(
                children: [
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
                    onPressed: _editProfile,
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // General Section
            const Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Data Sync'),
              subtitle: const Text('Enable Data Sync'),
              value: _syncEnabled,
              onChanged: (value) {
                setState(() {
                  _syncEnabled = value;
                  userBox.put('syncEnabled', _syncEnabled);
                });
              },
            ),
            const SizedBox(height: 20),

            // Subscriptions Section
            const Text(
              'My Subscriptions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sorting'),
              subtitle: Text(_sorting),
              onTap: () => _selectOption(
                title: 'Sorting',
                options: ['Date', 'Alphabetical', 'Category'],
                currentSelection: _sorting,
                onSelected: (newSorting) {
                  setState(() {
                    _sorting = newSorting;
                    userBox.put('sorting', _sorting);
                  });
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Summary'),
              subtitle: Text(_summary),
              onTap: () => _selectOption(
                title: 'Summary',
                options: ['Average', 'Total', 'Detailed'],
                currentSelection: _summary,
                onSelected: (newSummary) {
                  setState(() {
                    _summary = newSummary;
                    userBox.put('summary', _summary);
                  });
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Default Currency'),
              subtitle: Text(_defaultCurrency),
              onTap: () => _selectOption(
                title: 'Currency',
                options: ['USD (\$)', 'EUR (€)', 'MYR (RM)', 'JPY (¥)'],
                currentSelection: _defaultCurrency,
                onSelected: (newCurrency) {
                  setState(() {
                    _defaultCurrency = newCurrency;
                    userBox.put('defaultCurrency', _defaultCurrency);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}