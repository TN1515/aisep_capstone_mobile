import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/widgets/startup_auth_text_field.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_registration_view.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_forgot_password_view.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/login_view_model.dart';

class StartupLoginView extends StatefulWidget {
  const StartupLoginView({super.key});

  @override
  State<StartupLoginView> createState() => _StartupLoginViewState();
}

class _StartupLoginViewState extends State<StartupLoginView> {
  final _formKey = GlobalKey<FormState>();
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StartupOnboardingTheme.darkTheme,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: StartupOnboardingTheme.softIvory),
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
                      const SizedBox(height: 32),
                      FadeInDown(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: StartupOnboardingTheme.navySurface,
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
                              Icons.lock_person_rounded,
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
                          'Chào mừng trở lại',
                          style: StartupOnboardingTheme.darkTheme.textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Đăng nhập để tiếp tục hành trình AISEP của bạn',
                          style: StartupOnboardingTheme.darkTheme.textTheme.bodyLarge,
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
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StartupAuthTextField(
                              label: 'Mật khẩu',
                              hint: 'Nhập mật khẩu',
                              controller: _viewModel.passwordController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline_rounded,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const StartupForgotPasswordView(),
                                  ),
                                );
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: GoogleFonts.workSans(
                                  color: StartupOnboardingTheme.goldAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _viewModel.isLoading ? null : () => _viewModel.login(context, _formKey),
                            child: _viewModel.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: StartupOnboardingTheme.navyBg, strokeWidth: 2),
                                  )
                                : const Text('Đăng nhập'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Bạn chưa có tài khoản?',
                                style: GoogleFonts.workSans(
                                  color: StartupOnboardingTheme.softIvory.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const StartupRegistrationView()),
                                  );
                                },
                                child: Text(
                                  'Đăng ký ngay',
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
