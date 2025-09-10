import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_state.dart';
import '../core/theme/theme_notifier.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../core/state/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildAccountSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    final auth = context.watch<AuthState>();

    return _buildSection('Profile', [
      ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: AppColors.primaryBlue),
        ),
        title: Text(auth.email ?? 'User', style: AppTextStyles.h4),
        subtitle: Text(
          auth.email ?? 'No email',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.edit, color: AppColors.gray500),
        onTap: () {
          // TODO: Navigate to profile edit screen
          _showComingSoonDialog('Profile editing');
        },
      ),
    ]);
  }

  Widget _buildPreferencesSection() {
    final settings = context.watch<SettingsState>();
    return _buildSection('Preferences', [
      SwitchListTile(
        title: Text('Notifications', style: AppTextStyles.body1),
        subtitle: Text(
          'Receive alerts for budgets and goals',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        secondary: Icon(Icons.notifications, color: AppColors.primaryBlue),
        value: settings.notifications,
        onChanged: (value) => settings.setNotifications(value),
        activeColor: AppColors.primaryBlue,
      ),
      Consumer<ThemeNotifier>(
        builder:
            (context, theme, _) => SwitchListTile(
              title: Text('Dark Mode', style: AppTextStyles.body1),
              subtitle: Text(
                'Switch to dark theme',
                style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
              ),
              secondary: Icon(Icons.dark_mode, color: AppColors.primaryBlue),
              value: theme.mode == ThemeMode.dark,
              onChanged: (value) => theme.toggleDark(value),
              activeColor: AppColors.primaryBlue,
            ),
      ),
      ListTile(
        leading: Icon(Icons.attach_money, color: AppColors.primaryBlue),
        title: Text('Currency', style: AppTextStyles.body1),
        subtitle: Text(
          settings.currency,
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () => _showCurrencyDialog(),
      ),
      ListTile(
        leading: Icon(Icons.language, color: AppColors.primaryBlue),
        title: Text('Language', style: AppTextStyles.body1),
        subtitle: Text(
          settings.language,
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () => _showLanguageDialog(),
      ),
    ]);
  }

  Widget _buildSecuritySection() {
    return _buildSection('Security', [
      SwitchListTile(
        title: Text('Biometric Login', style: AppTextStyles.body1),
        subtitle: Text(
          'Use fingerprint or face recognition',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        secondary: Icon(Icons.fingerprint, color: AppColors.primaryBlue),
        value: false,
        onChanged: (value) {
          // TODO: Implement biometric login
          _showComingSoonDialog('Biometric authentication');
        },
        activeColor: AppColors.primaryBlue,
      ),
      ListTile(
        leading: Icon(Icons.lock, color: AppColors.primaryBlue),
        title: Text('Change Password', style: AppTextStyles.body1),
        subtitle: Text(
          'Update your account password',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Password change');
        },
      ),
      ListTile(
        leading: Icon(Icons.privacy_tip, color: AppColors.primaryBlue),
        title: Text('Privacy Settings', style: AppTextStyles.body1),
        subtitle: Text(
          'Manage your data and privacy',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Privacy settings');
        },
      ),
    ]);
  }

  Widget _buildDataSection() {
    return _buildSection('Data & Storage', [
      ListTile(
        leading: Icon(Icons.cloud_sync, color: AppColors.primaryBlue),
        title: Text('Sync Data', style: AppTextStyles.body1),
        subtitle: Text(
          'Backup and sync across devices',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Data sync');
        },
      ),
      ListTile(
        leading: Icon(Icons.file_download, color: AppColors.primaryBlue),
        title: Text('Export Data', style: AppTextStyles.body1),
        subtitle: Text(
          'Download your financial data',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Data export');
        },
      ),
      ListTile(
        leading: Icon(Icons.delete_sweep, color: AppColors.error),
        title: Text(
          'Clear Cache',
          style: AppTextStyles.body1.copyWith(color: AppColors.error),
        ),
        subtitle: Text(
          'Free up storage space',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showClearCacheDialog();
        },
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildSection('Support', [
      ListTile(
        leading: Icon(Icons.help, color: AppColors.primaryBlue),
        title: Text('Help Center', style: AppTextStyles.body1),
        subtitle: Text(
          'Get help and support',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Help center');
        },
      ),
      ListTile(
        leading: Icon(Icons.feedback, color: AppColors.primaryBlue),
        title: Text('Send Feedback', style: AppTextStyles.body1),
        subtitle: Text(
          'Help us improve the app',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showComingSoonDialog('Feedback form');
        },
      ),
      ListTile(
        leading: Icon(Icons.info, color: AppColors.primaryBlue),
        title: Text('About', style: AppTextStyles.body1),
        subtitle: Text(
          'App version and information',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showAboutDialog();
        },
      ),
    ]);
  }

  Widget _buildAccountSection() {
    return _buildSection('Account', [
      ListTile(
        leading: Icon(Icons.logout, color: AppColors.error),
        title: Text(
          'Sign Out',
          style: AppTextStyles.body1.copyWith(color: AppColors.error),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showSignOutDialog();
        },
      ),
      ListTile(
        leading: Icon(Icons.delete_forever, color: AppColors.error),
        title: Text(
          'Delete Account',
          style: AppTextStyles.body1.copyWith(color: AppColors.error),
        ),
        subtitle: Text(
          'Permanently delete your account',
          style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.gray500),
        onTap: () {
          _showDeleteAccountDialog();
        },
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(title, style: AppTextStyles.h4),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    final settings = context.read<SettingsState>();
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'CAD', 'AUD'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Currency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  currencies.map((currency) {
                    return RadioListTile<String>(
                      title: Text(currency),
                      value: currency,
                      groupValue: settings.currency,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setCurrency(value);
                        }
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog() {
    final settings = context.read<SettingsState>();
    final languages = ['English', 'Spanish', 'French', 'German', 'Japanese'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  languages.map((language) {
                    return RadioListTile<String>(
                      title: Text(language),
                      value: language,
                      groupValue: settings.language,
                      onChanged: (value) {
                        if (value != null) {
                          settings.setLanguage(value);
                        }
                        Navigator.of(context).pop();
                        _showComingSoonDialog('Multi-language support');
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.read<AuthState>().signOut();
                  Nav.replace(context, RoutePaths.welcome);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            content: const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showComingSoonDialog('Account deletion');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'This will clear temporary files and free up storage space.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Cache cleared successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Budget Buddy',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Budget Buddy. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Your personal finance companion for tracking expenses, managing budgets, and achieving savings goals.',
        ),
      ],
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Coming Soon'),
            content: Text('$feature will be available in a future update.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
