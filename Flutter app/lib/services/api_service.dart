import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'client_stub.dart'
    if (dart.library.html) 'client_web.dart'
    if (dart.library.io) 'client_mobile.dart';

/// API abstraction layer for Cafe De Paris.
/// All API calls go through this singleton.
final String baseUrl = (kIsWeb || defaultTargetPlatform != TargetPlatform.android) 
    ? 'http://127.0.0.1:8080/v1' 
    : 'http://10.0.2.2:8080/v1';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _client = getClient();
  }

  late final http.Client _client;
  final _storage = const FlutterSecureStorage();

  Future<String?> get _cookie => _storage.read(key: 'cdp_cookie');

  Future<Map<String, String>> get _headers async {
    final c = await _cookie;
    return {
      'Content-Type': 'application/json',
      // Manual cookie header only used on mobile/desktop (not web due to forbidden headers)
      if (!kIsWeb && c != null) 'Cookie': c,
    };
  }

  Future<dynamic> get(String path) async {
    final url = '$baseUrl$path';
    debugPrint('[API GET] $url');
    try {
      final res = await _client.get(Uri.parse(url), headers: await _headers)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API GET] $url → ${res.statusCode}');
      _updateCookie(res);
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
    final bodyJson = jsonEncode(body);
    debugPrint('[API POST] $url body=$bodyJson');
    try {
      final headers = await _headers;
      debugPrint('[API POST] Headers: $headers');
      final res = await _client.post(Uri.parse(url), headers: headers, body: bodyJson)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API POST] $url → ${res.statusCode} body=${res.body}');
      _updateCookie(res);
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
    debugPrint('[API PATCH] $url body=${body != null ? jsonEncode(body) : "empty"}');
    try {
      final res = await _client.patch(Uri.parse(url), headers: await _headers, body: body != null ? jsonEncode(body) : null)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API PATCH] $url → ${res.statusCode}');
      _updateCookie(res);
      if (res.statusCode == 401) { await clearToken(); throw ApiException(401, 'Unauthorized'); }
      if (res.statusCode == 200) return jsonDecode(res.body);
      throw ApiException(res.statusCode, res.body);
    } catch (e) {
      debugPrint('[API PATCH ERROR] $url → $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    final url = '$baseUrl$path';
    debugPrint('[API DELETE] $url');
    try {
      final res = await _client.delete(Uri.parse(url), headers: await _headers)
          .timeout(const Duration(seconds: 30));
      debugPrint('[API DELETE] $url → ${res.statusCode}');
      _updateCookie(res);
      if (res.statusCode == 401) { await clearToken(); throw ApiException(401, 'Unauthorized'); }
      if (res.statusCode == 200 || res.statusCode == 204) return null;
      throw ApiException(res.statusCode, res.body);
    } catch (e) {
      debugPrint('[API DELETE ERROR] $url → $e');
      rethrow;
    }
  }

  // Auth
  Future<Map<String, dynamic>> sendOtp(String phone) async =>
      await post('/auth/otp/send', {'phone': phone}) as Map<String, dynamic>;

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async =>
      await post('/auth/otp/verify', {'phone': phone, 'code': code}) as Map<String, dynamic>;

  void _updateCookie(http.Response response) {
    if (kIsWeb) return; // Browser handles cookies on Web
    
    String? rawCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
    if (rawCookie != null) {
      debugPrint('[DEBUG] Updating cookie from: $rawCookie');
      int index = rawCookie.indexOf(';');
      String cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
      _storage.write(key: 'cdp_cookie', value: cookie);
    }
  }

  Future<void> clearToken() =>
      _storage.delete(key: 'cdp_cookie');

  Future<bool> isLoggedIn() async {
    if (kIsWeb) return true; // Assume logged in for now on Web dev
    return (await _cookie) != null;
  }

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
  Future<Map<String, dynamic>> sendToKitchen(String tableId, List<Map<String, dynamic>> items) async {
    debugPrint('[API] Sending order for table $tableId with ${items.length} items');
    return await post('/orders', {'tableId': tableId, 'items': items}) as Map<String, dynamic>;
  }
  Future<dynamic> markServed(String orderId) async =>
      await patch('/orders/${Uri.encodeComponent(orderId)}/served');
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException: $statusCode - $message';
}
