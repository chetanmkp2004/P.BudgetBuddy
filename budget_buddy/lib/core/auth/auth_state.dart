import 'dart:async';
import 'package:flutter/foundation.dart';

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);
  @override
  String toString() => 'AuthException($code, $message)';
}

class AuthState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (password.trim().isEmpty) {
      throw AuthException('empty-password', 'Password required');
    }
    if (password == 'fail') {
      throw AuthException('invalid-credentials', 'Invalid email or password');
    }
    _isAuthenticated = true;
    _email = email;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!email.contains('@')) {
      throw AuthException('invalid-email', 'Invalid email');
    }
    if (password.length < 6) {
      throw AuthException('weak-password', 'Password too short');
    }
    // Simulate account creation success
    _isAuthenticated = true;
    _email = email;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _email = null;
    notifyListeners();
  }
}
