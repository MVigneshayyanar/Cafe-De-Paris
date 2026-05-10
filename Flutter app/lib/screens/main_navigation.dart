import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import 'service/service_screen.dart';
import 'tables/tables_screen.dart';
import 'profile/profile_screen.dart';

/// Main navigation shell with bottom nav bar (3 tabs)
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final _screens = const [
    ServiceScreen(),
    TablesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(0, FontAwesomeIcons.bell, FontAwesomeIcons.solidBell, 'Service'),
                _buildNavItem(1, FontAwesomeIcons.tableCells, FontAwesomeIcons.tableCellsLarge, 'Tables'),
                _buildNavItem(2, FontAwesomeIcons.user, FontAwesomeIcons.solidUser, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryTeal : AppColors.textSecondary,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
