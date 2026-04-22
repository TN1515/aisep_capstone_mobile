import 'package:aisep_capstone_mobile/features/auth/models/auth_request_models.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';
import 'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:flutter/foundation.dart';
import '../models/user_settings_model.dart';
import 'dart:async';

class SettingsViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StartupService _startupService = StartupService();
  
  UserSettingsModel _settings = const UserSettingsModel();
  bool _isLoading = false;
  String? _errorMessage;
  String? _kycStatus;

  UserSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get kycStatus => _kycStatus;

  bool _isInitialized = false;

  SettingsViewModel(); // Constructor không tự động load để tránh redundant request

  /// Bootstrapping: Nhận data từ main.dart
  void setInitialData(StartupProfileDto profile) {
    _settings = _settings.copyWith(isVisible: profile.isVisible);
    _kycStatus = profile.kycStatus;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _startupService.getMyProfile();
      if (response.success && response.data != null) {
        final profile = response.data!;
        _settings = _settings.copyWith(isVisible: profile.isVisible);
        _kycStatus = profile.kycStatus;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleProfileVisibility(bool value) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _startupService.toggleVisibility(value);
    
    if (response.success) {
      _settings = _settings.copyWith(isVisible: value);
    } else {
      _errorMessage = response.error ?? 'Không thể cập nhật trạng thái hiển thị';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _settings = _settings.copyWith(isDarkMode: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    // Local persistence logic could go here
    notifyListeners();
  }

  Future<bool> changePassword(String current, String newPwd, String confirmNewPwd) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final request = ChangePasswordRequest(
      currentPassword: current,
      newPassword: newPwd,
      confirmNewPassword: confirmNewPwd,
    );

    final response = await _authService.changePassword(request);
    
    _isLoading = false;
    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Đã có lỗi xảy ra khi đổi mật khẩu';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    print("User logged out");
  }
}
