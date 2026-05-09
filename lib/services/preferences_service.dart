import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _themeKey = 'isDarkMode';
  static const _lastTabKey = 'lastTab';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<int> getLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTabKey) ?? 0;
  }

  Future<void> setLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }
}