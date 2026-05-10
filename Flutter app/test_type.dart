void main() {
  final cartItems = [{'id': '1'}];
  final items = cartItems.map((e) => {'menuItemId': e['id'], 'quantity': 1}).toList();
  test(items);
}
void test(List<Map<String, dynamic>> items) {
  print('success');
}
