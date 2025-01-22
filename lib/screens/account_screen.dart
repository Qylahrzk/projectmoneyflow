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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _name = userBox.get('name', defaultValue: 'User Name');
    _email = userBox.get('email', defaultValue: 'user@example.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Padding(
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
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name and Email
            Text('Name: $_name', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Email: $_email', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            
            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/editProfile');
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 16),

            // Security Button
            ElevatedButton(
              onPressed: () {
                // Add navigation to security settings
                Navigator.pushNamed(context, '/security');
              },
              child: const Text('Security'),
            ),
            const SizedBox(height: 8),

            // Sorting Data Button
            ElevatedButton(
              onPressed: () {
                // Add navigation to sorting data screen
                Navigator.pushNamed(context, '/sortingData');
              },
              child: const Text('Sorting Data'),
            ),
            const SizedBox(height: 8),

            // Analytics Button
            ElevatedButton(
              onPressed: () {
                // Add navigation to analytics screen
                Navigator.pushNamed(context, '/analytics');
              },
              child: const Text('Analytics'),
            ),
            const SizedBox(height: 8),

            // Default Currency Button
            ElevatedButton(
              onPressed: () {
                // Add navigation to default currency screen
                Navigator.pushNamed(context, '/currency');
              },
              child: const Text('Default Currency'),
            ),
            const SizedBox(height: 16),

            // Settings Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

