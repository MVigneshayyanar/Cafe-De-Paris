import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'otp_screen.dart';

/// Screen 1 — Phone Login
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService().sendOtp(phone);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() { _phoneController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: AppColors.primaryTeal, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: FaIcon(FontAwesomeIcons.utensils, color: Colors.white, size: 24)),
              ),
              const SizedBox(height: 16),
              Text('Cafe De Paris', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
              const SizedBox(height: 2),
              Text('de Paris', style: GoogleFonts.playfairDisplay(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.goldAccent, fontStyle: FontStyle.italic)),
              const SizedBox(height: 6),
              Text('Waiter Dashboard', style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.primaryTeal)),
              const Spacer(flex: 1),
              // Phone input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone Number', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.dmSans(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      prefixIcon: const Center(widthFactor: 1.0, heightFactor: 1.0, child: FaIcon(FontAwesomeIcons.phone, color: AppColors.textSecondary, size: 16)),
                      filled: true, fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius), borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: AppColors.primaryTeal.withValues(alpha: 0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Send OTP', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'By Continuing, you agree to our '),
                      TextSpan(text: 'Terms of Service', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primaryTeal, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
