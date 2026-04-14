import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/auth/services/auth_service.dart';
import 'package:aisep_capstone_mobile/features/auth/models/auth_request_models.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/features/profile/views/profile_setup_view.dart';
import 'package:provider/provider.dart';

class LoginViewModel extends BaseViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    clearError();

    try {
      final authViewModel = context.read<AuthViewModel>();
      
      // MAPPING API: Gọi đăng nhập qua AuthViewModel để nhận Destination
      final destination = await authViewModel.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (context.mounted) {
        if (destination != LoginDestination.onboarding) {
          // Thành công: Điều hướng dựa trên kết quả API
          Widget screen = destination == LoginDestination.dashboard 
              ? const DashboardView() 
              : const ProfileSetupView();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => screen),
            (route) => false,
          );
        } else {
          // Thất bại: Hiển thị lỗi từ AuthViewModel
          setError(authViewModel.errorMessage ?? 'Đăng nhập thất bại');
        }
      }
    } catch (e) {
      setError('Lỗi kết nối hệ thống. Vui lòng thử lại sau.');
    } finally {
      if (context.mounted) setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
