import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_otp_verification_view.dart';

class RegistrationViewModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool validateRegistration(GlobalKey<FormState> formKey) {
    return formKey.currentState!.validate();
  }

  Future<void> register(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!validateRegistration(formKey)) return;

    setLoading(true);
    clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      // Success -> Navigate to OTP
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StartupOtpVerificationView(
              email: emailController.text,
              isPasswordReset: false,
            ),
          ),
        );
      }
    } catch (e) {
      setError('Đăng ký thất bại. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
