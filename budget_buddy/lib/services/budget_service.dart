import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/budget.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class BudgetService {
  final ApiClient _client;
  final AuthState _auth;

  BudgetService(this._auth) : _client = ApiClient();

  Future<List<BudgetModel>> getBudgets({
    String? period,
    int? categoryId,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (period != null) queryParams['period'] = period;
    if (categoryId != null) queryParams['category'] = categoryId.toString();

    final res = await _client.get(
      Endpoints.budgets,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load budgets: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => BudgetModel.fromJson(json)).toList();
  }

  Future<BudgetModel> createBudget(BudgetModel budget) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      Endpoints.budgets,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: budget.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create budget: ${res.body}');
    }

    return BudgetModel.fromJson(jsonDecode(res.body));
  }

  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '${Endpoints.budgets}/${budget.id}/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: budget.toJson(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update budget: ${res.body}');
    }

    return BudgetModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteBudget(int budgetId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '${Endpoints.budgets}/$budgetId/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete budget: ${res.body}');
    }
  }

  Future<List<BudgetModel>> getBudgetProgress({
    String? startDate,
    String? endDate,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start'] = startDate;
    if (endDate != null) queryParams['end'] = endDate;

    final res = await _client.get(
      Endpoints.budgetProgress,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load budget progress: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => BudgetModel.fromJson(json)).toList();
  }
}
