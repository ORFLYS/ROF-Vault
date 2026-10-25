class AppConstants {
  // App Info
  static const String appName = 'خزنة ROF';
  static const String appNameEn = 'ROF Vault';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String notesSubcollection = 'notes';
  static const String filesSubcollection = 'files';
  static const String accountsSubcollection = 'accounts';
  static const String websitesSubcollection = 'safe_websites';
  static const String cardsSubcollection = 'cards';
  static const String idsSubcollection = 'identities';
  static const String trashSubcollection = 'trash';

  // Storage Paths
  static const String storagePath = 'users';

  // Security
  static const String securityMethodKey = 'security_method';
  static const String pinCodeKey = 'pin_code';
  static const String securityEnabledKey = 'security_enabled';
  static const String autoLockMinutesKey = 'auto_lock_minutes';
  static const int defaultAutoLockMinutes = 5;
  static const int maxPinAttempts = 5;
  static const int pinLength = 4;
  static const int minPinLength = 4;
  static const int maxPinLength = 16;

  // Pagination
  static const int pageSize = 20;

  // Trash
  static const int trashRetentionDays = 30;

  // File Types
  static const List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  static const List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'];

  // Security Methods
  static const String methodBiometric = 'biometric';
  static const String methodPin = 'pin';
  static const String methodBoth = 'both';
  static const String methodNone = 'none';
}
