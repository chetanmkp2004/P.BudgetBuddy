import 'dart:convert';
import '../models/goal.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class GoalService {
  final ApiClient _client;
  final AuthState _auth;

  GoalService(this._auth) : _client = ApiClient();

  Future<List<GoalModel>> getGoals({String? status}) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;

    final res = await _client.get(
      '/api/goals/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load goals: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => GoalModel.fromJson(json)).toList();
  }

  Future<GoalModel> createGoal(GoalModel goal) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      '/api/goals/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: goal.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create goal: ${res.body}');
    }

    return GoalModel.fromJson(jsonDecode(res.body));
  }

  Future<GoalModel> updateGoal(GoalModel goal) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '/api/goals/${goal.id}/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: goal.toJson(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update goal: ${res.body}');
    }

    return GoalModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteGoal(int goalId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '/api/goals/$goalId/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete goal: ${res.body}');
    }
  }

  Future<GoalContribution> addContribution(
    int goalId,
    GoalContribution contribution,
  ) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      '/api/goals/$goalId/contributions/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: contribution.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to add contribution: ${res.body}');
    }

    return GoalContribution.fromJson(jsonDecode(res.body));
  }
}
