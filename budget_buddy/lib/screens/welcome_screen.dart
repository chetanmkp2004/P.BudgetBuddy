import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool compact = size.height < 700; // responsive spacing threshold

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: compact ? 32 : 60),
              // App Logo/Icon Placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.secondaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              SizedBox(height: compact ? 24 : 32),
              // App Title
              Text(
                'Budget Buddy',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontSize: compact ? 28 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Take control of your finances',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.gray700,
                  fontSize: compact ? 18 : 20,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                'Track spending, set budgets, and reach your savings goals with intelligent insights.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                  height: 1.5,
                  fontSize: compact ? 14 : 16,
                ),
              ),
              SizedBox(height: compact ? 32 : 48),
              // Feature highlights
              _buildFeatureItem(
                icon: Icons.trending_down,
                title: 'Smart Tracking',
                description: 'Automatic expense categorization',
              ),
              SizedBox(height: compact ? 16 : 20),
              _buildFeatureItem(
                icon: Icons.savings,
                title: 'Savings Goals',
                description: 'Set and achieve financial targets',
              ),
              SizedBox(height: compact ? 16 : 20),
              _buildFeatureItem(
                icon: Icons.insights,
                title: 'AI Insights',
                description: 'Personalized financial recommendations',
              ),
              SizedBox(height: compact ? 32 : 48),
              // Call to Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => context.go('/signin'),
                  child: Text(
                    'I already have an account',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 24 : 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
