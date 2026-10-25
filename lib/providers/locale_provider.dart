import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _storageKey = 'app_language_code';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Default language is English as requested
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final savedCode = await _storage.read(key: _storageKey);
      if (savedCode != null && (savedCode == 'ar' || savedCode == 'en')) {
        _locale = Locale(savedCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    notifyListeners();
    try {
      await _storage.write(key: _storageKey, value: newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  Future<void> toggleLocale() async {
    final nextCode = isArabic ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}
