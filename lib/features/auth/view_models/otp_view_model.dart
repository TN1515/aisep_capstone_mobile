import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_reset_password_view.dart';
import 'package:aisep_capstone_mobile/features/profile/views/profile_setup_view.dart';

class OtpViewModel extends BaseViewModel {
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

  Future<void> verify(BuildContext context, bool isForgotPassword) async {
    String otp = controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setLoading(true);
    clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        if (isForgotPassword) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const StartupResetPasswordView(),
            ),
          );
        } else {
          // Registration success -> Go to Onboarding (or Dashboard)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ProfileSetupView(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setError('Mã OTP không chính xác hoặc đã hết hạn.');
    } finally {
      setLoading(false);
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
