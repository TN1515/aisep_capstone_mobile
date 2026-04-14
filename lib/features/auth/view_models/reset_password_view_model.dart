import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_login_view.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';
import 'package:aisep_capstone_mobile/features/auth/models/auth_request_models.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final AuthService _authService = AuthService();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final String email;
  final String otp;

  ResetPasswordViewModel({required this.email, required this.otp});

  Future<void> resetPassword(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      setError('Mật khẩu nhập lại không khớp');
      return;
    }

    setLoading(true);
    clearError();

    try {
      final response = await _authService.resetPassword(
        ResetPasswordRequest(
          email: email,
          newPassword: passwordController.text,
          confirmNewPassword: confirmPasswordController.text,
        ),
      );

      if (response.success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mật khẩu đã được cập nhật thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Quay lại màn hình Đăng nhập sau 1 giây
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const StartupLoginView()),
                (route) => false,
              );
            }
          });
        }
      } else {
        setError(response.error ?? 'Cập nhật mật khẩu thất bại. Vui lòng thử lại sau.');
      }
    } catch (e) {
      setError('Lỗi kết nối hệ thống. Vui lòng thử lại.');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
