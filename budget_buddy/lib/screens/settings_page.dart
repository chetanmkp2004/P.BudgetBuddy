import 'package:flutter/material.dart';

/// Temporary lightweight settings page to unblock compilation.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings (temporary)')),
    );
  }
}
