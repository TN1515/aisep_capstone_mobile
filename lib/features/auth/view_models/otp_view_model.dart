import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';
import 'package:aisep_capstone_mobile/features/auth/models/auth_request_models.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_reset_password_view.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/views/create_startup_profile_view.dart';
import 'package:provider/provider.dart';

class OtpViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  int _timerSeconds = 60;
  Timer? _timer;

  int get timerSeconds => _timerSeconds;

  void startResendTimer() {
    _timer?.cancel();
    _timerSeconds = 60;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> resendOtp(String email) async {
    final response = await _authService.resend(email);
    if (!response.success) {
      setError(response.error ?? 'Gửi lại mã thất bại');
    } else {
      startResendTimer();
    }
  }

  Future<void> verify(BuildContext context, String email, bool isForgotPassword) async {
    String otp = controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setError('Vui lòng nhập đầy đủ 6 chữ số');
      return;
    }

    setLoading(true);
    clearError();

    try {
      final authViewModel = context.read<AuthViewModel>();

      if (isForgotPassword) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StartupResetPasswordView(email: email, otp: otp),
            ),
          );
        }
      } else {
        // MAPPING API: Sử dụng AuthViewModel để xác thực và nhận Destination
        final destination = await authViewModel.verifyEmail(email: email, otp: otp);

        if (context.mounted) {
          if (destination != LoginDestination.onboarding) {
            Widget screen = destination == LoginDestination.dashboard 
                ? const DashboardView() 
                : const CreateStartupProfileView();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => screen),
              (route) => false,
            );
          } else {
            setError(authViewModel.errorMessage ?? 'Xác thực thất bại');
          }
        }
      }
    } catch (e) {
      setError('Lỗi kết nối. Vui lòng thử lại.');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
