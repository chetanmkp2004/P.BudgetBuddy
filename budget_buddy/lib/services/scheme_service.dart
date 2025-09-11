import 'dart:convert';
import '../models/scheme.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class SchemeService {
  final ApiClient _client;
  final AuthState _auth;

  SchemeService(this._auth) : _client = ApiClient();

  Future<List<SchemeModel>> getSchemes({
    bool? isFavorite,
    String? category,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (isFavorite != null) queryParams['is_favorite'] = isFavorite.toString();
    if (category != null) queryParams['category'] = category;

    final res = await _client.get(
      '/api/schemes/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load schemes: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => SchemeModel.fromJson(json)).toList();
  }

  Future<SchemeModel> saveScheme(SchemeModel scheme) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      '/api/schemes/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: scheme.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to save scheme: ${res.body}');
    }

    return SchemeModel.fromJson(jsonDecode(res.body));
  }

  Future<SchemeModel> toggleFavorite(int schemeId, bool isFavorite) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '/api/schemes/$schemeId/favorite/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: {'is_favorite': isFavorite},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update favorite status: ${res.body}');
    }

    return SchemeModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteScheme(int schemeId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '/api/schemes/$schemeId/', // Replace with actual endpoint when available
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete scheme: ${res.body}');
    }
  }

  // For now, return mock data for saved schemes since this might not be in the backend yet
  List<SchemeModel> getMockSchemes() {
    return [
      SchemeModel(
        id: 1,
        title: 'CashbackDeal',
        description: '5% cashback on all grocery purchases with XYZ Card',
        validUntil: DateTime.now().add(const Duration(days: 30)),
        discount: 5.0,
        category: 'Groceries',
      ),
      SchemeModel(
        id: 2,
        title: 'FuelPoints',
        description: 'Double fuel points on weekends at ABC Gas Station',
        validUntil: DateTime.now().add(const Duration(days: 45)),
        promoCode: 'FUEL2X',
        category: 'Transport',
      ),
      SchemeModel(
        id: 3,
        title: 'Investment Offer',
        description: 'Zero-fee trading on all ETFs for first 3 months',
        validUntil: DateTime.now().add(const Duration(days: 90)),
        url: 'https://example.com/investment-offer',
        category: 'Investment',
      ),
    ];
  }
}
