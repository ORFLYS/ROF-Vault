import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/vault_provider.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';
import '../../widgets/vault_card.dart';
import '../../widgets/drive_permission_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static bool _hasPromptedDriveInSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDriveOnboarding();
    });
  }

  Future<void> _checkDriveOnboarding() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
    if (!vaultProvider.isDriveConnected && !_hasPromptedDriveInSession) {
      _hasPromptedDriveInSession = true;
      await DrivePermissionDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counts = vaultProvider.itemCounts;

    final displayName =
        authProvider.profile?.displayName ?? authProvider.user?.displayName ?? 'مستخدم';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final int crossAxisCount = screenWidth >= 1150
                    ? 3
                    : (screenWidth >= 720 ? 3 : 2);
                final double childAspectRatio = screenWidth >= 1150
                    ? 1.65
                    : (screenWidth >= 850 ? 1.5 : (screenWidth >= 600 ? 1.35 : 1.15));

                return CustomScrollView(
                  slivers: [
                    // Desktop Top Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                        child: Row(
                          children: [
                            // User avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
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
                                    _getGreeting(context.isArabic),
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white54
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    displayName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Security status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF6FF),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: AppColors.success,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.isArabic
                                        ? 'تشفير تام AES-256'
                                        : 'AES-256 Encrypted',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stats Hero Banner
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
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
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.isArabic
                                        ? 'خزينتك محمية ومؤمنة بالكامل'
                                        : 'Your vault is fully secured & private',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    context.isArabic
                                        ? '${_getTotalItems(counts)} عنصر محفوظ بأمان داخل الخزنة المشفرة'
                                        : '${_getTotalItems(counts)} items safely secured in encrypted vault',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 22, 28, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr.vaultCategories,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              context.isArabic ? '6 أقسام رئيسية' : '6 Categories',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section cards grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      sliver: SliverGrid(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        delegate: SliverChildListDelegate([
                          VaultCard(
                            title: context.tr.galleryTitle,
                            subtitle: context.isArabic ? 'ملف وسائط' : 'media files',
                            icon: Icons.perm_media_rounded,
                            accentColor: AppColors.galleryAccent,
                            backgroundColor: AppColors.galleryAccentLight,
                            itemCount: counts['gallery'] ??
                                ((counts['photos'] ?? 0) + (counts['videos'] ?? 0)),
                            onTap: () => Navigator.pushNamed(context, '/gallery'),
                            animationIndex: 0,
                          ),
                          VaultCard(
                            title: context.tr.catDocuments,
                            subtitle: context.isArabic ? 'مستند' : 'documents',
                            icon: Icons.folder_rounded,
                            accentColor: AppColors.documentsAccent,
                            backgroundColor: AppColors.documentsAccentLight,
                            itemCount: counts['documents'] ?? 0,
                            onTap: () => Navigator.pushNamed(context, '/documents'),
                            animationIndex: 1,
                          ),
                          VaultCard(
                            title: context.tr.catAccounts,
                            subtitle: context.isArabic ? 'حساب' : 'accounts',
                            icon: Icons.key_rounded,
                            accentColor: AppColors.accountsAccent,
                            backgroundColor: AppColors.accountsAccentLight,
                            itemCount: counts['accounts'] ?? 0,
                            onTap: () => Navigator.pushNamed(context, '/accounts'),
                            animationIndex: 2,
                          ),
                          VaultCard(
                            title: context.tr.catNotes,
                            subtitle: context.isArabic ? 'ملاحظة' : 'notes',
                            icon: Icons.note_alt_rounded,
                            accentColor: AppColors.notesAccent,
                            backgroundColor: AppColors.notesAccentLight,
                            itemCount: counts['notes'] ?? 0,
                            onTap: () => Navigator.pushNamed(context, '/notes'),
                            animationIndex: 3,
                          ),
                          VaultCard(
                            title: context.tr.cardsTitle,
                            subtitle: context.isArabic ? 'بطاقة' : 'cards',
                            icon: Icons.credit_card_rounded,
                            accentColor: AppColors.cardsAccent,
                            backgroundColor: AppColors.cardsAccentLight,
                            itemCount: counts['cards'] ?? 0,
                            onTap: () => Navigator.pushNamed(context, '/cards'),
                            animationIndex: 4,
                          ),
                          VaultCard(
                            title: context.tr.identitiesTitle,
                            subtitle: context.isArabic ? 'وثيقة' : 'IDs',
                            icon: Icons.badge_rounded,
                            accentColor: AppColors.identitiesAccent,
                            backgroundColor: AppColors.identitiesAccentLight,
                            itemCount: counts['identities'] ?? 0,
                            onTap: () => Navigator.pushNamed(context, '/identities'),
                            animationIndex: 5,
                          ),
                        ]),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting(bool isArabic) {
    final hour = DateTime.now().hour;
    if (isArabic) {
      if (hour < 6) return 'مساء الخير 🌙';
      if (hour < 12) return 'صباح الخير ☀️';
      if (hour < 18) return 'مساء الخير 🌤️';
      return 'مساء الخير 🌙';
    } else {
      if (hour < 12) return 'Good morning ☀️';
      if (hour < 18) return 'Good afternoon 🌤️';
      return 'Good evening 🌙';
    }
  }

  int _getTotalItems(Map<String, int> counts) {
    return (counts['photos'] ?? 0) +
        (counts['videos'] ?? 0) +
        (counts['notes'] ?? 0) +
        (counts['accounts'] ?? 0) +
        (counts['websites'] ?? 0) +
        (counts['documents'] ?? 0) +
        (counts['cards'] ?? 0) +
        (counts['identities'] ?? 0);
  }
}
