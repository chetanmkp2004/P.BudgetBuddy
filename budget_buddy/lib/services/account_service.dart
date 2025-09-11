import 'dart:convert';
import '../models/account.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class AccountService {
  final ApiClient _client;
  final AuthState _auth;

  AccountService(this._auth) : _client = ApiClient();

  Future<List<AccountModel>> getAccounts({
    String? type,
    bool? isActive,
    String? currency,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (isActive != null) queryParams['is_active'] = isActive.toString();
    if (currency != null) queryParams['currency'] = currency;

    final res = await _client.get(
      Endpoints.accounts,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load accounts: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => AccountModel.fromJson(json)).toList();
  }

  Future<AccountModel> createAccount(AccountModel account) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      Endpoints.accounts,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: account.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create account: ${res.body}');
    }

    return AccountModel.fromJson(jsonDecode(res.body));
  }

  Future<AccountModel> updateAccount(AccountModel account) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '${Endpoints.accounts}/${account.id}/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: account.toJson(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update account: ${res.body}');
    }

    return AccountModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteAccount(String accountId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '${Endpoints.accounts}/$accountId/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete account: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> getSummary() async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.get(
      Endpoints.summary,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load summary: ${res.body}');
    }

    return jsonDecode(res.body);
  }
}
