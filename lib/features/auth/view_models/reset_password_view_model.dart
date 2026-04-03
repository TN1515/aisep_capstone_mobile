import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_login_view.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> resetPassword(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu đã được cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to Login
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const StartupLoginView()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      setError('Cập nhật mật khẩu thất bại. Vui lòng thử lại sau.');
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
