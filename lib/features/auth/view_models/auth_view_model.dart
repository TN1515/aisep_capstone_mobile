import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';
import 'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import '../models/auth_request_models.dart';
import '../models/auth_response_model.dart';
import '../services/auth_service.dart';

enum LoginDestination { dashboard, createProfile, onboarding }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StartupService _startupService = StartupService();

  bool _isBusy = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // 1. Đăng ký (Register)
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _setBusy(true);
    final request = RegisterRequest(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      userType: 'Startup',
    );
    final response = await _authService.register(request);
    
    _setBusy(false);
    if (response.success) {
      _successMessage = 'Đăng ký thành công! Vui lòng kiểm tra mã OTP.';
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.error ?? 'Đăng ký thất bại';
      notifyListeners();
      return false;
    }
  }

  // 2. Xác thực OTP (Verify Email)
  Future<LoginDestination> verifyEmail({required String email, required String otp}) async {
    _setBusy(true);
    final response = await _authService.verifyEmail(VerifyEmailRequest(email: email, otp: otp));
    
    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
      
      // MAPPING API: Sử dụng userType từ UserModel (đã bóc từ data string)
      final destination = await _checkStartupProfile(response.data!.user.userType);
      _setBusy(false);
      return destination;
    } else {
      _errorMessage = response.error ?? 'Mã OTP không chính xác';
      _setBusy(false);
      return LoginDestination.onboarding;
    }
  }

  // 3. Đăng nhập (Login)
  Future<LoginDestination> login({required String email, required String password}) async {
    _setBusy(true);
    _errorMessage = null;
    
    final response = await _authService.login(LoginRequest(email: email, password: password));
    
    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
      
      final destination = await _checkStartupProfile(response.data!.user.userType);
      _setBusy(false);
      return destination;
    } else {
      _errorMessage = response.error ?? 'Đăng nhập thất bại. Kiểm tra lại thông tin.';
      _setBusy(false);
      return LoginDestination.onboarding;
    }
  }

  /// MAPPING API: Gọi GET /api/startups/me để xác định đích đến
  Future<LoginDestination> _checkStartupProfile(String userType) async {
    // Chấp nhận cả 'Startup' hoặc chuỗi chứa 'Startup' tùy theo backend
    if (!userType.toLowerCase().contains('startup')) {
       return LoginDestination.dashboard; 
    }

    try {
      final profileResponse = await _startupService.getMyProfile();
      if (profileResponse.success && profileResponse.data != null) {
        return LoginDestination.dashboard;
      } else {
        return LoginDestination.createProfile;
      }
    } catch (_) {
      return LoginDestination.createProfile;
    }
  }

  // 4. Gửi lại mã OTP
  Future<void> resendOtp(String email) async {
    final response = await _authService.resend(email);
    if (!response.success) {
      _errorMessage = response.error;
      notifyListeners();
    }
  }

  // 5. Quên mật khẩu
  Future<bool> forgotPassword(String email) async {
    _setBusy(true);
    final response = await _authService.forgotPassword(email);
    _setBusy(false);
    return response.success;
  }

  // 6. Đổi mật khẩu
  Future<bool> changePassword(String current, String newPwd, String confirmNewPwd) async {
    _setBusy(true);
    final response = await _authService.changePassword(
      ChangePasswordRequest(
        currentPassword: current,
        newPassword: newPwd,
        confirmNewPassword: confirmNewPwd,
      ),
    );
    _setBusy(false);
    if (!response.success) {
      _errorMessage = response.error;
    }
    return response.success;
  }

  // 7. Đăng xuất
  Future<void> logout() async {
    await _authService.logout();
    await TokenService.clearAuthData();
    notifyListeners();
  }

  // Private helpers
  void _setBusy(bool value) {
    _isBusy = value;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _saveAuthData(AuthResponse data) async {
    await TokenService.saveTokens(
      accessToken: data.accessToken,
      refreshToken: data.refreshToken,
    );
    await TokenService.saveUserInfo(
      userId: data.user.userId.toString(),
      userType: data.user.userType,
    );
  }
}
