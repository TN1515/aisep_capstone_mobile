import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/widgets/startup_auth_text_field.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/reset_password_view_model.dart';

class StartupResetPasswordView extends StatefulWidget {
  const StartupResetPasswordView({super.key});

  @override
  State<StartupResetPasswordView> createState() => _StartupResetPasswordViewState();
}

class _StartupResetPasswordViewState extends State<StartupResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      FadeInDown(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.password_rounded,
                              size: 50,
                              color: StartupOnboardingTheme.goldAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Đặt lại mật khẩu',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Tạo mật khẩu mới mạnh mẽ để bảo vệ tài khoản của bạn',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (_viewModel.error != null)
                        FadeInRight(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              _viewModel.error!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: StartupAuthTextField(
                          label: 'Mật khẩu mới',
                          hint: 'Nhập mật khẩu mới',
                          controller: _viewModel.passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (value.length < 8) {
                              return 'Mật khẩu phải có ít nhất 8 ký tự';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: StartupAuthTextField(
                          label: 'Xác nhận mật khẩu',
                          hint: 'Nhập lại mật khẩu mới',
                          controller: _viewModel.confirmPasswordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_reset_rounded,
                          validator: (value) {
                            if (value != _viewModel.passwordController.text) {
                              return 'Mật khẩu xác nhận không khớp';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : () => _viewModel.resetPassword(context, _formKey),
                            child: _viewModel.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Cập nhật mật khẩu'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    );
  }
}
