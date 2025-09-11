import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_state.dart';
import '../services/account_service.dart';
import '../services/budget_service.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';
import '../services/goal_service.dart';
import '../services/insight_service.dart';
import '../services/scheme_service.dart';

/// ServiceProvider aggregates all API services into a single provider
/// to avoid creating multiple instances and make them easily accessible
class ServiceProvider extends ChangeNotifier {
  final AccountService accountService;
  final BudgetService budgetService;
  final CategoryService categoryService;
  final TransactionService transactionService;
  final GoalService goalService;
  final InsightService insightService;
  final SchemeService schemeService;

  ServiceProvider(AuthState auth)
    : accountService = AccountService(auth),
      budgetService = BudgetService(auth),
      categoryService = CategoryService(auth),
      transactionService = TransactionService(auth),
      goalService = GoalService(auth),
      insightService = InsightService(auth),
      schemeService = SchemeService(auth);

  static ChangeNotifierProvider<ServiceProvider> create(AuthState auth) =>
      ChangeNotifierProvider(create: (_) => ServiceProvider(auth));
}
