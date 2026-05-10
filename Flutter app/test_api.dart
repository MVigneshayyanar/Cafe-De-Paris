import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'http://localhost:8080/v1/orders';
  final body = {
    'tableId': '2',
    'items': [
      {'menuItemId': '4', 'quantity': 1}
    ]
  };
  try {
    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer mock-waiter-token'},
      body: jsonEncode(body)
    );
    print('Status: ${res.statusCode}');
    print('Body: ${res.body}');
  } catch(e) {
    print('Error: $e');
  }
}
