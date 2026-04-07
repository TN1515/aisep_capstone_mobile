import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/otp_view_model.dart';

class StartupOtpVerificationView extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const StartupOtpVerificationView({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<StartupOtpVerificationView> createState() => _StartupOtpVerificationViewState();
}

class _StartupOtpVerificationViewState extends State<StartupOtpVerificationView> {
  late final OtpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OtpViewModel();
    _viewModel.startResendTimer();
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
                          Icons.verified_user_rounded,
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
                      'Xác thực email',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInLeft(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          const TextSpan(text: 'Nhập mã OTP 6 chữ số đã được gửi đến '),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              color: StartupOnboardingTheme.goldAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 45,
                          child: TextField(
                            controller: _viewModel.controllers[index],
                            focusNode: _viewModel.focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: GoogleFonts.workSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: StartupOnboardingTheme.goldAccent,
                            ),
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: StartupOnboardingTheme.goldAccent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _viewModel.focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                _viewModel.focusNodes[index - 1].requestFocus();
                              }
                              if (_viewModel.controllers.every((c) => c.text.isNotEmpty)) {
                                _viewModel.verify(context, widget.email, widget.isPasswordReset);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading
                            ? null
                            : () => _viewModel.verify(context, widget.email, widget.isPasswordReset),
                        child: _viewModel.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Theme.of(context).brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white, strokeWidth: 2),
                              )
                            : const Text('Xác nhận'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'Không nhận được mã?',
                            style: GoogleFonts.workSans(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _viewModel.timerSeconds == 0 ? () => _viewModel.resendOtp(widget.email) : null,
                            child: Text(
                              _viewModel.timerSeconds > 0
                                  ? 'Gửi lại mã sau ${_viewModel.timerSeconds} giây'
                                  : 'Gửi lại mã ngay',
                              style: GoogleFonts.workSans(
                                color: _viewModel.timerSeconds == 0
                                    ? StartupOnboardingTheme.goldAccent
                                    : StartupOnboardingTheme.slateGray.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
