import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../config/constants.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();

  bool _isAuthenticated = false;
  bool _isSecurityEnabled = false;
  String _securityMethod = AppConstants.methodNone;
  bool _isBiometricAvailable = false;
  int _autoLockMinutes = AppConstants.defaultAutoLockMinutes;
  DateTime? _lastActiveTime;

  bool get isAuthenticated => _isAuthenticated;
  bool get isSecurityEnabled => _isSecurityEnabled;
  String get securityMethod => _securityMethod;
  bool get isBiometricAvailable => _isBiometricAvailable;
  int get autoLockMinutes => _autoLockMinutes;

  /// Initialize security settings
  Future<void> initialize() async {
    _isSecurityEnabled = await _securityService.isSecurityEnabled();
    _securityMethod = await _securityService.getSecurityMethod();
    _isBiometricAvailable = await _securityService.isBiometricAvailable();
    _autoLockMinutes = await _securityService.getAutoLockMinutes();
    _lastActiveTime = DateTime.now();

    // If security is not enabled, auto-authenticate
    if (!_isSecurityEnabled) {
      _isAuthenticated = true;
    }

    notifyListeners();
  }

  /// Attempt biometric authentication
  Future<bool> authenticateWithBiometric() async {
    final result = await _securityService.authenticateWithBiometric();
    if (result) {
      _isAuthenticated = true;
      _lastActiveTime = DateTime.now();
      notifyListeners();
    }
    return result;
  }

  /// Verify PIN code
  Future<bool> verifyPin(String pin) async {
    final result = await _securityService.verifyPin(pin);
    if (result) {
      _isAuthenticated = true;
      _lastActiveTime = DateTime.now();
      notifyListeners();
    }
    return result;
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    return await _securityService.isPinSet();
  }

  /// Enable biometric security
  Future<void> enableBiometric() async {
    await _securityService.setSecurityMethod(AppConstants.methodBiometric);
    await _securityService.setSecurityEnabled(true);
    _securityMethod = AppConstants.methodBiometric;
    _isSecurityEnabled = true;
    notifyListeners();
  }

  /// Enable PIN security
  Future<void> enablePin(String pin) async {
    await _securityService.savePin(pin);
    await _securityService.setSecurityMethod(AppConstants.methodPin);
    await _securityService.setSecurityEnabled(true);
    _securityMethod = AppConstants.methodPin;
    _isSecurityEnabled = true;
    notifyListeners();
  }

  /// Enable both biometric and PIN
  Future<void> enableBoth(String pin) async {
    await _securityService.savePin(pin);
    await _securityService.setSecurityMethod(AppConstants.methodBoth);
    await _securityService.setSecurityEnabled(true);
    _securityMethod = AppConstants.methodBoth;
    _isSecurityEnabled = true;
    notifyListeners();
  }

  /// Disable all security
  Future<void> disableSecurity() async {
    await _securityService.setSecurityEnabled(false);
    await _securityService.setSecurityMethod(AppConstants.methodNone);
    await _securityService.deletePin();
    _isSecurityEnabled = false;
    _securityMethod = AppConstants.methodNone;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Update auto-lock minutes
  Future<void> setAutoLockMinutes(int minutes) async {
    await _securityService.setAutoLockMinutes(minutes);
    _autoLockMinutes = minutes;
    notifyListeners();
  }

  /// Update last active time (for idle detection)
  void updateLastActiveTime() {
    _lastActiveTime = DateTime.now();
  }

  /// Check if should lock due to inactivity
  bool shouldLock() {
    if (!_isSecurityEnabled || !_isAuthenticated) return false;
    if (_lastActiveTime == null) return true;

    final elapsed = DateTime.now().difference(_lastActiveTime!);
    return elapsed.inMinutes >= _autoLockMinutes;
  }

  /// Lock the app (require re-authentication)
  void lock() {
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Clear all security data (on sign out)
  Future<void> clearAll() async {
    await _securityService.clearAllSecurityData();
    _isAuthenticated = false;
    _isSecurityEnabled = false;
    _securityMethod = AppConstants.methodNone;
    notifyListeners();
  }
}
