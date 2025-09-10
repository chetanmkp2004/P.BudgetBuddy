import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);
  @override
  String toString() => 'AuthException($code, $message)';
}

class AuthState extends ChangeNotifier {
  bool _loading = false;
  bool _isAuthenticated = false;
  String? _email;
  String? _accessToken;
  String? _refreshToken;
  final ApiClient _client = ApiClient();

  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;
  String? get email => _email;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access');
    _refreshToken = prefs.getString('refresh');
    _email = prefs.getString('email');
    _isAuthenticated = _accessToken != null && _accessToken!.isNotEmpty;
    notifyListeners();
  }

  Future<void> register(
    String email,
    String password, {
    double? monthlyIncome,
  }) async {
    final body = {
      'email': email,
      'password': password,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
    };
    await _authRequest(Endpoints.token, email, password, registerBody: body);
  }

  Future<void> signIn(String email, String password) async {
    await _authRequest(Endpoints.token, email, password);
  }

  Future<void> _authRequest(
    String path,
    String email,
    String password, {
    Map<String, dynamic>? registerBody,
  }) async {
    _setLoading(true);
    try {
      if (registerBody != null) {
        final regRes = await _client.post(
          '/api/auth/register/',
          body: registerBody,
        );
        if (regRes.statusCode != 201) {
          throw AuthException('register_failed', regRes.body);
        }
        final decoded = jsonDecode(regRes.body);
        _storeTokens(decoded, email);
      } else {
        final res = await _client.post(
          path,
          body: {'username': email, 'password': password},
        );
        if (res.statusCode != 200) {
          throw AuthException('login_failed', res.body);
        }
        final decoded = jsonDecode(res.body);
        _storeTokens(decoded, email);
      }
    } finally {
      _setLoading(false);
    }
  }

  void _storeTokens(Map<String, dynamic> data, String email) async {
    _accessToken = data['access'];
    _refreshToken = data['refresh'];
    _email = email;
    _isAuthenticated = _accessToken != null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access', _accessToken ?? '');
    await prefs.setString('refresh', _refreshToken ?? '');
    await prefs.setString('email', _email ?? '');
    debugPrint(
      '[AuthState] Logged in as $email, access token length: ${_accessToken?.length ?? 0}',
    );
    notifyListeners();
  }

  Future<bool> ensureToken() async {
    if (_accessToken == null && _refreshToken != null) {
      return await refresh();
    }
    return _accessToken != null;
  }

  Future<bool> refresh() async {
    if (_refreshToken == null) return false;
    final res = await _client.post(
      Endpoints.tokenRefresh,
      body: {'refresh': _refreshToken},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _accessToken = data['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access', _accessToken ?? '');
      notifyListeners();
      return true;
    }
    signOut();
    return false;
  }

  void signOut() async {
    _accessToken = null;
    _refreshToken = null;
    _email = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
    await prefs.remove('email');
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
