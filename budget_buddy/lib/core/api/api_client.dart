import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:flutter/foundation.dart';

/// Simple HTTP client wrapping package:http adding API key header.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Uri _u(String path, [Map<String, dynamic>? query]) {
    final clean = path.trim();
    final joined = clean.startsWith('/') ? clean : '/$clean';
    return Uri.parse(
      ApiConfig.baseUrl + joined,
    ).replace(queryParameters: query);
  }

  Map<String, String> _headers({Map<String, String>? extra, String? token}) {
    final h = <String, String>{
      'Content-Type': 'application/json',
      ApiConfig.apiKeyHeader: ApiConfig.apiKey,
    };
    if (token != null) h['Authorization'] = 'Bearer $token';
    if (extra != null) h.addAll(extra);
    return h;
  }

  Future<http.Response> get(
    String path, {
    Map<String, dynamic>? query,
    String? token,
  }) {
    final uri = _u(path, query);
    final headers = _headers(token: token);
    if (ApiConfig.debug) debugPrint('[HTTP] GET  $uri\nHeaders: $headers');
    return _client.get(uri, headers: headers).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} GET $uri  Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> post(String path, {Object? body, String? token}) {
    final uri = _u(path);
    final headers = _headers(token: token);
    final jsonBody = jsonEncode(body);
    if (ApiConfig.debug)
      debugPrint('[HTTP] POST $uri\nHeaders: $headers\nBody: $jsonBody');
    return _client.post(uri, headers: headers, body: jsonBody).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} POST $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> put(String path, {Object? body, String? token}) {
    final uri = _u(path);
    final headers = _headers(token: token);
    final jsonBody = jsonEncode(body);
    if (ApiConfig.debug)
      debugPrint('[HTTP] PUT  $uri\nHeaders: $headers\nBody: $jsonBody');
    return _client.put(uri, headers: headers, body: jsonBody).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} PUT  $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> delete(String path, {String? token}) {
    final uri = _u(path);
    final headers = _headers(token: token);
    if (ApiConfig.debug) debugPrint('[HTTP] DELETE $uri\nHeaders: $headers');
    return _client.delete(uri, headers: headers).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} DELETE $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  void close() => _client.close();
}
