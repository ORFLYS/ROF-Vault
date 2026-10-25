import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/security_provider.dart';
import '../../providers/vault_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../config/translations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/developer_credits.dart';
import '../../widgets/drive_permission_dialog.dart';
import '../../widgets/privacy_policy_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final vaultProvider = Provider.of<VaultProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName =
        authProvider.profile?.displayName ?? authProvider.user?.displayName ?? context.tr.vaultUser;
    final email = authProvider.profile?.email ?? authProvider.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.settingsTitle, style: GoogleFonts.cairo()),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0] : '?',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Section
          _buildSectionTitle(context.tr.secSecurity, isDark),
          const SizedBox(height: 8),
          _buildSettingsCard(isDark, [
            // Security enabled
            SwitchListTile(
              title: Text(context.tr.appProtection, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              subtitle: Text(
                context.tr.appProtectionDesc,
                style: GoogleFonts.cairo(fontSize: 12),
              ),
              secondary: const Icon(Icons.security_rounded),
              value: securityProvider.isSecurityEnabled,
              onChanged: (value) {
                if (value) {
                  _showSecuritySetupDialog(context, securityProvider);
                } else {
                  securityProvider.disableSecurity();
                }
              },
            ),

            if (securityProvider.isSecurityEnabled) ...[
              const Divider(height: 1),
              // Security method
              ListTile(
                leading: const Icon(Icons.fingerprint_rounded),
                title: Text(context.tr.securityMethodTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _getSecurityMethodLabel(context, securityProvider.securityMethod),
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
                trailing: Icon(context.isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                onTap: () =>
                    _showSecuritySetupDialog(context, securityProvider),
              ),
              const Divider(height: 1),
              // Auto-lock
              ListTile(
                leading: const Icon(Icons.timer_rounded),
                title: Text(context.tr.autoLockTimer, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  context.isArabic ? '${securityProvider.autoLockMinutes} دقيقة' : '${securityProvider.autoLockMinutes} min',
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
                trailing: Icon(context.isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                onTap: () =>
                    _showAutoLockDialog(context, securityProvider),
              ),
            ],
          ]),
          const SizedBox(height: 20),

          // Cloud Storage Section
          _buildSectionTitle(context.tr.gdriveBackup, isDark),
          const SizedBox(height: 8),
          _buildSettingsCard(isDark, [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: vaultProvider.isDriveConnected
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : Colors.amber.withValues(alpha: 0.15),
                ),
                child: Icon(
                  vaultProvider.isDriveConnected
                      ? Icons.cloud_done_rounded
                      : Icons.cloud_off_rounded,
                  color: vaultProvider.isDriveConnected
                      ? const Color(0xFF10B981)
                      : Colors.amber,
                  size: 24,
                ),
              ),
              title: Text(
                context.isArabic ? 'Google Drive (مساحتك الشخصية)' : 'Google Drive (Personal Cloud)',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              subtitle: Text(
                vaultProvider.isDriveConnected
                    ? (context.isArabic
                        ? 'متصل: ${vaultProvider.driveUserEmail ?? 'حسابك الشخصي'}\nيتم تشفير الملفات ورفعها لمجلد تطبيقك الخاص'
                        : 'Connected: ${vaultProvider.driveUserEmail ?? 'Personal Account'}\nFiles are encrypted and stored in your private app folder')
                    : (context.isArabic
                        ? 'غير متصل - مطلوب لرفع الصور، الفيديوهات، والمستندات'
                        : 'Not connected - Required to upload photos, videos, and documents'),
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              trailing: vaultProvider.isDriveConnected
                  ? OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => _showDisconnectDriveDialog(context, vaultProvider),
                      child: Text(
                        context.tr.disconnectDriveBtn,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => DrivePermissionDialog.show(context),
                      icon: const Icon(Icons.link_rounded, size: 18),
                      label: Text(
                        context.tr.connectDriveBtn,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
            ),
          ]),
          const SizedBox(height: 20),

          // Appearance & Preferences Section
          _buildSectionTitle(context.tr.secPreferences, isDark),
          const SizedBox(height: 8),
          _buildSettingsCard(isDark, [
            SwitchListTile(
              title: Text(context.tr.themeDark, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
            const Divider(height: 1),
            // Language Setting Tile
            ListTile(
              leading: const Icon(Icons.translate_rounded),
              title: Text(context.tr.languageSetting, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              subtitle: Text(
                '${context.tr.currentLanguageName} (${context.isArabic ? 'العربية' : 'English'})',
                style: GoogleFonts.cairo(fontSize: 12),
              ),
              trailing: OutlinedButton.icon(
                onPressed: () {
                  localeProvider.toggleLocale();
                },
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: Text(
                  context.tr.otherLanguageName,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // App Info Section
          _buildSectionTitle(context.tr.secAbout, isDark),
          const SizedBox(height: 8),
          _buildSettingsCard(isDark, [
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(context.tr.appVersionLabel, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              trailing: Text(
                AppConstants.appVersion,
                style: GoogleFonts.cairo(color: AppColors.textSecondary),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: Text(context.tr.privacyAndTermsNav, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
              ),
              onTap: () => PrivacyPolicyDialog.show(context),
            ),
          ]),
          const SizedBox(height: 24),

          // Sign out button
          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () => _showSignOutDialog(context),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                context.tr.signOutBtn,
                style: GoogleFonts.cairo(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Technical Support Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _launchWebUrl('https://orflys.com/support'),
              icon: const Icon(Icons.support_agent_rounded, size: 22),
              label: Text(
                context.isArabic ? 'الدعم الفني والمساعدة' : 'Technical Support & Help',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Developer Credits
          DeveloperCredits(
            textColor: isDark ? Colors.white : AppColors.textPrimary,
            subtextColor: isDark ? Colors.white54 : AppColors.textSecondary,
          ),

          const SizedBox(height: 18),

          // Official Website Button
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _launchWebUrl('https://orflys.com/'),
              icon: const Icon(Icons.language_rounded, size: 20),
              label: Text(
                context.isArabic ? 'الموقع الرسمي: orflys.com' : 'Official Website: orflys.com',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.3,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : AppColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    ),
  ),
);
  }

  Future<void> _launchWebUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch url: $urlString, error: $e');
    }
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  String _getSecurityMethodLabel(BuildContext context, String method) {
    final isAr = context.isArabic;
    switch (method) {
      case AppConstants.methodBiometric:
        return isAr
            ? 'Windows Hello (بصمة / قفل الجهاز)'
            : 'Windows Hello (Biometrics)';
      case AppConstants.methodPin:
        return isAr ? 'رمز PIN للخزنة' : 'Vault PIN Code';
      case AppConstants.methodBoth:
        return isAr ? 'Windows Hello + رمز PIN' : 'Windows Hello + PIN';
      default:
        return isAr ? 'غير مفعل' : 'Disabled';
    }
  }

  void _showSecuritySetupDialog(
      BuildContext context, SecurityProvider securityProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = context.isArabic;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'اختر طريقة الحماية' : 'Choose Protection Method',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isAr ? 'تأمين فتح الخزنة على نظام ويندوز' : 'Secure your vault on Windows',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Option 1: PIN
              _buildSecurityOptionTile(
                isDark: isDark,
                icon: Icons.pin_outlined,
                title: isAr ? 'رمز PIN مخصص (موصى به للكمبيوتر)' : 'Custom PIN (Recommended for PC)',
                subtitle: isAr ? 'رمز من 4 أرقام تدخله بسرعة عبر لوحة المفاتيح' : '4-digit code entered quickly via keyboard',
                onTap: () {
                  Navigator.pop(ctx);
                  _showPinSetupDialog(context, securityProvider, false);
                },
              ),
              const SizedBox(height: 10),

              // Option 2: Windows Hello (if available)
              if (securityProvider.isBiometricAvailable) ...[
                _buildSecurityOptionTile(
                  isDark: isDark,
                  icon: Icons.fingerprint_rounded,
                  title: isAr ? 'Windows Hello (بصمة / قفل الجهاز)' : 'Windows Hello (Fingerprint / PIN)',
                  subtitle: isAr ? 'التحقق السريع عبر بصمة الإصبع أو قفل الويندوز' : 'Fast unlock via fingerprint or Windows Hello',
                  onTap: () async {
                    await securityProvider.enableBiometric();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _buildSecurityOptionTile(
                  isDark: isDark,
                  icon: Icons.verified_user_outlined,
                  title: isAr ? 'Windows Hello + رمز PIN احتياطي' : 'Windows Hello + Backup PIN',
                  subtitle: isAr ? 'أعلى درجات الأمان مع خيارين للفتح' : 'Maximum security with dual unlock options',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showPinSetupDialog(context, securityProvider, true);
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr.cancel,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: AppColors.primary.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinSetupDialog(
      BuildContext context, SecurityProvider securityProvider, bool withBiometric) {
    String pin = '';
    bool obscurePin = true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = context.isArabic;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final canSave = pin.length >= AppConstants.minPinLength;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: Text(
              context.tr.setNewPin,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAr
                        ? 'أدخل رمز PIN مخصص (4 أرقام أو أكثر) ثم اضغط حفظ'
                        : 'Enter custom PIN (at least 4 digits) then click Save',
                    style: GoogleFonts.cairo(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: AppConstants.maxPinLength,
                    obscureText: obscurePin,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: pin.length > 6 ? 22 : 28,
                      letterSpacing: pin.length > 6 ? 6 : 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    onChanged: (v) => setDialogState(() => pin = v),
                    onSubmitted: (v) async {
                      if (v.length >= AppConstants.minPinLength) {
                        if (withBiometric) {
                          await securityProvider.enableBoth(v);
                        } else {
                          await securityProvider.enablePin(v);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••',
                      hintStyle: GoogleFonts.cairo(
                        fontSize: 26,
                        letterSpacing: 10,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: isDark ? Colors.white60 : Colors.grey,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscurePin = !obscurePin),
                        tooltip: isAr ? 'إظهار / إخفاء الرمز' : 'Show / Hide PIN',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (pin.isNotEmpty && pin.length < AppConstants.minPinLength)
                    Text(
                      isAr
                          ? 'الحد الأدنى 4 أرقام (متبقي ${AppConstants.minPinLength - pin.length})'
                          : 'Minimum 4 digits (${AppConstants.minPinLength - pin.length} remaining)',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (canSave)
                    Text(
                      isAr
                          ? 'تم إدخال ${pin.length} أرقام - اضغط حفظ أو Enter'
                          : '${pin.length} digits entered - press Save or Enter',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  context.tr.cancel,
                  style: GoogleFonts.cairo(
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: canSave
                    ? () async {
                        if (withBiometric) {
                          await securityProvider.enableBoth(pin);
                        } else {
                          await securityProvider.enablePin(pin);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    : null,
                child: Text(
                  context.tr.save,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAutoLockDialog(
      BuildContext context, SecurityProvider securityProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = context.isArabic;
    final options = [1, 3, 5, 10, 15, 30];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.timer_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              context.tr.autoLockTimer,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map(
              (minutes) => ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  securityProvider.autoLockMinutes == minutes
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: securityProvider.autoLockMinutes == minutes
                      ? AppColors.primary
                      : (isDark ? Colors.white38 : Colors.grey),
                ),
                title: Text(
                  isAr ? '$minutes دقيقة من الخمول' : '$minutes minutes of inactivity',
                  style: GoogleFonts.cairo(
                    fontWeight: securityProvider.autoLockMinutes == minutes
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  securityProvider.setAutoLockMinutes(minutes);
                  Navigator.pop(ctx);
                },
              ),
            ).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr.cancel,
              style: GoogleFonts.cairo(
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr.signOutConfirmTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr.signOutConfirmMsg,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider =
                  Provider.of<app_auth.AuthProvider>(context, listen: false);
              final secProvider =
                  Provider.of<SecurityProvider>(context, listen: false);
              final vaultProvider =
                  Provider.of<VaultProvider>(context, listen: false);

              vaultProvider.clear();
              await secProvider.clearAll();
              await authProvider.signOut();

              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(context.tr.signOutBtn, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Future<void> _showDisconnectDriveDialog(
    BuildContext context,
    VaultProvider vaultProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr.disconnectDriveBtn,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.tr.driveDisconnectConfirm,
          style: GoogleFonts.cairo(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr.disconnectDriveBtn, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vaultProvider.disconnectDrive();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تم إلغاء ربط حساب Google Drive'
                  : 'Google Drive disconnected',
              style: GoogleFonts.cairo(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

