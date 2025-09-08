import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_notifier.dart';
import 'core/router/app_router.dart';
import 'core/auth/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mock mode – no Firebase initialization required.
  runApp(const BudgetBuddyApp());
}

class BudgetBuddyApp extends StatelessWidget {
  const BudgetBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeNotifier>();
          final auth = context.watch<AuthState>();
          final router = AppRouter.create(auth);
          return MaterialApp.router(
            title: 'Budget Buddy',
            debugShowCheckedModeBanner: false,
            theme: theme.light,
            darkTheme: theme.dark,
            themeMode: theme.mode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
