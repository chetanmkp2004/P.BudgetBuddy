import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_notifier.dart';
import 'core/router/app_router.dart';
import 'core/auth/auth_state.dart';
import 'core/api/finance_provider.dart';
import 'core/state/settings_state.dart';
// API client auto-injects the mobile API key header defined in ApiConfig.
// import 'core/api/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthState();
  await auth.init();
  final settings = SettingsState();
  await settings.load();
  runApp(BudgetBuddyRoot(auth: auth, settings: settings));
}

class BudgetBuddyRoot extends StatelessWidget {
  const BudgetBuddyRoot({
    super.key,
    required this.auth,
    required this.settings,
  });
  final AuthState auth;
  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider<AuthState>.value(value: auth),
        ChangeNotifierProvider<SettingsState>.value(value: settings),
        FinanceProvider.create(auth),
      ],
      child: Builder(
        builder: (context) {
          final theme = context.watch<ThemeNotifier>();
          final auth = context.watch<AuthState>();
          return MaterialApp(
            title: 'Budget Buddy',
            debugShowCheckedModeBanner: false,
            theme: theme.light,
            darkTheme: theme.dark,
            themeMode: theme.mode,
            initialRoute: RoutePaths.welcome,
            onGenerateRoute: onGenerateRoute,
            home: buildHome(auth),
          );
        },
      ),
    );
  }
}
