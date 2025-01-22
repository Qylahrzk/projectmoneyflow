import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _email;
  bool _useFaceID = false;

  @override
  void initState() {
    super.initState();
    final userBox = Hive.box('user');
    final settingsBox = Hive.box('settings');

    _name = userBox.get('name', defaultValue: 'John Doe');
    _email = userBox.get('email', defaultValue: 'johndoe@example.com');
    _useFaceID = settingsBox.get('useFaceID', defaultValue: false);
  }

  // Edit Profile function
  void _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              setState(() {
                _name = nameController.text;
                _email = emailController.text;
              });
              final userBox = Hive.box('user');
              userBox.put('name', _name);
              userBox.put('email', _email);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Toggle Face ID function
  void _toggleFaceID(bool value) {
    setState(() {
      _useFaceID = value;
      Hive.box('settings').put('useFaceID', _useFaceID);
    });

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _useFaceID ? 'Face ID enabled' : 'Face ID disabled',
        ),
      ),
    );
  }

  // Change Password function
  void _changePassword() {
    // Future implementation of password change logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change Password feature coming soon!')),
    );
  }

  // Delete Account function
  void _deleteAccount() async {
    final userBox = Hive.box('user');

    // Show confirmation dialog
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If confirmed, delete the account
    if (shouldDelete == true) {
      userBox.clear();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const Divider(height: 32),

            // Edit Profile button
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: _editProfile,
            ),

            // Security (Face ID) switch
            SwitchListTile(
              value: _useFaceID,
              onChanged: _toggleFaceID,
              title: const Text('Security (Face ID)'),
              secondary: const Icon(Icons.security),
            ),

            const Divider(),

            // Change Password button
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: _changePassword,
            ),

            // Delete Account button
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: _deleteAccount,
              textColor: Colors.red,
            ),

            const Divider(),

            // Display App Version
            Center(
              child: Text(
                'App Version: 1.0.0',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




