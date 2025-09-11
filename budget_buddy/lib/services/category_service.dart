import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/auth/auth_state.dart';

class CategoryService {
  final ApiClient _client;
  final AuthState _auth;

  CategoryService(this._auth) : _client = ApiClient();

  Future<List<CategoryModel>> getCategories() async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.get(
      Endpoints.categories,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load categories: ${res.body}');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<CategoryModel> createCategory(CategoryModel category) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.post(
      Endpoints.categories,
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: category.toJson(),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create category: ${res.body}');
    }

    return CategoryModel.fromJson(jsonDecode(res.body));
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.put(
      '${Endpoints.categories}/${category.id}/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
      body: category.toJson(),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update category: ${res.body}');
    }

    return CategoryModel.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteCategory(int categoryId) async {
    if (!(await _auth.ensureToken())) throw Exception('Not authenticated');

    final res = await _client.delete(
      '${Endpoints.categories}/$categoryId/',
      headers: {'Authorization': 'Bearer ${_auth.accessToken}'},
    );

    if (res.statusCode != 204) {
      throw Exception('Failed to delete category: ${res.body}');
    }
  }
}
