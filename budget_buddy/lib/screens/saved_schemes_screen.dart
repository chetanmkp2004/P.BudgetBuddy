import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SavedSchemesScreen extends StatelessWidget {
  const SavedSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Schemes'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: ListView.builder(
        itemCount: 5, // Dummy data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.bookmark,
                color: AppTheme.secondaryGreen,
              ),
              title: Text('Scheme ${index + 1}'),
              subtitle: const Text('A brief description of the saved scheme.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle scheme tap
              },
            ),
          );
        },
      ),
    );
  }
}
