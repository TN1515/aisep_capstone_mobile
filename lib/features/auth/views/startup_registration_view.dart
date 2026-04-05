import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/widgets/startup_auth_text_field.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_login_view.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/registration_view_model.dart';

class StartupRegistrationView extends StatefulWidget {
  const StartupRegistrationView({super.key});

  @override
  State<StartupRegistrationView> createState() => _StartupRegistrationViewState();
}

class _StartupRegistrationViewState extends State<StartupRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  late final RegistrationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = RegistrationViewModel();
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
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const StartupOnboardingScreen()),
              (route) => false,
            );
          },
        ),
      ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      FadeInDown(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              size: 40,
                              color: StartupOnboardingTheme.goldAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Đăng ký tài khoản Startup',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Bắt đầu hành trình của bạn cùng AISEP',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: StartupAuthTextField(
                          label: 'Email',
                          hint: 'Nhập địa chỉ email của bạn',
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
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: StartupAuthTextField(
                          label: 'Mật khẩu',
                          hint: 'Nhập ít nhất 8 ký tự',
                          controller: _viewModel.passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
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
                        delay: const Duration(milliseconds: 400),
                        child: StartupAuthTextField(
                          label: 'Xác nhận mật khẩu',
                          hint: 'Nhập lại mật khẩu của bạn',
                          controller: _viewModel.confirmPasswordController,
                          isPassword: true,
                          prefixIcon: Icons.shield_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu';
                            }
                            if (value != _viewModel.passwordController.text) {
                              return 'Mật khẩu không trùng khớp';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : () => _viewModel.register(context, _formKey),
                            child: _viewModel.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Đăng ký'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 700),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Bạn đã có tài khoản?',
                                style: GoogleFonts.workSans(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const StartupLoginView()),
                                  );
                                },
                                child: Text(
                                  'Đăng nhập ngay',
                                  style: GoogleFonts.workSans(
                                    color: StartupOnboardingTheme.goldAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
