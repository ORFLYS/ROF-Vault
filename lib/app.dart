import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/security_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'config/translations.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/security/security_gate_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/vault/photos_screen.dart';
import 'screens/vault/videos_screen.dart';
import 'screens/vault/notes_screen.dart';
import 'screens/vault/accounts_screen.dart';
import 'screens/vault/safe_websites_screen.dart';
import 'screens/vault/documents_screen.dart';
import 'screens/vault/gallery_screen.dart';
import 'screens/vault/payment_cards_screen.dart';
import 'screens/vault/identities_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/trash/trash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/privacy_policy_dialog.dart';

class KazenaApp extends StatelessWidget {
  const KazenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'ROF Vault',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: localeProvider.locale,
      builder: (context, child) {
        return Directionality(
          textDirection: localeProvider.textDirection,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-email': (context) => const EmailVerificationScreen(),
        '/security-gate': (context) => const SecurityGateScreen(),
        '/home': (context) => const MainShell(),
        '/gallery': (context) => const GalleryScreen(),
        '/photos': (context) => const PhotosScreen(),
        '/videos': (context) => const VideosScreen(),
        '/notes': (context) => const NotesScreen(),
        '/accounts': (context) => const AccountsScreen(),
        '/cards': (context) => const PaymentCardsScreen(),
        '/identities': (context) => const IdentitiesScreen(),
        '/safe-websites': (context) => const SafeWebsitesScreen(),
        '/documents': (context) => const DocumentsScreen(),
      },
    );
  }
}

/// Main app shell with desktop sidebar or bottom navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime? _lastPaused;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    TrashScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final securityProvider =
        Provider.of<SecurityProvider>(context, listen: false);

    if (state == AppLifecycleState.paused) {
      _lastPaused = DateTime.now();
      securityProvider.updateLastActiveTime();
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPaused != null && securityProvider.isSecurityEnabled) {
        final elapsed = DateTime.now().difference(_lastPaused!);
        if (elapsed.inMinutes >= securityProvider.autoLockMinutes) {
          securityProvider.lock();
          Navigator.of(context).pushReplacementNamed('/security-gate');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 750;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildDesktopSidebar(isDark),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, context.tr.navHome),
                _buildNavItem(1, Icons.search_rounded, Icons.search_rounded, context.tr.navSearch),
                _buildNavItem(2, Icons.delete_outline_rounded, Icons.delete_outline_rounded, context.tr.navTrash),
                _buildNavItem(3, Icons.settings_rounded, Icons.settings_outlined, context.tr.navSettings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(bool isDark) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final displayName = authProvider.profile?.displayName ??
        authProvider.user?.displayName ??
        context.tr.vaultUser;
    final email = authProvider.profile?.email ??
        authProvider.user?.email ??
        '';

    return Container(
      width: 260,
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo and title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ROF Vault',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        context.tr.encryptedVault,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.shield_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Nav Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _buildSidebarItem(0, Icons.home_rounded, Icons.home_outlined, context.tr.navHome, isDark),
                const SizedBox(height: 6),
                _buildSidebarItem(1, Icons.search_rounded, Icons.search_outlined, context.tr.navSearch, isDark),
                const SizedBox(height: 6),
                _buildSidebarItem(2, Icons.delete_rounded, Icons.delete_outline_rounded, context.tr.navTrash, isDark),
                const SizedBox(height: 6),
                _buildSidebarItem(3, Icons.settings_rounded, Icons.settings_outlined, context.tr.navSettings, isDark),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Dedicated Language Switcher Button in the menu
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => localeProvider.toggleLocale(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.tr.language,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              localeProvider.isArabic ? 'English' : 'العربية',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Dedicated Privacy Policy & Terms Button (in the exact position requested)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => PrivacyPolicyDialog.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 20,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.tr.privacyAndTermsNav,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            size: 18,
                            color: isDark ? Colors.white38 : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Account & Quick Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  // User Profile info
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            if (email.isNotEmpty)
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  // Action Buttons: Lock Vault, Language Toggle & Theme Toggle
                  Row(
                    children: [
                      // Lock button
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            securityProvider.lock();
                            Navigator.of(context).pushReplacementNamed('/security-gate');
                          },
                          icon: const Icon(Icons.lock_outline_rounded, size: 16),
                          label: Text(
                            context.tr.lockVault,
                            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),

                      // Quick Language Toggle
                      IconButton(
                        onPressed: () => localeProvider.toggleLocale(),
                        tooltip: context.tr.switchToOtherLanguage,
                        icon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? Colors.white30 : const Color(0xFF94A3B8),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            localeProvider.isArabic ? 'EN' : 'عربي',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      // Theme toggle
                      IconButton(
                        onPressed: () => themeProvider.toggleTheme(),
                        tooltip: themeProvider.isDarkMode ? context.tr.themeLight : context.tr.themeDark,
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 18,
                          color: isDark ? Colors.amber : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData activeIcon, IconData inactiveIcon, String label, bool isDark) {
    final isActive = _currentIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.12))
                : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : inactiveIcon,
                size: 20,
                color: isActive
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark ? Colors.white60 : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? (isDark ? Colors.white : AppColors.primary)
                        : (isDark ? Colors.white70 : const Color(0xFF334155)),
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 5,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive
              ? (isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1))
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 24,
              color: isActive
                  ? (isDark ? AppColors.primaryLight : AppColors.primary)
                  : (isDark ? Colors.white38 : AppColors.textHint),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : (isDark ? Colors.white38 : AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
