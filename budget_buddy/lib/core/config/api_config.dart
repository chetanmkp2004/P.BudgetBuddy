/// Central API configuration.
/// Automatically resolves the correct host depending on platform to avoid
/// 'Connection refused' errors (e.g. Android emulator needs 10.0.2.2).
///
/// For a real device on the same LAN, set [overrideBaseUrl] at app start
/// (e.g. via an env file or debug settings screen) to something like
/// 'http://192.168.1.42:8000'.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform; // ignored on web builds

class ApiConfig {
  // Defaults
  static const String _loopback = 'http://127.0.0.1:8000';
  static const String _androidEmulator = 'http://10.0.2.2:8000';

  /// Optional runtime override (e.g. set from a debug panel)
  static String? overrideBaseUrl;

  /// Resolve a base URL appropriate for the current platform.
  static String get baseUrl {
    if (overrideBaseUrl != null) return overrideBaseUrl!;
    if (kIsWeb) return _loopback; // browser shares host
    try {
      if (Platform.isAndroid) return _androidEmulator; // emulator mapping
      if (Platform.isIOS) return _loopback; // iOS simulator loopback
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return _loopback;
      }
    } catch (_) {
      // Fallback if Platform not available
    }
    return _loopback;
  }

  static const String apiKey = 'dev-mobile-key-change-me';
  static const String apiKeyHeader = 'X-Mobile-API-Key';
  // Enable verbose HTTP logging (development only)
  static const bool debug = true;
}
