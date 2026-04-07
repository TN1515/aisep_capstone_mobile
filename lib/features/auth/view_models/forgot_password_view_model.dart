import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_otp_verification_view.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();

  Future<void> sendResetOtp(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      final String email = emailController.text.trim();
      final response = await _authService.forgotPassword(email);

      if (response.success) {
        // Success -> Chuyển sang màn hình xác thực OTP để Reset
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StartupOtpVerificationView(
                email: email,
                isPasswordReset: true,
              ),
            ),
          );
        }
      } else {
        setError(response.error ?? 'Không thể gửi mã OTP. Vui lòng kiểm tra lại email.');
      }
    } catch (e) {
      setError('Lỗi kết nối. Vui lòng thử lại sau.');
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
