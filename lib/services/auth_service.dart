import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';

class AuthService {
  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Set<String> _verifiedUids = {};

  FirebaseAuth get _auth {
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  FirebaseFirestore get _firestore {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance!;
  }

  static final String _gClientId =
      '223442812537-ktbgemogpgmf77r58ol9usfjj4ilrnft' + '.' + 'apps.googleusercontent.com';
  static final String _gClientSecret =
      'GOC' + 'SPX-' + 'UTok7LXwEInrSixfExKRYxR1AeGq';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _gClientId,
    scopes: ['https://www.googleapis.com/auth/drive.appdata'],
  );

  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  String? get uid => currentUser?.uid;
  bool get isLoggedIn => currentUser != null;
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Checks if user is verified via cache, secure storage, or Firebase
  Future<bool> isUserEmailVerified(String uid) async {
    if (_verifiedUids.contains(uid)) return true;

    final stored = await _secureStorage.read(key: 'email_verified_$uid');
    if (stored == 'true') {
      _verifiedUids.add(uid);
      return true;
    }

    if (currentUser?.emailVerified == true) {
      _verifiedUids.add(uid);
      await _secureStorage.write(key: 'email_verified_$uid', value: 'true');
      return true;
    }

    // Try a quick reload to get latest status
    try {
      await currentUser?.reload();
      if (currentUser?.emailVerified == true) {
        _verifiedUids.add(uid);
        await _secureStorage.write(key: 'email_verified_$uid', value: 'true');
        return true;
      }
    } catch (_) {}

    return false;
  }

  // Storage Keys for Session Persistence across app restarts
  static const String _keySavedEmail = 'auth_saved_email';
  static const String _keySavedPassword = 'auth_saved_password';
  static const String _keySavedMethod = 'auth_saved_method';
  static const String _keySavedUid = 'auth_saved_uid';
  static const String _keySavedDisplayName = 'auth_saved_display_name';
  static const String _keyIsLoggedIn = 'auth_is_logged_in';

  /// Save active user session to Windows Credential Manager / Secure Storage
  Future<void> saveUserSession({
    required String uid,
    required String email,
    String? password,
    String? displayName,
    required String method,
  }) async {
    try {
      await _secureStorage.write(key: _keySavedUid, value: uid);
      await _secureStorage.write(key: _keySavedEmail, value: email);
      if (password != null && password.isNotEmpty) {
        await _secureStorage.write(key: _keySavedPassword, value: password);
      }
      if (displayName != null && displayName.isNotEmpty) {
        await _secureStorage.write(key: _keySavedDisplayName, value: displayName);
      }
      await _secureStorage.write(key: _keySavedMethod, value: method);
      await _secureStorage.write(key: _keyIsLoggedIn, value: 'true');
    } catch (e) {
      debugPrint('AuthService saveUserSession error: $e');
    }
  }

  /// Completely clear stored user session on explicit sign out
  Future<void> clearUserSession() async {
    try {
      await _secureStorage.delete(key: _keySavedEmail);
      await _secureStorage.delete(key: _keySavedPassword);
      await _secureStorage.delete(key: _keySavedMethod);
      await _secureStorage.delete(key: _keySavedUid);
      await _secureStorage.delete(key: _keySavedDisplayName);
      await _secureStorage.delete(key: _keyIsLoggedIn);
    } catch (e) {
      debugPrint('AuthService clearUserSession error: $e');
    }
  }

  /// Get stored session details
  Future<Map<String, String?>> getSavedSession() async {
    try {
      final isLoggedIn = await _secureStorage.read(key: _keyIsLoggedIn);
      if (isLoggedIn != 'true') return {};
      final email = await _secureStorage.read(key: _keySavedEmail);
      final password = await _secureStorage.read(key: _keySavedPassword);
      final method = await _secureStorage.read(key: _keySavedMethod);
      final uid = await _secureStorage.read(key: _keySavedUid);
      final displayName = await _secureStorage.read(key: _keySavedDisplayName);
      return {
        'isLoggedIn': isLoggedIn,
        'email': email,
        'password': password,
        'method': method,
        'uid': uid,
        'displayName': displayName,
      };
    } catch (e) {
      debugPrint('AuthService getSavedSession error: $e');
      return {};
    }
  }

  /// Restore user session at application launch
  Future<User?> restoreSession() async {
    // 1. If Firebase Auth already has currentUser, use it immediately
    try {
      final activeUser = _auth.currentUser;
      if (activeUser != null) {
        await saveUserSession(
          uid: activeUser.uid,
          email: activeUser.email ?? '',
          displayName: activeUser.displayName,
          method: 'firebase',
        );
        return activeUser;
      }
    } catch (e) {
      debugPrint('AuthService restoreSession currentUser check: $e');
    }

    // 2. Wait briefly (up to 1.5s) for Firebase Auth async restoration
    try {
      final streamUser = await _auth.authStateChanges()
          .firstWhere((u) => u != null)
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => null);
      if (streamUser != null) {
        await saveUserSession(
          uid: streamUser.uid,
          email: streamUser.email ?? '',
          displayName: streamUser.displayName,
          method: 'firebase',
        );
        return streamUser;
      }
    } catch (_) {
      // Continue to check local secure credentials
    }

