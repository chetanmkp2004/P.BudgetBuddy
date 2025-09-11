import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'biometric_service.dart';

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
  final BiometricService _biometricService = BiometricService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isBiometricsEnabled = false;
  bool _biometricsAvailable = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get loading => _loading;
  bool get isBiometricsEnabled => _isBiometricsEnabled;
  bool get biometricsAvailable => _biometricsAvailable;
  String? get email => _email;
  String? get accessToken => _accessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if biometrics are enabled and available
    _isBiometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
    _biometricsAvailable = await _biometricService.isBiometricsAvailable();

    try {
      // Try to load from secure storage first if biometrics are enabled
      if (_isBiometricsEnabled) {
        _accessToken = await _secureStorage.read(key: 'access');
        _refreshToken = await _secureStorage.read(key: 'refresh');
        _email = await _secureStorage.read(key: 'email');
      }

      // Fall back to regular storage if not found in secure storage
      if (_accessToken == null || _refreshToken == null) {
        _accessToken = prefs.getString('access');
        _refreshToken = prefs.getString('refresh');
        _email = prefs.getString('email');

        // If tokens were found in regular storage and biometrics are enabled,
        // migrate them to secure storage
        if (_isBiometricsEnabled &&
            _accessToken != null &&
            _refreshToken != null) {
          await _storeInSecureStorage();
        }
      }
    } catch (e) {
      debugPrint('Error retrieving tokens: $e');
      // Fall back to regular storage if secure storage fails
      _accessToken = prefs.getString('access');
      _refreshToken = prefs.getString('refresh');
      _email = prefs.getString('email');
    }

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

  Future<void> _storeInSecureStorage() async {
    if (_accessToken != null) {
      await _secureStorage.write(key: 'access', value: _accessToken);
    }
    if (_refreshToken != null) {
      await _secureStorage.write(key: 'refresh', value: _refreshToken);
    }
    if (_email != null) {
      await _secureStorage.write(key: 'email', value: _email);
    }
  }

  void _storeTokens(Map<String, dynamic> data, String email) async {
    _accessToken = data['access'];
    _refreshToken = data['refresh'];
    _email = email;
    _isAuthenticated = _accessToken != null;

    final prefs = await SharedPreferences.getInstance();

    // Store tokens in secure storage if biometrics are enabled
    if (_isBiometricsEnabled) {
      await _storeInSecureStorage();
    }

    // Always store in regular storage as backup
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

    // Clear from both storage locations
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('refresh');
    await prefs.remove('email');

    try {
      await _secureStorage.delete(key: 'access');
      await _secureStorage.delete(key: 'refresh');
      await _secureStorage.delete(key: 'email');
    } catch (e) {
      debugPrint('Error removing tokens from secure storage: $e');
    }

    notifyListeners();
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricsEnabled(bool enabled) async {
    if (enabled == _isBiometricsEnabled) return;

    final prefs = await SharedPreferences.getInstance();

    if (enabled) {
      // Check if biometrics are available
      final available = await _biometricService.isBiometricsAvailable();
      if (!available) {
        throw AuthException(
          'biometrics_unavailable',
          'Biometrics not available on this device',
        );
      }

      // Store current tokens in secure storage
      if (_accessToken != null && _refreshToken != null) {
        await _storeInSecureStorage();
      }
    }

    _isBiometricsEnabled = enabled;
    await prefs.setBool('biometrics_enabled', enabled);
    notifyListeners();
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    if (!_isBiometricsEnabled || !_biometricsAvailable) {
      return false;
    }

    final result = await _biometricService.authenticate(
      reason: 'Authenticate to access Budget Buddy',
    );

    if (result.success) {
      // Biometric authentication succeeded, tokens should already be loaded
      return _isAuthenticated;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return false;
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
