import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../main_navigation.dart';

/// Screen 2 — OTP Verification
class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  String get _maskedPhone {
    final p = widget.phoneNumber;
    if (p.length > 4) return '${p.substring(0, p.length - 4).replaceAll(RegExp(r'\d'), '•')}${p.substring(p.length - 4)}';
    return p;
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 4) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService().verifyOtp(widget.phoneNumber, code);
      final token = result['token'] as String?;
      // Cookie is handled automatically by ApiService interceptor
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavigation()), (route) => false);
    } catch (e) {
      if (!mounted) return;
      _shakeController.forward().then((_) => _shakeController.reset());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (_resendCooldown > 0) return;
    try {
      await ApiService().sendOtp(widget.phoneNumber);
      setState(() => _resendCooldown = 60);
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() { _resendCooldown--; if (_resendCooldown <= 0) t.cancel(); });
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP resent successfully')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resend: $e')));
    }
  }

  @override
  void dispose() { _otpController.dispose(); _cooldownTimer?.cancel(); _shakeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: AppColors.textPrimary, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Enter verification code', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text('We sent a code to $_maskedPhone', style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeController.isAnimating ? 10 * (0.5 - _shakeController.value) * (_shakeController.value < 0.5 ? 1 : -1) : 0.0;
                  return Transform.translate(offset: Offset(offset, 0), child: child);
                },
                child: PinCodeTextField(
                  appContext: context, length: 4,
                  controller: _otpController,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  textStyle: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box, borderRadius: BorderRadius.circular(12),
                    fieldHeight: 64, fieldWidth: 56,
                    activeFillColor: AppColors.cardSurface, inactiveFillColor: AppColors.cardSurface, selectedFillColor: AppColors.cardSurface,
                    activeColor: AppColors.primaryTeal, inactiveColor: AppColors.border, selectedColor: AppColors.primaryTeal, borderWidth: 1.5,
                  ),
                  enableActiveFill: true,
                  onCompleted: (_) => _verifyOtp(),
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _resendCooldown > 0 ? null : _resendCode,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: "Didn't receive code? "),
                        TextSpan(
                          text: _resendCooldown > 0 ? 'Resend in ${_resendCooldown}s' : 'Resend',
                          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: _resendCooldown > 0 ? AppColors.textSecondary : AppColors.primaryTeal),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                    disabledBackgroundColor: AppColors.primaryTeal.withValues(alpha: 0.6),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text('Verify', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
