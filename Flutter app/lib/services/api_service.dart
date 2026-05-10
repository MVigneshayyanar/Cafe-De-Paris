import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// API abstraction layer for Cafe De Paris.
/// All API calls go through this singleton.
final String baseUrl = (kIsWeb || defaultTargetPlatform != TargetPlatform.android) 
    ? 'http://localhost:8080/v1' 
    : 'http://10.0.2.2:8080/v1';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();

  Future<String?> get _token => _storage.read(key: 'cdp_token');

  Future<Map<String, String>> get _headers async {
    final t = await _token;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${t ?? ""}',
    };
  }

  Future<dynamic> get(String path) async {
    final url = '$baseUrl$path';
    debugPrint('[API GET] $url');
    try {
      final res = await http.get(Uri.parse(url), headers: await _headers)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API GET] $url → ${res.statusCode}');
      if (res.statusCode == 401) { await clearToken(); throw ApiException(401, 'Unauthorized'); }
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw ApiException(res.statusCode, res.body);
    } catch (e) {
      debugPrint('[API GET ERROR] $url → $e');
      rethrow;
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final url = '$baseUrl$path';
    debugPrint('[API POST] $url body=${jsonEncode(body)}');
    try {
      debugPrint('[DEBUG] Actually calling http.post now...');
      final res = await http.post(Uri.parse(url), headers: await _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      debugPrint('[API POST] $url → ${res.statusCode}');
      debugPrint('[DEBUG] Response body: ${res.body}');
      if (res.statusCode == 401) { await clearToken(); throw ApiException(401, 'Unauthorized'); }
      if (res.statusCode == 200 || res.statusCode == 201) return jsonDecode(res.body);
      throw ApiException(res.statusCode, res.body);
    } catch (e) {
      debugPrint('[API POST ERROR] $url → $e');
      rethrow;
    }
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    final url = '$baseUrl$path';
    debugPrint('[API PATCH] $url');
    try {
      final res = await http.patch(Uri.parse(url), headers: await _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API PATCH] $url → ${res.statusCode}');
      if (res.statusCode == 401) { await clearToken(); throw ApiException(401, 'Unauthorized'); }
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw ApiException(res.statusCode, res.body);
    } catch (e) {
      debugPrint('[API PATCH ERROR] $url → $e');
      rethrow;
    }
  }

  // Auth
  Future<Map<String, dynamic>> sendOtp(String phone) async =>
      await post('/auth/otp/send', {'phone': phone}) as Map<String, dynamic>;

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async =>
      await post('/auth/otp/verify', {'phone': phone, 'code': code}) as Map<String, dynamic>;

  Future<void> saveToken(String token) =>
      _storage.write(key: 'cdp_token', value: token);

  Future<void> clearToken() =>
      _storage.delete(key: 'cdp_token');

  Future<bool> isLoggedIn() async => (await _token) != null;

  // Tables
  Future<List> getTables() async => await get('/tables') as List;
  Future<Map<String, dynamic>> getTable(String id) async => await get('/tables/$id') as Map<String, dynamic>;
  Future<dynamic> updateTableStatus(String id, String status) async => await patch('/tables/$id/status', {'status': status});

  // Menu
  Future<List> getMenu([String? category]) async {
    final path = category != null ? '/menu?category=$category' : '/menu';
    return await get(path) as List;
  }

  // Orders
  Future<List> getOrders() async => await get('/orders') as List;
  Future<Map<String, dynamic>> sendToKitchen(String tableId, List<Map<String, dynamic>> items) async =>
      await post('/orders', {'tableId': tableId, 'items': items}) as Map<String, dynamic>;
  Future<dynamic> markServed(String orderId) async =>
      await patch('/orders/${Uri.encodeComponent(orderId)}/served');
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
