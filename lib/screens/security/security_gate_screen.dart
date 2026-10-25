import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/security_provider.dart';
import '../../providers/vault_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class SecurityGateScreen extends StatefulWidget {
  const SecurityGateScreen({super.key});

  @override
  State<SecurityGateScreen> createState() => _SecurityGateScreenState();
}

class _SecurityGateScreenState extends State<SecurityGateScreen>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  String _pinInput = '';
  bool _obscurePin = true;
  bool _isAuthenticating = false;
  int _failedAttempts = 0;
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _initSecurity();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _initSecurity() async {
    try {
      final securityProvider =
          Provider.of<SecurityProvider>(context, listen: false);
      await securityProvider.initialize();

      if (!securityProvider.isSecurityEnabled) {
        _proceedToHome();
        return;
      }

      if (securityProvider.securityMethod == AppConstants.methodBiometric ||
          securityProvider.securityMethod == AppConstants.methodBoth) {
        await _tryBiometric();
      }
    } catch (e) {
      debugPrint('SecurityGateScreen _initSecurity error: $e');
      _proceedToHome();
    }
  }

  Future<void> _tryBiometric() async {
    try {
      if (mounted) setState(() => _isAuthenticating = true);
      final securityProvider =
          Provider.of<SecurityProvider>(context, listen: false);
      final success = await securityProvider.authenticateWithBiometric();

      if (success && mounted) {
        _proceedToHome();
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticating = false;
            if (securityProvider.securityMethod == AppConstants.methodBiometric) {
              _errorMessage = context.tr.biometricFailed;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('SecurityGateScreen _tryBiometric error: $e');
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  void _onPinDigit(String digit) {
    if (_pinInput.length >= AppConstants.maxPinLength) return;

    setState(() {
      _pinInput += digit;
      _errorMessage = null;
    });
  }

  void _onPinDelete() {
    if (_pinInput.isEmpty) return;
    setState(() {
      _pinInput = _pinInput.substring(0, _pinInput.length - 1);
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    final securityProvider =
        Provider.of<SecurityProvider>(context, listen: false);
    final success = await securityProvider.verifyPin(_pinInput);

    if (success && mounted) {
      _proceedToHome();
    } else {
      _failedAttempts++;
      _shakeController.forward(from: 0);
      setState(() {
        _pinInput = '';
        if (_failedAttempts >= AppConstants.maxPinAttempts) {
          _errorMessage = context.tr.maxAttemptsReached;
          _forceSignOut();
        } else {
          _errorMessage =
              '${context.tr.incorrectPin}. ${context.tr.remainingAttempts}: ${AppConstants.maxPinAttempts - _failedAttempts}';
        }
      });
    }
  }

  void _proceedToHome() {
    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    final vaultProvider =
        Provider.of<VaultProvider>(context, listen: false);

    if (authProvider.uid != null) {
      vaultProvider.initialize(authProvider.uid!);
    }

    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _forceSignOut() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final authProvider =
        Provider.of<app_auth.AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityProvider = Provider.of<SecurityProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showPinPad = securityProvider.securityMethod == AppConstants.methodPin ||
        securityProvider.securityMethod == AppConstants.methodBoth;

    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent && showPinPad) {
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.digit0 ||
                key == LogicalKeyboardKey.numpad0) {
              _onPinDigit('0');
            } else if (key == LogicalKeyboardKey.digit1 ||
                key == LogicalKeyboardKey.numpad1) {
              _onPinDigit('1');
            } else if (key == LogicalKeyboardKey.digit2 ||
                key == LogicalKeyboardKey.numpad2) {
              _onPinDigit('2');
            } else if (key == LogicalKeyboardKey.digit3 ||
                key == LogicalKeyboardKey.numpad3) {
              _onPinDigit('3');
            } else if (key == LogicalKeyboardKey.digit4 ||
                key == LogicalKeyboardKey.numpad4) {
              _onPinDigit('4');
            } else if (key == LogicalKeyboardKey.digit5 ||
                key == LogicalKeyboardKey.numpad5) {
              _onPinDigit('5');
            } else if (key == LogicalKeyboardKey.digit6 ||
                key == LogicalKeyboardKey.numpad6) {
              _onPinDigit('6');
            } else if (key == LogicalKeyboardKey.digit7 ||
                key == LogicalKeyboardKey.numpad7) {
              _onPinDigit('7');
            } else if (key == LogicalKeyboardKey.digit8 ||
                key == LogicalKeyboardKey.numpad8) {
              _onPinDigit('8');
            } else if (key == LogicalKeyboardKey.digit9 ||
                key == LogicalKeyboardKey.numpad9) {
              _onPinDigit('9');
            } else if (key == LogicalKeyboardKey.backspace) {
              _onPinDelete();
            } else if (key == LogicalKeyboardKey.enter ||
                       key == LogicalKeyboardKey.numpadEnter) {
              if (_pinInput.length >= AppConstants.minPinLength) {
                _verifyPin();
              }
            }
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _focusNode.requestFocus(),
            child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [AppColors.primaryDark, AppColors.primary],
                stops: const [0.0, 0.5],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 35,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Icon
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr.securityGateTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          showPinPad
                              ? context.tr.enterPinPrompt
                              : context.tr.biometricPrompt,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // PIN input field (Modern Desktop style - flexible length)
                        if (showPinPad) ...[
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              final shake =
                                  _shakeAnimation.value * 10 * ((_shakeController.value * 8).toInt().isEven ? 1 : -1);
                              return Transform.translate(
                                offset: Offset(shake, 0),
                                child: child,
                              );
                            },
                            child: GestureDetector(
                              onTap: () => _focusNode.requestFocus(),
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(maxWidth: 320),
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _errorMessage != null
                                        ? AppColors.error
                                        : (_pinInput.isNotEmpty
                                            ? AppColors.primary
                                            : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1))),
                                    width: _pinInput.isNotEmpty ? 1.8 : 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                      color: _pinInput.isNotEmpty
                                          ? AppColors.primary
                                          : (isDark ? Colors.white38 : AppColors.textHint),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Center(
                                        child: _pinInput.isEmpty
                                            ? Text(
                                                context.isArabic ? 'أدخل رمز PIN...' : 'Enter PIN...',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 14,
                                                  color: isDark ? Colors.white38 : Colors.black38,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Text(
                                                  _obscurePin
                                                      ? '● ' * _pinInput.length
                                                      : _pinInput,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: _obscurePin ? 18 : 20,
                                                    letterSpacing: _obscurePin ? 4 : 4,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    if (_pinInput.isNotEmpty) ...[
                                      IconButton(
                                        icon: Icon(
                                          _obscurePin
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 20,
                                          color: isDark ? Colors.white60 : Colors.black54,
                                        ),
                                        tooltip: _obscurePin
                                            ? (context.isArabic ? 'إظهار الرمز' : 'Show PIN')
                                            : (context.isArabic ? 'إخفاء الرمز' : 'Hide PIN'),
                                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                                        splashRadius: 18,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.backspace_outlined, size: 18),
                                        color: isDark ? Colors.white60 : Colors.black54,
                                        tooltip: context.isArabic ? 'حذف' : 'Backspace',
                                        onPressed: _onPinDelete,
                                        splashRadius: 18,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ] else ...[
                                      const SizedBox(width: 20),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Error message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // PIN Keypad (Fixed LTR order for desktop)
                        if (showPinPad) _buildPinKeypad(isDark),

                        // Keyboard hint for desktop users
                        if (showPinPad) ...[
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_alt_outlined,
                                size: 16,
                                color: isDark ? Colors.white38 : AppColors.textHint,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.isArabic
                                    ? 'يمكنك استخدام لوحة المفاتيح والضغط على Enter'
                                    : 'You can use physical keyboard & press Enter',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Biometric button (when available as fallback)
                        if (securityProvider.securityMethod == AppConstants.methodBoth &&
                            securityProvider.isBiometricAvailable) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _isAuthenticating ? null : _tryBiometric,
                            icon: Icon(Icons.fingerprint, color: isDark ? Colors.white : AppColors.primary),
                            label: Text(
                              context.tr.useBiometricBtn,
                              style: GoogleFonts.cairo(color: isDark ? Colors.white : AppColors.primary),
                            ),
                          ),
                        ],

                        // Retry biometric button
                        if (securityProvider.securityMethod ==
                                AppConstants.methodBiometric &&
                            !_isAuthenticating) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _tryBiometric,
                            icon: const Icon(Icons.fingerprint),
                            label: Text(
                              context.tr.retry,
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinKeypad(bool isDark) {
    final canSubmit = _pinInput.length >= AppConstants.minPinLength;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
                ['del', '0', 'ok'],
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.map((key) {
                      if (key == 'ok') {
                        return SizedBox(
                          width: 82,
                          height: 52,
                          child: Material(
                            color: canSubmit
                                ? AppColors.success
                                : (isDark
                                    ? const Color(0xFF334155).withValues(alpha: 0.3)
                                    : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: canSubmit ? _verifyPin : null,
                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: canSubmit
                                      ? Colors.white
                                      : (isDark ? Colors.white24 : Colors.black26),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      if (key == 'del') {
                        return SizedBox(
                          width: 82,
                          height: 52,
                          child: Material(
                            color: isDark
                                ? const Color(0xFF334155).withValues(alpha: 0.25)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              onTap: _onPinDelete,
                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: Icon(
                                  Icons.backspace_outlined,
                                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        width: 82,
                        height: 52,
                        child: Material(
                          color: isDark
                              ? const Color(0xFF334155).withValues(alpha: 0.45)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => _onPinDigit(key),
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: Text(
                                key,
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
