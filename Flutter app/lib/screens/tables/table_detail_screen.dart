import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/table_model.dart';
import '../../models/menu_item.dart' as models;
import '../../services/api_service.dart';
import '../../widgets/menu_item_card.dart';
import '../../main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Screen 6 — Table Detail (Order Screen)
class TableDetailScreen extends StatefulWidget {
  final TableModel table;
  const TableDetailScreen({super.key, required this.table});
  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  List<models.MenuItem> _menuItems = [];
  final Map<String, int> _quantities = {};
  // Keep a master cache of ALL items the user has ever seen/added, across categories
  final Map<String, models.MenuItem> _allItemsCache = {};
  bool _loading = true;
  bool _isSending = false;
  String _activeCategory = 'starters';

  final _categories = ['starters', 'mains', 'sides', 'drinks', 'desserts'];

  @override
  void initState() { super.initState(); _loadMenu(); }

  Future<void> _loadMenu() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService().getMenu(_activeCategory);
      if (!mounted) return;
      final items = (data as List).map<models.MenuItem>((m) => models.MenuItem.fromJson(m as Map<String, dynamic>)).toList();
      // Cache every item we load
      for (final item in items) {
        _allItemsCache[item.id] = item;
      }
      setState(() { _menuItems = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  int get _totalItems => _quantities.values.fold(0, (s, q) => s + q);

  double get _totalPrice {
    double total = 0;
    _quantities.forEach((id, qty) {
      final item = _allItemsCache[id];
      if (item != null) total += item.price * qty;
    });
    return total;
  }

  List<MapEntry<models.MenuItem, int>> get _cartItems {
    final result = <MapEntry<models.MenuItem, int>>[];
    for (final entry in _quantities.entries) {
      if (entry.value > 0) {
        final item = _allItemsCache[entry.key];
        if (item != null) {
          result.add(MapEntry(item, entry.value));
        }
      }
    }
    return result;
  }

  void _updateQty(String id, int qty) {
    setState(() {
      if (qty <= 0) {
        _quantities.remove(id);
      } else {
        _quantities[id] = qty;
      }
    });
  }

  Future<void> _sendToKitchen() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    
    final navigator = Navigator.of(context);

    try {
      final itemsList = <Map<String, dynamic>>[];
      for (final entry in _cartItems) {
        itemsList.add({'menuItemId': entry.key.id, 'quantity': entry.value});
      }
      
      debugPrint('[DEBUG] Order data: $itemsList');
      
      // Call api service directly
      await ApiService().sendToKitchen(widget.table.id, itemsList);
      
      debugPrint('[DEBUG] Order sent successfully!');
      
      if (!mounted) return;
      setState(() {
        _quantities.clear();
        _isSending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order sent to kitchen!'), backgroundColor: AppColors.successGreen)
      );
      
      navigator.pop();
    } catch (e, stackTrace) {
      debugPrint('[ERROR] _sendToKitchen failed: $e');
      debugPrint('[ERROR] StackTrace: $stackTrace');
      if (!mounted) return;
      setState(() => _isSending = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.errorRed)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.table.name),
      ),
      body: Column(
        children: [
          // Category pills
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final active = cat == _activeCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () { setState(() => _activeCategory = cat); _loadMenu(); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryTeal : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(AppTheme.badgeRadius),
                        border: Border.all(color: active ? AppColors.primaryTeal : AppColors.border),
                        boxShadow: active ? [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Menu list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 220),
                    itemCount: _menuItems.length,
                    itemBuilder: (ctx, i) {
                      final item = _menuItems[i];
                      return MenuItemCard(
                        item: item,
                        quantity: _quantities[item.id] ?? 0,
                        onQuantityChanged: (q) => _updateQty(item.id, q),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: _totalItems > 0 ? _buildOrderSheet() : null,
    );
  }

  Widget _buildOrderSheet() {
    final cart = _cartItems;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(widget.table.name, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('€${_totalPrice.toStringAsFixed(2)}', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryTeal)),
        ]),
        const SizedBox(height: 4),
        Text('$_totalItems Items', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        const Divider(color: AppColors.border),
        const SizedBox(height: 4),
        ...cart.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Expanded(child: Text('${e.value} x ${e.key.name}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            Text('€${(e.key.price * e.value).toStringAsFixed(2)}', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _updateQty(e.key.id, 0),
              child: const Icon(Icons.close, size: 18, color: AppColors.errorRed),
            ),
          ]),
        )),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _quantities.clear()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              backgroundColor: const Color(0xFFF3F4F6),
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
            ),
            child: Text('Cancel', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(
            onPressed: _isSending ? null : _sendToKitchen,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
            ),
            child: _isSending 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Send to kitchen', style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600)),
          )),
        ]),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ]),
    );
  }
}
