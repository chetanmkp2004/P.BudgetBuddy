import 'package:flutter/material.dart';
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

class RoutePaths {
  static const welcome = '/welcome';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const dashboard = '/dashboard';
  static const addExpense = '/add-expense';
  static const budget = '/budget';
  static const savings = '/savings';
  static const settings = '/settings';
  static const transactions = '/transactions';
}

/// Simple auth gate deciding initial home.
Widget buildHome(AuthState auth) =>
    auth.isAuthenticated ? const DashboardScreen() : const WelcomeScreen();

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RoutePaths.welcome:
      return _page(const WelcomeScreen());
    case RoutePaths.signIn:
      return _page(const SignInScreen());
    case RoutePaths.signUp:
      return _page(const SignUpScreen());
    case RoutePaths.dashboard:
      return _page(const DashboardScreen());
    case RoutePaths.addExpense:
      return _page(const AddExpenseScreen());
    case RoutePaths.budget:
      return _page(const BudgetScreen());
    case RoutePaths.savings:
      return _page(const SavingsScreen());
    case RoutePaths.settings:
      return _page(const SettingsScreen());
    case RoutePaths.transactions:
      return _page(const TransactionsScreen());
  }
  return null; // fallback to unknown route handler if provided
}

PageRoute<dynamic> _page(Widget child) =>
    MaterialPageRoute(builder: (_) => child);

class Nav {
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? args,
  }) => Navigator.of(context).pushNamed<T>(routeName, arguments: args);
  static void replace(BuildContext context, String routeName, {Object? args}) =>
      Navigator.of(context).pushReplacementNamed(routeName, arguments: args);
  static void toDashboard(BuildContext context) =>
      replace(context, RoutePaths.dashboard);
  static void toSignIn(BuildContext context) =>
      replace(context, RoutePaths.signIn);
  static void toSignUp(BuildContext context) =>
      push(context, RoutePaths.signUp);
  static void back(BuildContext context) => Navigator.of(context).pop();
}
