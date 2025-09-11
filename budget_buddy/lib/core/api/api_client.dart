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
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    final uri = _u(path, queryParameters);
    final h = _headers(extra: headers);
    if (ApiConfig.debug) debugPrint('[HTTP] GET  $uri\nHeaders: $headers');
    return _client.get(uri, headers: h).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} GET $uri  Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    final uri = _u(path);
    final h = _headers(extra: headers);
    final jsonBody = jsonEncode(body);
    if (ApiConfig.debug)
      debugPrint('[HTTP] POST $uri\nHeaders: $h\nBody: $jsonBody');
    return _client.post(uri, headers: h, body: jsonBody).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} POST $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) {
    final uri = _u(path);
    final h = _headers(extra: headers);
    final jsonBody = jsonEncode(body);
    if (ApiConfig.debug)
      debugPrint('[HTTP] PUT  $uri\nHeaders: $h\nBody: $jsonBody');
    return _client.put(uri, headers: h, body: jsonBody).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} PUT  $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final uri = _u(path);
    final h = _headers(extra: headers);
    if (ApiConfig.debug) debugPrint('[HTTP] DELETE $uri\nHeaders: $h');
    return _client.delete(uri, headers: h).then((r) {
      if (ApiConfig.debug)
        debugPrint(
          '[HTTP] <-- ${r.statusCode} DELETE $uri Body: ${r.body.substring(0, r.body.length.clamp(0, 500))}',
        );
      return r;
    });
  }

  void close() => _client.close();
}
