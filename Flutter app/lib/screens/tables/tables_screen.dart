import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/status_badge.dart';
import '../../models/table_model.dart';
import 'table_detail_screen.dart';

/// Screen 5 — Tables Tab
class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});
  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<TableModel> _tables = [];
  bool _loading = true;
  Timer? _pollingTimer;

  @override
  void initState() { 
    super.initState(); 
    _loadTables(); 
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadTables());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTables() async {
    try {
      final data = await ApiService().getTables();
      if (!mounted) return;
      setState(() { 
        _tables = (data as List).map<TableModel>((t) => TableModel.fromJson(t as Map<String, dynamic>)).toList(); 
        for (var t in _tables) {
          debugPrint('[DEBUG] Table ${t.name} status: ${t.status} (raw: ${t.status.name})');
        }
        _loading = false; 
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0, centerTitle: true,
        title: Text('Tables', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9, 
                ),
                itemCount: _tables.length,
                itemBuilder: (ctx, i) {
                  final table = _tables[i];
                  final canOrder = table.status != TableStatus.billed;
                  final showBilled = table.status == TableStatus.eating;
                  final showAvailable = table.status == TableStatus.billed;

                  return GestureDetector(
                    onTap: canOrder ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => TableDetailScreen(table: table))).then((_) => _loadTables()) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Beautiful Icon Container
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryTeal.withValues(alpha: 0.15),
                                          AppColors.primaryTeal.withValues(alpha: 0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.chair, 
                                        color: AppColors.primaryTeal,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    table.name,
                                    style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  StatusBadge.fromTableStatus(table.status),
                                ],
                              ),
                            ),
                          ),
                          
                          // Quick Action Buttons
                          if (showBilled || showAvailable)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  if (showBilled)
                                    Expanded(
                                      child: _actionButton(
                                        'Bill',
                                        FontAwesomeIcons.receipt,
                                        AppColors.billingText,
                                        () async {
                                          await ApiService().updateTableStatus(table.id, 'billed');
                                          _loadTables();
                                        },
                                      ),
                                    ),
                                  if (showAvailable)
                                    Expanded(
                                      child: _actionButton(
                                        'Free',
                                        FontAwesomeIcons.rotateRight,
                                        AppColors.successGreen,
                                        () async {
                                          await ApiService().updateTableStatus(table.id, 'available');
                                          _loadTables();
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30, // Even smaller for a boutique feel
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
