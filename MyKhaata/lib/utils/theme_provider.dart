import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class AppTheme {
  final String name;
  final Color yellowT;
  final Color blackBG;
  final Color scaffoldColor;

  AppTheme({
    required this.name,
    required this.yellowT,
    required this.blackBG,
    required this.scaffoldColor,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _currencyKey = 'currency_symbol';
  static const String _passcodeKey = 'passcode';
  static const String _passcodeEnabledKey = 'passcode_enabled';
  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _reminderTimeKey = 'reminder_time';

  int _selectedThemeIndex = 0;
  String _currencySymbol = 'Rs';
  String _passcode = '';
  bool _passcodeEnabled = false;
  bool _dailyReminderEnabled = false;
  TimeOfDay _reminderTime = TimeOfDay(hour: 20, minute: 0);

  final NotificationService _notificationService = NotificationService();

  static final List<AppTheme> themes = [
    AppTheme(
      name: 'Classic Olive',
      yellowT: Color(0xFFEAE1A7),
      blackBG: Color(0xFF5A5A5A),
      scaffoldColor: Color(0xFF34343C),
    ),
    AppTheme(
      name: 'Ocean Blue',
      yellowT: Color(0xFFE3F2FD),
      blackBG: Color(0xFF1565C0),
      scaffoldColor: Color(0xFF0D47A1),
    ),
    AppTheme(
      name: 'Forest Green',
      yellowT: Color(0xFFE8F5E9),
      blackBG: Color(0xFF2E7D32),
      scaffoldColor: Color(0xFF1B5E20),
    ),
    AppTheme(
      name: 'Royal Purple',
      yellowT: Color(0xFFF3E5F5),
      blackBG: Color(0xFF6A1B9A),
      scaffoldColor: Color(0xFF4A148C),
    ),
    AppTheme(
      name: 'Sunset Orange',
      yellowT: Color(0xFFFFF3E0),
      blackBG: Color(0xFFE65100),
      scaffoldColor: Color(0xFFBF360C),
    ),
    AppTheme(
      name: 'Cherry Blossom',
      yellowT: Color(0xFFFCE4EC),
      blackBG: Color(0xFFC2185B),
      scaffoldColor: Color(0xFF880E4F),
    ),
    AppTheme(
      name: 'Midnight Blue',
      yellowT: Color(0xFFE1F5FE),
      blackBG: Color(0xFF01579B),
      scaffoldColor: Color(0xFF002F6C),
    ),
    AppTheme(
      name: 'Emerald',
      yellowT: Color(0xFFE0F2F1),
      blackBG: Color(0xFF00695C),
      scaffoldColor: Color(0xFF004D40),
    ),
  ];

  int get selectedThemeIndex => _selectedThemeIndex;
  AppTheme get currentTheme => themes[_selectedThemeIndex];
  String get currencySymbol => _currencySymbol;
  String get passcode => _passcode;
  bool get passcodeEnabled => _passcodeEnabled;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  TimeOfDay get reminderTime => _reminderTime;

  ThemeProvider() {
    _loadPreferences();
    _notificationService.initialize();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedThemeIndex = prefs.getInt(_themeKey) ?? 0;
    _currencySymbol = prefs.getString(_currencyKey) ?? 'Rs';
    _passcode = prefs.getString(_passcodeKey) ?? '';
    _passcodeEnabled = prefs.getBool(_passcodeEnabledKey) ?? false;
    _dailyReminderEnabled = prefs.getBool(_dailyReminderKey) ?? false;

    final reminderHour = prefs.getInt('${_reminderTimeKey}_hour') ?? 20;
    final reminderMinute = prefs.getInt('${_reminderTimeKey}_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);

    // Schedule notification if enabled
    if (_dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    }

    notifyListeners();
  }

  Future<void> setTheme(int index) async {
    if (index >= 0 && index < themes.length) {
      _selectedThemeIndex = index;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, index);
      notifyListeners();
    }
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
    notifyListeners();
  }

  Future<void> setPasscode(String code) async {
    _passcode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passcodeKey, code);
    notifyListeners();
  }

  Future<void> setPasscodeEnabled(bool enabled) async {
    _passcodeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_passcodeEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setDailyReminderEnabled(bool enabled) async {
    _dailyReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, enabled);

    if (enabled) {
      await _notificationService.scheduleDailyReminder(_reminderTime);
    } else {
      await _notificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_reminderTimeKey}_hour', time.hour);
    await prefs.setInt('${_reminderTimeKey}_minute', time.minute);

    // Reschedule notification with new time if enabled
    if (_dailyReminderEnabled) {
      await _notificationService.scheduleDailyReminder(time);
    }

    notifyListeners();
  }

  Future<void> testNotification() async {
    await _notificationService.showTestNotification();
  }

  bool verifyPasscode(String code) {
    return _passcode == code;
  }
}