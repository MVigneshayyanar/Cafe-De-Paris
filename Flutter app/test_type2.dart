void main() {
  final cartItems = [MapEntry(MenuItem('1'), 2)];
  final items = cartItems.map((e) => {'menuItemId': e.key.id, 'quantity': e.value}).toList();
  try {
    test(items);
  } catch(e) {
    print('Error: $e');
  }
}
class MenuItem {
  final String id;
  MenuItem(this.id);
}
void test(List<Map<String, dynamic>> items) {
  print('success');
}
