import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _prefKey = 'selected_language';

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  /// Sets the new locale and saves it to shared preferences.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  /// Clears the saved locale and reverts to system default.
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Loads the saved locale from shared preferences on startup.
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_prefKey);
    if (langCode != null) {
      _locale = Locale(langCode);
      notifyListeners();
    }
  }
}
