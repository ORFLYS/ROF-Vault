import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserProfile? _profile;
  String? _offlineUid;
  String? _offlineEmail;
  String? _offlineDisplayName;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null || _offlineUid != null;
  String? get uid => _user?.uid ?? _offlineUid;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Check whether user is verified via persistent storage, cache, or network
  Future<bool> getIsEmailVerified() async {
    final currentUid = uid;
    if (currentUid == null) return false;
    return await _authService.isUserEmailVerified(currentUid);
  }

  /// Mark email as verified locally
  Future<void> markEmailVerified() async {
    if (_user != null) {
      await _authService.markEmailAsVerified(_user!.uid);
      notifyListeners();
    }
  }

  /// Send email verification to the current user
  Future<bool> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      debugPrint('AuthProvider sendEmailVerification error: $e');
      return false;
    }
  }

  /// Reload user and check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      final verified = await _authService.reloadCurrentUser();
      _user = _authService.currentUser;
      if (verified && _user != null) {
        await _authService.markEmailAsVerified(_user!.uid);
      }
      notifyListeners();
      return verified;
    } catch (e) {
      debugPrint('AuthProvider checkEmailVerified error: $e');
      return false;
    }
  }

  AuthProvider() {
    try {
      _user = _authService.currentUser;
      _authService.authStateChanges.listen((user) {
        _user = user;
        if (user != null) {
          _loadProfile();
        } else {
          _profile = null;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthProvider initialization error: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      _profile = await _authService.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider _loadProfile error: $e');
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _loadProfile();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');
      _setError(_getArabicError(e.code, e.message));
      _setLoading(false);
      return false;
    } catch (e, st) {
      debugPrint('Sign up error: $e\n$st');
      _setError('حدث خطأ: ${e.toString().replaceAll('Exception:', '').trim()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.signInWithEmail(email: email, password: password);
      await _loadProfile();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException [${e.code}]: ${e.message}');
      _setError(_getArabicError(e.code, e.message));
      _setLoading(false);
      return false;
    } catch (e, st) {
      debugPrint('Sign in error: $e\n$st');
      _setError('حدث خطأ: ${e.toString().replaceAll('Exception:', '').trim()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        _setLoading(false);
        return false;
      }
      await _loadProfile();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth Error: ${e.code} - ${e.message}');
      _setError(_getArabicError(e.code));
      _setLoading(false);
      return false;
    } catch (e, stacktrace) {
      debugPrint('Auth Unknown Error: $e\n$stacktrace');
      final errStr = e.toString();
      if (errStr.contains('MissingPluginException') ||
          errStr.contains('google_sign_in')) {
        _setError(
            'تسجيل الدخول عبر Google متاح على تطبيق الهاتف، يرجى استخدام البريد الإلكتروني وكلمة المرور على الكمبيوتر.');
      } else {
        _setError(errStr);
      }
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getArabicError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      _setLoading(false);
      return false;
    }
  }

  /// Restores session across app restarts (both Firebase and secure offline cache)
  Future<bool> restoreSession() async {
    try {
      final user = await _authService.restoreSession();
      if (user != null) {
        _user = user;
        _offlineUid = user.uid;
        _offlineEmail = user.email;
        _offlineDisplayName = user.displayName;
        await _loadProfile();
        notifyListeners();
        return true;
      }

      // Check offline stored session
      final session = await _authService.getSavedSession();
      if (session['isLoggedIn'] == 'true' && session['uid'] != null) {
        _offlineUid = session['uid'];
        _offlineEmail = session['email'];
        _offlineDisplayName = session['displayName'];
        _profile ??= UserProfile(
          uid: _offlineUid!,
          displayName: _offlineDisplayName ??
              _offlineEmail?.split('@').first ??
              'مستخدم',
          email: _offlineEmail ?? '',
          securityMethod: 'none',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          autoLockMinutes: 5,
        );
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('AuthProvider restoreSession error: $e');
    }
    return false;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _authService.updateUserProfile(data);
    await _loadProfile();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _profile = null;
    _offlineUid = null;
    _offlineEmail = null;
    _offlineDisplayName = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _getArabicError(String code, [String? message]) {
    final msg = message?.toLowerCase() ?? '';
    if (code == 'invalid-credential' ||
        msg.contains('invalid_login_credentials') ||
        (code == 'unknown-error' && (msg.contains('incorrect') || msg.contains('password')))) {
      return 'بيانات الدخول غير صحيحة (تأكد من صحة البريد وكلمة المرور، أو اضغط على "نسيت كلمة المرور" لتعيين رمز جديد)';
    }

    switch (code) {
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل بالفعل، يمكنك تسجيل الدخول به';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بالبريد غير مفعّل في مشروع الخادم حالياً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة (يجب ألا تقل عن 6 خانات)';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'user-not-found':
        return 'لم يتم العثور على حساب بهذا البريد، يرجى إنشاء حساب أولاً';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة (تأكد من البريد وكلمة المرور)';
      case 'too-many-requests':
        return 'محاولات كثيرة خاطئة، يرجى الانتظار قليلاً والمحاولة لاحقاً';
      case 'network-request-failed':
        return 'تعذر الاتصال بالشبكة، يرجى التحقق من اتصال الإنترنت';
      case 'channel-error':
        return 'يرجى إدخال جميع الحقول المطلوبة';
      case 'unknown-error':
        return 'تعذر التحقق من الحساب (تأكد من كلمة المرور، أو استخدم "نسيت كلمة المرور" لتعيين رمز)';
      default:
        return 'حدث خطأ في المصادقة ($code)';
    }
  }
}
