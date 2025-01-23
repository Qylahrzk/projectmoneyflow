import 'package:flutter/material.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // Add logic for changing password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password clicked')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Enable Face ID'),
              trailing: Switch(
                value: false,
                onChanged: (bool value) {
                  // Add logic for enabling/disabling Face ID
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Face ID: ${value ? "Enabled" : "Disabled"}')),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phonelink_lock),
              title: const Text('Two-Factor Authentication'),
              onTap: () {
                // Add logic for two-factor authentication
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Two-Factor Authentication clicked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
