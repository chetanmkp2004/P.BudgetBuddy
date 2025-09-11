import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/transaction.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/sign_in_screen.dart';
import '../../screens/sign_up_screen.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/add_expense_screen.dart';
import '../../screens/budget_screen.dart';
import '../../screens/savings_goals_screen.dart';
import '../../screens/saved_schemes_screen.dart';
import '../../screens/settings_page.dart';

/// Professional navigation configuration with named routes and transitions
class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String addExpense = '/add-expense';
  static const String budget = '/budget';
  static const String savingsGoals = '/savings-goals';
  static const String savedSchemes = '/saved-schemes';
  static const String settings = '/settings';

  static final GoRouter _router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen
      GoRoute(
        path: welcome,
        name: 'welcome',
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const WelcomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      ),
            ),
      ),

      // Sign In Screen
      GoRoute(
        path: signIn,
        name: 'signin',
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const SignInScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      ),
            ),
      ),

      // Sign Up Screen
      GoRoute(
        path: signUp,
        name: 'signup',
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const SignUpScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                        ),
                        child: child,
                      ),
            ),
      ),

      // Dashboard Screen (Main App)
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder:
            (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) =>
                      FadeTransition(opacity: animation, child: child),
            ),
        routes: [
          // Add Expense Screen (Modal)
          GoRoute(
            path: 'add-expense',
            name: 'add-expense',
            pageBuilder: (context, state) {
              // Get transaction parameter from state if provided for editing
              final transactionParam = state.extra as TransactionModel?;
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: AddExpenseScreen(transaction: transactionParam),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOutBack)),
                          ),
                          child: child,
                        ),
              );
            },
          ),

          // Budget Screen
          GoRoute(
            path: 'budget',
            name: 'budget',
            pageBuilder:
                (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const BudgetScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: child,
                          ),
                ),
          ),

          // Savings Goals Screen
          GoRoute(
            path: 'savings-goals',
            name: 'savings-goals',
            pageBuilder:
                (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const SavingsGoalsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: child,
                          ),
                ),
          ),
          // Saved Schemes Screen
          GoRoute(
            path: 'saved-schemes',
            name: 'saved-schemes',
            pageBuilder:
                (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const SavedSchemesScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: child,
                          ),
                ),
          ),

          // Settings Screen
          GoRoute(
            path: 'app-settings',
            name: 'app-settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],

    // Error page
    errorBuilder: (context, state) => ErrorPage(error: state.error),

    // Route transition duration
    routerNeglect: true,
  );

  static GoRouter get router => _router;

  // Navigation helper methods
  static void goToWelcome(BuildContext context) {
    context.go(welcome);
  }

  static void goToSignIn(BuildContext context) {
    context.go(signIn);
  }

  static void goToSignUp(BuildContext context) {
    context.go(signUp);
  }

  static void goToDashboard(BuildContext context) {
    context.go(dashboard);
  }

  static void goToAddExpense(BuildContext context) {
    context.go('$dashboard/add-expense');
  }

  static void goToBudget(BuildContext context) {
    context.go('$dashboard/budget');
  }

  static void goToSavingsGoals(BuildContext context) {
    context.go('$dashboard/savings-goals');
  }

  static void goToSavedSchemes(BuildContext context) {
    context.go('$dashboard/saved-schemes');
  }

  static void goToSettings(BuildContext context) {
    context.go('$dashboard/app-settings');
  }

  // Navigation with replacement
  static void replaceWithDashboard(BuildContext context) {
    context.pushReplacement(dashboard);
  }

  static void replaceWithWelcome(BuildContext context) {
    context.pushReplacement(welcome);
  }

  // Pop methods
  static void pop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void popToRoot(BuildContext context) {
    while (context.canPop()) {
      context.pop();
    }
  }
}

/// Error page widget for handling navigation errors
class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => AppRouter.goToWelcome(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation utilities for better UX
class NavigationUtils {
  /// Show a modal bottom sheet with custom transition
  static void showModalSheet(
    BuildContext context,
    Widget child, {
    bool isScrollControlled = true,
    bool enableDrag = true,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: child,
          ),
    );
  }

  /// Show a custom dialog with fade animation
  static Future<T?> showCustomDialog<T>(BuildContext context, Widget child) {
    return showGeneralDialog<T>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Check if the current route is one of the main tabs
  static bool isMainRoute(String currentRoute) {
    const mainRoutes = [
      AppRouter.dashboard,
      '${AppRouter.dashboard}/budget',
      '${AppRouter.dashboard}/savings-goals',
      '${AppRouter.dashboard}/app-settings',
    ];
    return mainRoutes.contains(currentRoute);
  }
}
