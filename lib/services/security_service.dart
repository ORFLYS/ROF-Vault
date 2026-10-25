import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class SecurityService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // === Biometric Methods ===

  /// Check if device supports biometrics
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('SecurityService isBiometricAvailable error: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('SecurityService getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'قم بالتحقق من هويتك للوصول إلى خزينتك',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('SecurityService authenticateWithBiometric error: $e');
      return false;
    }
  }

  // === PIN Methods ===

  /// Save PIN code securely
  Future<void> savePin(String pin) async {
    try {
      await _secureStorage.write(key: AppConstants.pinCodeKey, value: pin);
    } catch (e) {
      debugPrint('SecurityService savePin error: $e');
    }
  }

  /// Verify PIN code
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: AppConstants.pinCodeKey);
      return storedPin == pin;
    } catch (e) {
      debugPrint('SecurityService verifyPin error: $e');
      return false;
    }
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    try {
      final pin = await _secureStorage.read(key: AppConstants.pinCodeKey);
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      debugPrint('SecurityService isPinSet error: $e');
      return false;
    }
  }

  /// Delete PIN
  Future<void> deletePin() async {
    try {
      await _secureStorage.delete(key: AppConstants.pinCodeKey);
    } catch (e) {
      debugPrint('SecurityService deletePin error: $e');
    }
  }

  // === Security Method ===

  /// Save security method preference
  Future<void> setSecurityMethod(String method) async {
    try {
      await _secureStorage.write(
          key: AppConstants.securityMethodKey, value: method);
    } catch (e) {
      debugPrint('SecurityService setSecurityMethod error: $e');
    }
  }

  /// Get current security method
  Future<String> getSecurityMethod() async {
    try {
      final method =
          await _secureStorage.read(key: AppConstants.securityMethodKey);
      return method ?? AppConstants.methodNone;
    } catch (e) {
      debugPrint('SecurityService getSecurityMethod error: $e');
      return AppConstants.methodNone;
    }
  }

  /// Set security enabled state
  Future<void> setSecurityEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
          key: AppConstants.securityEnabledKey, value: enabled.toString());
    } catch (e) {
      debugPrint('SecurityService setSecurityEnabled error: $e');
    }
  }

  /// Check if security is enabled
  Future<bool> isSecurityEnabled() async {
    try {
      final enabled =
          await _secureStorage.read(key: AppConstants.securityEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('SecurityService isSecurityEnabled error: $e');
      return false;
    }
  }

  /// Perform full security check based on saved method
  Future<bool> performSecurityCheck() async {
    try {
      final isEnabled = await isSecurityEnabled();
      if (!isEnabled) return true; // No security configured, allow access

      final method = await getSecurityMethod();

      switch (method) {
        case AppConstants.methodBiometric:
          return await authenticateWithBiometric();

        case AppConstants.methodPin:
          // PIN verification happens via UI, this just checks if it's set
          return false; // Caller should show PIN screen

        case AppConstants.methodBoth:
          // Try biometric first
          final biometricResult = await authenticateWithBiometric();
          if (biometricResult) return true;
          return false; // Fall back to PIN screen

        default:
          return true;
      }
    } catch (e) {
      debugPrint('SecurityService performSecurityCheck error: $e');
      return true;
    }
  }

  /// Save auto-lock duration
  Future<void> setAutoLockMinutes(int minutes) async {
    try {
      await _secureStorage.write(
          key: AppConstants.autoLockMinutesKey, value: minutes.toString());
    } catch (e) {
      debugPrint('SecurityService setAutoLockMinutes error: $e');
    }
  }

  /// Get auto-lock duration
  Future<int> getAutoLockMinutes() async {
    try {
      final value =
          await _secureStorage.read(key: AppConstants.autoLockMinutesKey);
      return int.tryParse(value ?? '') ?? AppConstants.defaultAutoLockMinutes;
    } catch (e) {
      debugPrint('SecurityService getAutoLockMinutes error: $e');
      return AppConstants.defaultAutoLockMinutes;
    }
  }

  /// Clear all security data (for sign out)
  Future<void> clearAllSecurityData() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('SecurityService clearAllSecurityData error: $e');
    }
  }
}
