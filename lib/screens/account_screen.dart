import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart'; // To pick profile image
import 'dart:io'; // For handling file paths

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _profilePicture;
  String? _name = 'User Name';
  String? _email = 'user@example.com';

  // Load the user's details from the Hive box
  final userBox = Hive.box('user');

  // Pick a profile picture
  Future<void> _pickProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = image.path;
        userBox.put('profilePicture', _profilePicture); // Save to Hive
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _name = userBox.get('name', defaultValue: 'User Name');
    _email = userBox.get('email', defaultValue: 'user@example.com');
    _profilePicture = userBox.get('profilePicture');
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
              Navigator.pushNamed(context, '/settings'); // Navigate to settings screen
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
              _name ?? 'User Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _email ?? 'user@example.com',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editProfile'); // Navigate to edit profile
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            // General Section
            _buildSectionHeader('General'),
            _buildListTile('Security', 'Face ID', Icons.security),
            _buildListTile('iCloud Sync', 'Enabled', Icons.cloud, isSwitch: true),
            const SizedBox(height: 20),
            // My Subscriptions Section
            _buildSectionHeader('My Subscriptions'),
            _buildListTile('Sorting', 'Date', Icons.sort),
            _buildListTile('Summary', 'Average', Icons.summarize),
            _buildListTile('Default Currency', 'USD (\$)', Icons.monetization_on),
            const SizedBox(height: 20),
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildListTile('App Icon', 'Default', Icons.apps),
            _buildListTile('Theme', 'Dark', Icons.dark_mode),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, {bool isSwitch = false}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSwitch
          ? Switch(
              value: true,
              onChanged: (value) {},
            )
          : null,
      onTap: () {
        // Handle tap actions here if needed
      },
    );
  }
}


