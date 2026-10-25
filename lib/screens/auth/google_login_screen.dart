import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/drive_api_service.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final DriveApiService _driveApiService = DriveApiService();
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);

    final success = await _driveApiService.connect();

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged in as ${_driveApiService.userEmail ?? 'Google User'}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        // Navigate to the next secure screen
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sign in failed or canceled',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark Charcoal background
    return Scaffold(
      backgroundColor: const Color(0xFF1C1E22),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimalist icon or spacing
            const Icon(
              Icons.cloud_sync_rounded,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 32),
            Text(
              'Kazena Secure Vault',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your private files, backed up\ndirectly to your personal Drive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 64),
            
            // Glassmorphism Button
            _buildGlassButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _handleSignIn,
            highlightColor: Colors.white.withValues(alpha: 0.1),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Container(
              height: 60,
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google 'G' Icon locally represented or stylized
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          child: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 24,
                            color: Color(0xFF1C1E22),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Login with Google',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
