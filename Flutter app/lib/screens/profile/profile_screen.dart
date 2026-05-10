import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../auth/phone_login_screen.dart';

/// Screen 7 — Profile Tab (shows waiter name + phone)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const name = 'Jean-Pierre Dupont';
    const phone = '+33 6 •• •• 56 78';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryTeal, AppColors.primaryTeal.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primaryTeal.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Center(child: Text('JP', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
                  ),
                  const SizedBox(height: 20),
                  Text(name, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(phone, style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primaryTeal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppTheme.badgeRadius)),
                    child: Text('Senior Waiter', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Statistics Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Today's Performance", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatTile('Orders', '24', FontAwesomeIcons.receipt, AppColors.availableBg, AppColors.availableText),
                const SizedBox(width: 16),
                _buildStatTile('Rating', '4.9', FontAwesomeIcons.solidStar, AppColors.preparingBg, AppColors.preparingText),
              ],
            ),
            const SizedBox(height: 40),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ApiService().clearToken();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PhoneLoginScreen()), (route) => false);
                },
                icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 20),
                label: Text('Sign Out', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
