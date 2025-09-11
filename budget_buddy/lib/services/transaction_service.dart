import 'dart:convert';
import '../models/transaction.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class TransactionService {
  final ApiClient _client;
  final AuthState _auth;

  TransactionService(this._auth) : _client = ApiClient();

  Future<List<TransactionModel>> getTransactions({
    String? direction,
    String? startDate,
    String? endDate,
    double? minAmount,
    double? maxAmount,
    int? accountId,
    int? categoryId,
    bool? isPending,
    int? page,
    int? pageSize,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (startDate != null) queryParams['txn_time__date__gte'] = startDate;
    if (endDate != null) queryParams['txn_time__date__lte'] = endDate;
    if (minAmount != null) queryParams['amount__gte'] = minAmount.toString();
    if (maxAmount != null) queryParams['amount__lte'] = maxAmount.toString();
    if (accountId != null) queryParams['account'] = accountId.toString();
    if (categoryId != null) queryParams['category'] = categoryId.toString();
    if (isPending != null) queryParams['is_pending'] = isPending.toString();
    if (page != null) queryParams['page'] = page.toString();
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();

    final res = await _client.get(
      Endpoints.transactions,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load transactions: ${res.body}');
    }

    final Map<String, dynamic> data = jsonDecode(res.body);
    final List<dynamic> results = data['results'] ?? [];
    return results.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      Endpoints.transactions,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: transaction.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create transaction: ${res.body}');
    }

    return TransactionModel.fromJson(jsonDecode(res.body));
  }

  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '${Endpoints.transactions}/${transaction.id}/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: transaction.toJson(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update transaction: ${res.body}');
    }

    return TransactionModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '${Endpoints.transactions}/$transactionId/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete transaction: ${res.body}');
    }
  }

  Future<List<dynamic>> getCategorySpending({
    String? startDate,
    String? endDate,
  }) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start'] = startDate;
    if (endDate != null) queryParams['end'] = endDate;

    final res = await _client.get(
      Endpoints.categorySpending,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      queryParameters: queryParams,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load category spending: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is List) return data;
    return [];
  }
}
