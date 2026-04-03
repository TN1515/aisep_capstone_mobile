import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_otp_verification_view.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();

  Future<void> sendResetOtp(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      // Success -> Navigate to OTP for reset
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StartupOtpVerificationView(
              email: emailController.text,
              isPasswordReset: true,
            ),
          ),
        );
      }
    } catch (e) {
      setError('Không thể gửi mã OTP. Vui lòng kiểm tra lại email.');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
