import 'dart:convert';
import 'api_client.dart';
import 'endpoints.dart';
import '../../models/account.dart';
import '../../models/transaction.dart';
import 'package:http/http.dart' as http;
import '../cache/data_cache.dart';
import 'package:flutter/foundation.dart';

/// Simple contract for an auth refresh callback. Should attempt refresh and
/// return true if a new access token is available.
typedef RefreshCallback = Future<bool> Function();

/// High-level service that maps JSON responses into models.
class FinanceService {
  FinanceService(this._client, {this.token, this.onUnauthorized});
  final ApiClient _client;
  String? token; // JWT access token (access)
  RefreshCallback? onUnauthorized;

  List _extractResults(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final maybe = decoded['results'] ?? decoded['data'];
      if (maybe is List) return maybe;
      // If the viewset pagination disabled for some endpoints
      if (decoded.values.every((v) => v is! List)) return [];
    }
    if (decoded is List) return decoded;
    return [];
  }

  Future<List<AccountModel>> fetchAccounts({int page = 1}) async {
    if (page == 1) {
      final cached = DataCache.I.get<List<AccountModel>>('accounts_page1');
      if (cached != null) return cached;
    }
    final res = await _authGet(
      Endpoints.accounts,
      query: {'page': page.toString()},
    );
    final decoded = jsonDecode(res.body);
    final list = _extractResults(decoded);
    final accounts =
        list
            .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
            .toList();
    if (page == 1) {
      DataCache.I.put(
        'accounts_page1',
        accounts,
        ttl: const Duration(minutes: 2),
      );
    }
    return accounts;
  }

  Future<List<TransactionModel>> fetchTransactions({int page = 1}) async {
    final res = await _authGet(
      Endpoints.transactions,
      query: {'page': page.toString()},
    );
    final decoded = jsonDecode(res.body);
    final list = _extractResults(decoded);
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchSummary() async {
    final cached = DataCache.I.get<Map<String, dynamic>>('summary');
    if (cached != null) return cached;
    final res = await _authGet(Endpoints.summary);
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    DataCache.I.put('summary', map, ttl: const Duration(minutes: 1));
    return map;
  }

  Future<List<Map<String, dynamic>>> fetchCategories({int page = 1}) async {
    final res = await _authGet(
      Endpoints.categories,
      query: {'page': page.toString()},
    );
    final decoded = jsonDecode(res.body);
    final list = _extractResults(decoded);
    return list.cast<Map<String, dynamic>>();
  }

  /// Fetch budgets from backend. Returns list of raw maps so UI can adapt.
  Future<List<Map<String, dynamic>>> fetchBudgets({int page = 1}) async {
    if (page == 1) {
      final cached = DataCache.I.get<List<Map<String, dynamic>>>(
        'budgets_page1',
      );
      if (cached != null) return cached;
    }
    final res = await _authGet(
      Endpoints.budgets,
      query: {'page': page.toString()},
    );
    final decoded = jsonDecode(res.body);
    final list = _extractResults(decoded).cast<Map<String, dynamic>>();
    if (page == 1) {
      DataCache.I.put('budgets_page1', list, ttl: const Duration(minutes: 2));
    }
    return list;
  }

  /// Create a new transaction (expense by default direction 'out').
  Future<TransactionModel> createTransaction({
    required double amount,
    String direction = 'out',
    String? merchant,
    String? description,
    int? categoryId,
    int? accountId,
    DateTime? txnTime,
  }) async {
    final body = {
      'amount': amount,
      'direction': direction,
      if (merchant != null && merchant.isNotEmpty) 'merchant': merchant,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (categoryId != null) 'category': categoryId,
      if (accountId != null) 'account': accountId,
      'txn_time': (txnTime ?? DateTime.now()).toIso8601String(),
    };
    final res = await _authPost(Endpoints.transactions, body: body);
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    // Invalidate related cached aggregates
    DataCache.I.invalidate('summary');
    DataCache.I.invalidate('accounts_page1');
    return TransactionModel.fromJson(decoded);
  }

  // ---------- Internal helpers with 401 retry logic ---------- //

  Future<http.Response> _authGet(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    if (token == null || token!.isEmpty) {
      debugPrint(
        '[FinanceService] WARNING: _authGet called without token for $path',
      );
    }
    final res = await _client.get(
      path,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      queryParameters: query,
    );
    if (res.statusCode == 401 && onUnauthorized != null) {
      if (await onUnauthorized!()) {
        final retry = await _client.get(
          path,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
          queryParameters: query,
        );
        return retry;
      }
    }
    if (res.statusCode >= 400) {
      throw Exception('Request failed (${res.statusCode}): ${res.body}');
    }
    return res;
  }

  Future<http.Response> _authPost(String path, {Object? body}) async {
    if (token == null || token!.isEmpty) {
      debugPrint(
        '[FinanceService] WARNING: _authPost called without token for $path',
      );
    }
    final res = await _client.post(
      path,
      body: body,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
    if (res.statusCode == 401 && onUnauthorized != null) {
      if (await onUnauthorized!()) {
        final retry = await _client.post(
          path,
          body: body,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        );
        return retry;
      }
    }
    if (res.statusCode >= 400) {
      throw Exception('Request failed (${res.statusCode}): ${res.body}');
    }
    return res;
  }
}
