import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart'; // For picking images

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required String currentName});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late String _name;
  late String _username;
  late String _profilePicture;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userBox = Hive.box('user');
    _name = userBox.get('name', defaultValue: 'John Doe');
    _username = userBox.get('username', defaultValue: 'johndoe');
    _profilePicture = userBox.get('profilePicture', defaultValue: '');
    _nameController.text = _name;
    _usernameController.text = _username;
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilePicture = pickedFile.path;
      });

      // Save profile picture to Hive
      final userBox = Hive.box('user');
      userBox.put('profilePicture', _profilePicture);
    }
  }

  void _saveProfile() {
    final userBox = Hive.box('user');
    userBox.put('name', _nameController.text);
    userBox.put('username', _usernameController.text);

    // You may want to pop the screen back to account screen after saving
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture.isEmpty
                    ? null
                    : NetworkImage(_profilePicture),
                child: _profilePicture.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