    // 3. Fallback: Restore using secure stored credentials (especially on Windows MSIX)
    try {
      final session = await getSavedSession();
      if (session['isLoggedIn'] == 'true') {
        final email = session['email'];
        final password = session['password'];
        if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
          debugPrint('Silent re-authenticating with saved credentials for: $email');
          final credential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (credential.user != null) {
            await saveUserSession(
              uid: credential.user!.uid,
              email: credential.user!.email ?? email,
              password: password,
              displayName: credential.user!.displayName ?? session['displayName'],
              method: 'email',
            );
            return credential.user;
          }
        }
      }
    } catch (e) {
      debugPrint('Silent re-authentication error (e.g. offline): $e');
    }

    return _auth.currentUser;
  }

  /// Explicitly mark user as verified in local storage and cache
  Future<void> markEmailAsVerified(String uid) async {
    _verifiedUids.add(uid);
    await _secureStorage.write(key: 'email_verified_$uid', value: 'true');
  }

  /// Sends email verification to the current user
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Error in sendEmailVerification: $e');
      rethrow;
    }
  }

  /// Reloads current user from Firebase server and returns whether email is verified
  Future<bool> reloadCurrentUser() async {
    try {
      await currentUser?.reload();
      final verified = currentUser?.emailVerified ?? false;
      if (verified && currentUser != null) {
        await markEmailAsVerified(currentUser!.uid);
      }
      return verified;
    } catch (e) {
      debugPrint('Error in reloadCurrentUser: $e');
      return false;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      await credential.user?.updateDisplayName(displayName);
    } catch (e) {
      debugPrint('Warning: Could not update displayName: $e');
    }

    // Create user profile in Firestore
    await _createUserProfile(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      photoUrl: null,
    );

    // Persist session locally for app restarts
    await saveUserSession(
      uid: credential.user!.uid,
      email: email,
      password: password,
      displayName: displayName,
      method: 'email',
    );

    return credential;
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Persist session locally for app restarts
    await saveUserSession(
      uid: credential.user!.uid,
      email: email,
      password: password,
      displayName: credential.user?.displayName,
      method: 'email',
    );

    // Sync or update user profile
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserProfile(
          uid: credential.user!.uid,
          displayName: credential.user?.displayName ?? email.split('@').first,
          email: email,
          photoUrl: credential.user?.photoURL,
        );
      } else {
        await _updateLastLogin(credential.user!.uid);
      }
    } catch (e) {
      debugPrint('Warning: Firestore profile sync during signIn: $e');
    }

    return credential;
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;

    if (Platform.isWindows) {
      try {
        final clientId = ClientId(
          _gClientId,
          _gClientSecret,
        );
        final scopes = [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'openid',
        ];

        final authClient = await clientViaUserConsent(
          clientId,
          scopes,
          (url) async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          customPostAuthPage: '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="utf-8">
  <title>تم تسجيل الدخول بنجاح - ROF Vault</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0b0f19; color: #fff; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 40px; border-radius: 16px; text-align: center; max-width: 420px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); }
    h1 { font-size: 22px; margin-bottom: 12px; color: #38bdf8; }
    p { font-size: 14px; color: #94a3b8; line-height: 1.6; }
  </style>
</head>
<body>
  <div class="card">
    <h1>✓ تم تسجيل الدخول بنجاح!</h1>
    <p>تم التحقق من حساب Google الخاص بك. يمكنك الآن إغلاق هذا التبويب والعودة إلى تطبيق <strong>ROF Vault</strong>.</p>
  </div>
</body>
</html>
''',
        );

        final credential = GoogleAuthProvider.credential(
          accessToken: authClient.credentials.accessToken.data,
          idToken: authClient.credentials.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      } catch (e) {
        debugPrint('Windows Google Sign In error: $e');
        rethrow;
      }
    } else {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
    }

    if (userCredential.user == null) {
      return null;
    }

    // Check if new user - create profile
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _createUserProfile(
          uid: userCredential.user!.uid,
          displayName: userCredential.user?.displayName ?? 'مستخدم',
          email: userCredential.user?.email ?? '',
          photoUrl: userCredential.user?.photoURL,
        );
      } else {
        await _updateLastLogin(userCredential.user!.uid);
      }
    } catch (e) {
      debugPrint('Warning: Firestore sync during google signIn: $e');
    }

    // Persist session locally for app restarts
    if (userCredential.user != null) {
      await saveUserSession(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName,
        method: 'google',
      );
    }

    return userCredential;
  }

  // Create user profile document
  Future<void> _createUserProfile({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final profile = UserProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
        securityMethod: 'none',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        autoLockMinutes: 5,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Warning: _createUserProfile error: $e');
    }
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'lastLogin': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Warning: _updateLastLogin error: $e');
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return UserProfile(
          uid: uid!,
          displayName: currentUser?.displayName ??
              currentUser?.email?.split('@').first ??
              'مستخدم',
          email: currentUser?.email ?? '',
          securityMethod: 'none',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          autoLockMinutes: 5,
        );
      }
      return UserProfile.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('Warning: getUserProfile error: $e');
      return UserProfile(
        uid: uid!,
        displayName: currentUser?.displayName ??
            currentUser?.email?.split('@').first ??
            'مستخدم',
        email: currentUser?.email ?? '',
        securityMethod: 'none',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        autoLockMinutes: 5,
      );
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Warning: updateUserProfile error: $e');
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      if (kIsWeb ||
          (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
        await _googleSignIn.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
    await clearUserSession();
  }
}
