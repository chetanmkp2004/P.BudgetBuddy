import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Firebase removed for mock auth mode
import '../auth/auth_state.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/sign_in_screen.dart';
import '../../screens/sign_up_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/add_expense_screen.dart';
import '../../screens/budget_screen.dart';
import '../../screens/savings_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/transactions_screen.dart';

class AppRouter {
  static GoRouter create(AuthState auth) => GoRouter(
    initialLocation: '/welcome',
    refreshListenable: auth,
    redirect: (context, state) {
      final bool isAuthenticated = auth.isAuthenticated;
      final bool isOnAuthPage = state.fullPath?.startsWith('/auth') ?? false;
      final bool isOnWelcomePage = state.fullPath == '/welcome';

      if (!isAuthenticated && !isOnAuthPage && !isOnWelcomePage) {
        return '/welcome';
      }
      if (isAuthenticated && (isOnAuthPage || isOnWelcomePage)) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      // Welcome & Authentication Routes
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main App Routes (require authentication)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        name: 'add-expense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/budget',
        name: 'budget',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/savings',
        name: 'savings',
        builder: (context, state) => const SavingsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
    ],
  );
}

// Navigation helper class
class AppNavigation {
  static void goToWelcome(BuildContext context) {
    context.go('/welcome');
  }

  static void goToSignIn(BuildContext context) {
    context.go('/auth/signin');
  }

  static void goToSignUp(BuildContext context) {
    context.go('/auth/signup');
  }

  static void goToDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  static void goToAddExpense(BuildContext context) {
    context.go('/add-expense');
  }

  static void goToBudget(BuildContext context) {
    context.go('/budget');
  }

  static void goToSavings(BuildContext context) {
    context.go('/savings');
  }

  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void goToTransactions(BuildContext context) {
    context.go('/transactions');
  }

  // Push methods (for stack navigation)
  static void pushAddExpense(BuildContext context) {
    context.push('/add-expense');
  }
}
