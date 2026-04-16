import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  Future<AppSettings> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_settingsKey);
      if (data == null) return AppSettings.defaults;
      return AppSettings.fromJson(jsonDecode(data));
    } catch (e) {
      return AppSettings.defaults;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
