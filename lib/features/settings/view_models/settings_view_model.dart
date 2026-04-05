import 'package:flutter/foundation.dart';
import '../models/user_settings_model.dart';
import 'dart:async';

class SettingsViewModel extends ChangeNotifier {
  UserSettingsModel _settings = const UserSettingsModel();
  bool _isLoading = false;

  UserSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsViewModel() {
    // Initial load, in a real app this would fetch from a database or shared preferences
    _loadSettings();
  }

  void _loadSettings() {
    // For now, using default settings
    _settings = const UserSettingsModel();
    notifyListeners();
  }

  Future<void> toggleShowToInvestors(bool value) async {
    _settings = _settings.copyWith(showToInvestors: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleShowToAdvisors(bool value) async {
    _settings = _settings.copyWith(showToAdvisors: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> togglePushNotifications(bool value) async {
    _settings = _settings.copyWith(pushNotifications: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleEmailNotifications(bool value) async {
    _settings = _settings.copyWith(emailNotifications: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    // Mock save delay
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
    // Real implementation would call a repository here
  }

  Future<bool> changePassword(String current, String newPwd) async {
    _isLoading = true;
    notifyListeners();
    
    // Mock API call to change password
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
    return true; // Assume success for now
  }

  void logout() {
    // Mock logout logic: clear session, etc.
    print("User logged out");
  }
}
