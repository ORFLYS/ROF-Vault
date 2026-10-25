import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/vault_provider.dart';

class DrivePermissionDialog extends StatefulWidget {
  final String? customTitle;
  final String? customDescription;

  const DrivePermissionDialog({
    super.key,
    this.customTitle,
    this.customDescription,
  });

  /// Static helper to display the dialog easily from anywhere in the app
  static Future<bool> show(
    BuildContext context, {
    String? customTitle,
    String? customDescription,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DrivePermissionDialog(
        customTitle: customTitle,
        customDescription: customDescription,
      ),
    );
    return result ?? false;
  }

  @override
  State<DrivePermissionDialog> createState() => _DrivePermissionDialogState();
}

class _DrivePermissionDialogState extends State<DrivePermissionDialog> {
  bool _isConnecting = false;
  String? _errorMessage;

  Future<void> _handleConnect(VaultProvider vaultProvider) async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final success = await vaultProvider.connectDrive();
      if (!mounted) return;

      setState(() => _isConnecting = false);

      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${context.tr.driveConnectedSuccess}: ${vaultProvider.driveUserEmail ?? ''}',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = context.isArabic
              ? 'لم تكتمل عملية الربط أو تم إلغاؤها من المتصفح'
              : 'Connection was cancelled or not completed in browser';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _errorMessage = 'حدث خطأ أثناء الاتصال: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header with glowing gradient
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cloud_sync_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                widget.customTitle ?? context.tr.driveDialogTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Privacy & Security Tag
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 15,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.isArabic
                            ? 'مشفر من طرف إلى طرف ومحمي بالكامل'
                            : 'End-to-End Encrypted & Private',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Description Text
              Text(
                widget.customDescription ??
                    (context.isArabic
                        ? 'تتيح لك الخزنة تخزين صورك ومقاطع الفيديو والمستندات في مساحتك الشخصية على Google Drive بشكل مشفر داخل مجلد مخفي وخاص بالتطبيق.\n\nلا يمكن لأي جهة الاطلاع على ملفاتك، ولك حرية الموافقة الآن أو إبقاء التخزين محلياً والمزامنة لاحقاً.'
                        : 'The vault allows storing your photos, videos, and documents in your personal Google Drive in an encrypted hidden app folder.\n\nNo external app can access your files. You are free to connect now or keep storage local.'),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13.5,
                  height: 1.6,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),

              // Error Message if any
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Actions
              if (_isConnecting)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.isArabic
                            ? 'جاري فتح المتصفح لربط حساب Google...'
                            : 'Opening browser to link Google account...',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () => _handleConnect(vaultProvider),
                  icon: const Icon(Icons.link_rounded, size: 20),
                  label: Text(
                    context.tr.driveDialogConnect,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    context.tr.driveDialogSkip,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
