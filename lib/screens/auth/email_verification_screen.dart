import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/locale_provider.dart';
import '../../widgets/developer_credits.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Periodically check every 5 seconds in background if user clicked the link
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerificationStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    setState(() => _resendCooldown = seconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() => _resendCooldown = 0);
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _checkVerificationStatus({bool silent = false}) async {
    if (!mounted || _isChecking) return;

    if (!silent) {
      setState(() => _isChecking = true);
    }

    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);

    final isVerified = await authProvider.checkEmailVerified();

    if (!mounted) return;

    if (!silent) {
      setState(() => _isChecking = false);
    }

    if (isVerified) {
      _autoCheckTimer?.cancel();
      _cooldownTimer?.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.isArabic
                ? 'تم تأكيد البريد الإلكتروني بنجاح!'
                : 'Email verified successfully!',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await authProvider.markEmailVerified();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/security-gate');
    } else if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr.emailNotVerifiedYet,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.amber.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);

    final sent = await authProvider.sendEmailVerification();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (sent) {
      _startCooldown(60);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr.verificationLinkResent,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.isArabic
                ? 'تعذر إرسال الرابط حالياً، يرجى المحاولة لاحقاً'
                : 'Failed to send verification email. Please try again later.',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();

    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userEmail = authProvider.user?.email ?? '';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [AppColors.primaryDark, AppColors.primary],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top Bar with Language Switcher
              Positioned(
                top: 12,
                left: 16,
                child: Consumer<LocaleProvider>(
                  builder: (context, localeProvider, _) {
                    return InkWell(
                      onTap: () => localeProvider.toggleLocale(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              localeProvider.isArabic ? 'English' : 'العربية',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main Centered Content
              Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animated Icon Badge
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_rounded,
                                size: 42,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Title
                            Text(
                              context.tr.verifyEmailTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle
                            Text(
                              context.tr.verifyEmailSub,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                height: 1.6,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Email Address Badge
                            if (userEmail.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.email_outlined,
                                        size: 18, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        userEmail,
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Guidance Notice
                            Text(
                              context.tr.verifyEmailCheckNotice,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                height: 1.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Button 1: Check Verification Status (Primary)
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed:
                                    _isChecking ? null : () => _checkVerificationStatus(),
                                icon: _isChecking
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.verified_rounded, size: 20),
                                label: Text(
                                  _isChecking
                                      ? context.tr.checkingVerification
                                      : context.tr.checkVerifiedBtn,
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Button 2: Resend Verification Link (Outlined)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: (_resendCooldown > 0 || _isResending)
                                    ? null
                                    : _resendVerification,
                                icon: _isResending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh_rounded, size: 18),
                                label: Text(
                                  _resendCooldown > 0
                                      ? '${context.tr.resendInSeconds} $_resendCooldown ${context.tr.secondsShort}'
                                      : context.tr.resendVerificationBtn,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Spam Folder Notice Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.amber
                                    .withValues(alpha: isDark ? 0.12 : 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber
                                      .withValues(alpha: isDark ? 0.35 : 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      size: 18, color: Colors.amber),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.tr.spamFolderNotice,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        height: 1.45,
                                        color: isDark
                                            ? Colors.amber.shade200
                                            : const Color(0xFF92400E),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Button 3: Sign Out / Change Email (Text)
                            TextButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout_rounded, size: 16),
                              label: Text(
                                context.tr.changeEmailOrSignOut,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white60
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Developer Credits at Bottom
              const Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: DeveloperCredits(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
