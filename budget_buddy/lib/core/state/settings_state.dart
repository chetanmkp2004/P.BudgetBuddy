import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user app preferences (currency, language, toggles) persisted locally.
class SettingsState extends ChangeNotifier {
  static const _kCurrency = 'pref_currency';
  static const _kLanguage = 'pref_language';
  static const _kNotifications = 'pref_notifications';
  static const _kBiometric = 'pref_biometric';

  String _currency = 'USD';
  String _language = 'English';
  bool _notifications = true;
  bool _biometric = false;
  bool _loaded = false;

  String get currency => _currency;
  String get language => _language;
  bool get notifications => _notifications;
  bool get biometric => _biometric;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currency = prefs.getString(_kCurrency) ?? _currency;
    _language = prefs.getString(_kLanguage) ?? _language;
    _notifications = prefs.getBool(_kNotifications) ?? _notifications;
    _biometric = prefs.getBool(_kBiometric) ?? _biometric;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    _currency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrency, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    _notifications = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, v);
    notifyListeners();
  }

  Future<void> setBiometric(bool v) async {
    _biometric = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometric, v);
    notifyListeners();
  }
}
