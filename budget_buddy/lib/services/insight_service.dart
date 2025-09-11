import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/insight.dart';
import '../core/api/api_client.dart';
import '../core/auth/auth_state.dart';

class InsightService {
  final ApiClient _client;
  final AuthState _auth;

  InsightService(this._auth) : _client = ApiClient();

  Future<List<InsightModel>> getInsights({
    bool? acknowledged,
    String? severity,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (acknowledged != null) {
      queryParams['acknowledged'] = acknowledged.toString();
    }
    if (severity != null) queryParams['severity'] = severity;

    final res = await _client.get(
      '/api/insights/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load insights: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => InsightModel.fromJson(json)).toList();
  }

  Future<InsightModel> acknowledgeInsight(int insightId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '/api/insights/$insightId/acknowledge/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to acknowledge insight: ${res.body}');
    }

    return InsightModel.fromJson(jsonDecode(res.body));
  }

  // Method to generate AI-based insights and recommendations
  Future<List<Map<String, dynamic>>> generateRecommendations() async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    try {
      // This would call a backend endpoint that would use ML/AI to analyze
      // spending patterns and suggest optimizations
      final res = await _client.get(
        '/api/insights/recommendations/', // Replace with actual endpoint
        headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      );

      if (res.statusCode != 200) {
        throw Exception('Failed to generate recommendations');
      }

      final List<dynamic> data = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Error generating recommendations: $e');

      // For demo purposes, return mock recommendations if the endpoint fails
      return [
        {
          'type': 'budget_warning',
          'title': 'Budget Alert: Groceries',
          'message':
              'You\'ve spent 80% of your groceries budget with 10 days remaining.',
          'severity': 'warning',
          'data': {
            'category': 'Groceries',
            'spent': 240,
            'budget': 300,
            'remaining_days': 10,
          },
        },
        {
          'type': 'spending_insight',
          'title': 'Dining Out Trend',
          'message':
              'You spent 15% less on dining out this month compared to last month.',
          'severity': 'info',
          'data': {
            'category': 'Dining',
            'current': 120,
            'previous': 141,
            'change': -15,
          },
        },
        {
          'type': 'saving_opportunity',
          'title': 'Subscription Savings',
          'message':
              'We identified 3 subscription services totaling \$35/month that you might want to review.',
          'severity': 'info',
          'data': {
            'count': 3,
            'total': 35,
            'services': [
              'Streaming Service A',
              'News Subscription',
              'App Premium',
            ],
          },
        },
      ];
    }
  }

  // Method to auto-categorize transactions based on description
  Future<String?> predictCategory(String description) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    try {
      final res = await _client.post(
        '/api/transactions/predict-category/', // Replace with actual endpoint
        headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
        body: {'description': description},
      );

      if (res.statusCode != 200) {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(res.body);
      return data['category_id']?.toString();
    } catch (e) {
      debugPrint('Error predicting category: $e');
      return null; // Silently fail and let the user select a category manually
    }
  }
}
