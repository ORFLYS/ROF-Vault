import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../config/translations.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PrivacyPolicyDialog(),
    );
  }

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchWebUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch url: $urlString, error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = context.isArabic;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 680,
          maxHeight: 760,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
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
                          context.tr.privacyAndTermsNav,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          context.tr.privacyDialogSubtitle,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: isDark ? Colors.white60 : AppColors.textSecondary,
                labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    text: context.tr.privacyPolicyTitle,
                  ),
                  Tab(
                    icon: const Icon(Icons.gavel_rounded, size: 18),
                    text: context.tr.termsOfUseTitle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Privacy Policy
                  _buildPrivacyPolicyTab(isDark, isAr),

                  // Tab 2: Terms of Use
                  _buildTermsTab(isDark, isAr),
                ],
              ),
            ),

            const Divider(height: 1),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: Row(
                children: [
                  // Read on website button
                  OutlinedButton.icon(
                    onPressed: () => _launchWebUrl('https://orflys.com/privacy'),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(
                      context.tr.readOnWebsite,
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const Spacer(),
                  // Close / Understand button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      context.tr.understoodAndAgree,
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyTab(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.enhanced_encryption_rounded,
          accentColor: const Color(0xFF10B981),
          title: isAr
              ? 'التشفير المحلي التام (Zero-Knowledge Architecture)'
              : 'Local End-to-End Encryption (Zero-Knowledge)',
          content: isAr
              ? 'تعتمد خزنة ROF Vault نظام التشفير العسكري AES-256-GCM. يتم تشفير كافة الصور، الفيديوهات، المستندات، الملاحظات، وكلمات المرور محلياً على جهازك قبل حفظها أو نقلها. المفاتيح مشتقة من بياناتك الخاصة، ولا يمتلك فريق التطوير أو أي طرف آخر مفاتيح لفك تشفير ملفاتك.'
              : 'ROF Vault operates on a strict Zero-Knowledge model with AES-256-GCM encryption. All photos, videos, documents, notes, and credentials are encrypted on your local device before transmission or storage. Encryption keys are derived locally; the developers hold no backdoors or master keys to decrypt your data.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.cloud_done_rounded,
          accentColor: const Color(0xFF0284C7),
          title: isAr
              ? 'التخزين السحابي في مساحتك الخاصة على Google Drive'
              : 'Storage in Your Personal Google Drive',
          content: isAr
              ? 'تُرفع ملفاتك المشفرة مباشرة إلى حساب Google Drive الشخصي التابع لك، داخل مجلد مخصص وخفي للتطبيق (appDataFolder). لا يتم تخزين ملفاتك على أي خوادم وسيطة خاصة بنا، ولا يستطيع أي تطبيق آخر الوصول لمجلد الخزنة السري.'
              : 'Encrypted media and files are uploaded directly to your own personal Google Drive account within an isolated application folder (appDataFolder). ROF Vault does not operate intermediate storage servers and no third-party apps can access this dedicated folder.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.fingerprint_rounded,
          accentColor: const Color(0xFF8B5CF6),
          title: isAr
              ? 'حماية Windows Hello ورمز PIN المحلي'
              : 'Windows Hello & Local PIN Protection',
          content: isAr
              ? 'عند تفعيل الحماية الحيوية، تُدار عمليات التحقق بالكامل عبر نظام تشغيل ويندوز (Windows Hello Subsystem). لا تخرج أي بصمة أو بيانات بيومترية من حاسوبك، كما يتم تشفير رمز PIN وحفظه محلياً بتقنية Windows DPAPI الآمنة.'
              : 'Biometric verification is managed directly by the native Windows Hello subsystem. No biometric telemetry ever leaves your computer. PIN codes are secured locally via Microsoft Windows DPAPI protection.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.do_not_disturb_on_rounded,
          accentColor: const Color(0xFFF59E0B),
          title: isAr
              ? 'انعدام الإعلانات وعدم تتبع أو بيع البيانات'
              : 'Zero Tracking, Zero Ads & No Data Monetization',
          content: isAr
              ? 'التطبيق خالٍ تماماً من أي شبكات إعلانية أو أدوات تتبع سلوكي. نحن لا نبيع، ولا نؤجر، ولا نشارك أي بيانات شخصية أو محتويات مخزنة مع أي شركات تسويقية أو جهات خارجية.'
              : 'The application contains absolutely no advertisements or tracking SDKs. We never monetize, sell, or share your personal files, notes, or credentials with advertising networks or third parties.',
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTermsTab(bool isDark, bool isAr) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      children: [
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.account_circle_outlined,
          accentColor: const Color(0xFF3B82F6),
          title: isAr
              ? 'الاستخدام المشروع والشخصي'
              : 'Authorized Personal & Professional Use',
          content: isAr
              ? 'صُممت الخزنة لحفظ وإدارة وتأمين بياناتك الخاصة والمهنية المشروعة. يتحمل المستخدم المسؤولية الكاملة عن شرعية وسلامة المحتويات المحفوظة داخل خزنته الشخصية.'
              : 'ROF Vault is intended for lawful personal and professional data protection. The user maintains sole responsibility for the legality and integrity of the content maintained within their vault.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.key_rounded,
          accentColor: const Color(0xFFEF4444),
          title: isAr
              ? 'مسؤولية مفاتيح الحساب ورموز الأمان'
              : 'Master Credentials Responsibility',
          content: isAr
              ? 'نظراً لأن النظام مشفر بشكل كامل بدون أي أبواب خلفية (Zero-Knowledge)، فإن المستخدم مسؤول عن تذكر كلمة المرور الرئيسية ورمز PIN الخاص به. لا يملك فريق التطوير أي إمكانية تقنية لاسترجاع الملفات إذا فُقدت مفاتيح التشفير بشكل نهائي.'
              : 'Due to uncompromising zero-knowledge architecture with no developer backdoors, users are solely responsible for retaining their master password and PIN code. The development team possesses no technical mechanism to decrypt or recover data if master access credentials are lost.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.verified_rounded,
          accentColor: const Color(0xFF10B981),
          title: isAr
              ? 'ملكية البيانات التامة للمستخدم 100%'
              : '100% User Data Ownership',
          content: isAr
              ? 'يحتفظ المستخدم بكامل حقوق الملكية الفكرية والقانونية لجميع الصور والفيديوهات والمستندات والبيانات التي يتم تخزينها داخل الخزنة، ولا يطالب المطورون بأي حقوق على أي ملف لك.'
              : 'You retain total, absolute ownership and legal rights over every file, document, and note stored in your vault. The developers claim zero ownership rights over any of your content.',
        ),
        const SizedBox(height: 12),
        _buildSectionCard(
          isDark: isDark,
          icon: Icons.support_agent_rounded,
          accentColor: const Color(0xFF6366F1),
          title: isAr
              ? 'التحديثات الدورية والدعم الفني'
              : 'Updates & Technical Support',
          content: isAr
              ? 'نحن ملتزمون بتقديم تحسينات مستمرة وتحديثات أمنية دورية للحفاظ على استقرار التطبيق. في حال وجود أي استفسار أو طلب مساعدة تقنية، يمكنك التواصل معنا مباشرة عبر: https://orflys.com/support'
              : 'We are committed to delivering continuous performance enhancements and periodic security updates. For technical inquiries and support, connect directly via: https://orflys.com/support',
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required IconData icon,
    required Color accentColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
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
                const SizedBox(height: 6),
                Text(
                  content,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    height: 1.55,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
