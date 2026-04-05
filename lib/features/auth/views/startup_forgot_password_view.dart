import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/widgets/startup_auth_text_field.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/forgot_password_view_model.dart';

class StartupForgotPasswordView extends StatefulWidget {
  const StartupForgotPasswordView({super.key});

  @override
  State<StartupForgotPasswordView> createState() => _StartupForgotPasswordViewState();
}

class _StartupForgotPasswordViewState extends State<StartupForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel();
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
                              Icons.mark_email_read_rounded,
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
                          'Quên mật khẩu?',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Nhập email của bạn để nhận mã xác thực (OTP)',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: StartupAuthTextField(
                          label: 'Email',
                          hint: 'Nhập email của bạn',
                          controller: _viewModel.emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Vui lòng nhập email hợp lệ';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : () => _viewModel.sendResetOtp(context, _formKey),
                            child: _viewModel.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Gửi mã xác thực'),
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
