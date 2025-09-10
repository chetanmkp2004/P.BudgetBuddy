import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../auth/auth_state.dart';
import 'api_client.dart';
import 'finance_service.dart';

/// Provides a single FinanceService instance bound to current auth token.
/// Listens to AuthState changes to update token automatically.
class FinanceProvider extends ChangeNotifier {
  FinanceProvider(this._auth) {
    _service = FinanceService(
      _client,
      token: _auth.accessToken,
      onUnauthorized: _handle401,
    );
    _auth.addListener(_handleAuthChanged);
  }

  final AuthState _auth;
  final ApiClient _client = ApiClient();
  late FinanceService _service;
  FinanceService get service => _service;

  Future<bool> _handle401() async {
    final refreshed = await _auth.refresh();
    if (refreshed) {
      _service.token = _auth.accessToken;
    }
    return refreshed;
  }

  void _handleAuthChanged() {
    _service.token = _auth.accessToken; // update token when auth changes
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_handleAuthChanged);
    _client.close();
    super.dispose();
  }

  static ChangeNotifierProvider<FinanceProvider> create(AuthState auth) =>
      ChangeNotifierProvider(create: (_) => FinanceProvider(auth));
}
