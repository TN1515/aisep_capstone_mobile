import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_otp_verification_view.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';
import 'package:aisep_capstone_mobile/features/auth/models/auth_request_models.dart';

class RegistrationViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> register(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      final request = RegisterRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        userType: 'Startup', // Bắt buộc Startup theo yêu cầu
      );
      
      final response = await _authService.register(request);

      if (response.success) {
        // Success -> Chuyển sang màn hình xác thực OTP
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StartupOtpVerificationView(
                email: emailController.text.trim(),
                isPasswordReset: false,
              ),
            ),
          );
        }
      } else {
        setError(response.error ?? 'Đăng ký thất bại. Vui lòng kiểm tra lại thông tin.');
      }
    } catch (e) {
      setError('Lỗi kết nối hệ thống. Vui lòng thử lại sau.');
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
