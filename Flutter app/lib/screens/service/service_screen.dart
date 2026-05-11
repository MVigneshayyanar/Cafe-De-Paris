import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../widgets/order_card.dart';
import '../../main.dart';

/// Screen 4 — Service Tab
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});
  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;
  Timer? _pollingTimer;

  @override
  void initState() { 
    super.initState(); 
    _loadOrders(); 
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadOrders()); 
  }

  @override
  void dispose() { 
    _pollingTimer?.cancel(); 
    super.dispose(); 
  }

  Future<void> _loadOrders() async {
    try {
      final data = await ApiService().getOrders();
      if (!mounted) return;
      setState(() {
        _orders = (data as List).map<Order>((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markServed(String orderId) async {
    try {
      await ApiService().markServed(orderId);
      await _loadOrders();
      
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: const Text('Order marked as served'), 
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text('Failed: $e'), 
        backgroundColor: AppColors.errorRed
      ));
    }
  }

  List<Order> _byStatus(OrderStatus s) => _orders.where((o) => o.status == s).toList();

  @override
  Widget build(BuildContext context) {
    final ready = _byStatus(OrderStatus.ready);
    final preparing = _byStatus(OrderStatus.preparing);
    final awaiting = _byStatus(OrderStatus.awaitingPayment);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Dashboard'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  FaIcon(FontAwesomeIcons.wifi, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Connection lost', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Check your internet and try again', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadOrders, 
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                    child: const Text('Retry')
                  ),
                ]))
              : RefreshIndicator(
                  onRefresh: _loadOrders, color: AppColors.primaryTeal,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (ready.isNotEmpty) ...[
                        _header('Ready to Serve', ready.length, AppColors.readyBg, AppColors.readyText),
                        ...ready.map((o) => OrderCard(order: o, onMarkServed: () => _markServed(o.id))),
                      ],
                      if (preparing.isNotEmpty) ...[
                        _header('Preparing', preparing.length, AppColors.preparingBg, AppColors.preparingText),
                        ...preparing.map((o) => OrderCard(order: o)),
                      ],

                      if (_byStatus(OrderStatus.newOrder).isNotEmpty) ...[
                        _header('New Orders', _byStatus(OrderStatus.newOrder).length, AppColors.cardSurface, AppColors.textSecondary),
                        ..._byStatus(OrderStatus.newOrder).map((o) => OrderCard(order: o)),
                      ],
                      if (awaiting.isNotEmpty) ...[
                        _header('Awaiting Payment', awaiting.length, AppColors.billingBg, AppColors.billingText),
                        ...awaiting.map((o) => OrderCard(order: o)),
                      ],
                      if (ready.isEmpty && preparing.isEmpty && _byStatus(OrderStatus.newOrder).isEmpty && awaiting.isEmpty) 
                        _emptyState(),
                    ],
                  ),
                ),
    );
  }

  Widget _header(String title, int count, Color bg, Color fg) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppTheme.badgeRadius)),
        child: Text('$title • $count', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.5)),
      ),
    ]),
  );

  Widget _emptyState() => Padding(
    padding: const EdgeInsets.only(top: 100),
    child: Column(children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(color: AppColors.readyBg, shape: BoxShape.circle),
        child: const FaIcon(FontAwesomeIcons.solidCircleCheck, size: 40, color: AppColors.readyText),
      ),
      const SizedBox(height: 24),
      Text('No order found', style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      Text('Your service dashboard is empty', style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textSecondary)),
    ]),
  );
}
