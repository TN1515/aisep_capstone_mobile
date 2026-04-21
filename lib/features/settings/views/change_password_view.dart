import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/app_colors.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:provider/provider.dart';
import '../view_models/settings_view_model.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Đổi mật khẩu',
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Security Icon Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.shieldCheck,
                        color: StartupOnboardingTheme.goldAccent,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bảo mật tài khoản',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.displayLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đảm bảo mật khẩu của bạn có ít nhất 8 ký tự và bao gồm các ký tự đặc biệt.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.dividerColor),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldHeader(context, 'Mật khẩu hiện tại'),
                          _buildPasswordField(
                            context,
                            controller: _currentController,
                            hint: 'Nhập mật khẩu hiện tại',
                            obscure: _obscureCurrent,
                            toggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu hiện tại';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFieldHeader(context, 'Mật khẩu mới'),
                          _buildPasswordField(
                            context,
                            controller: _newController,
                            hint: 'Ít nhất 8 ký tự',
                            obscure: _obscureNew,
                            toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                            validator: (value) {
                              if (value == null || value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildFieldHeader(context, 'Xác nhận mật khẩu'),
                          _buildPasswordField(
                            context,
                            controller: _confirmController,
                            hint: 'Nhập lại mật khẩu mới',
                            obscure: _obscureConfirm,
                            toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            validator: (value) {
                              if (value != _newController.text) return 'Mật khẩu không khớp';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final success = await viewModel.changePassword(
                              _currentController.text,
                              _newController.text,
                              _confirmController.text,
                            );
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã cập nhật mật khẩu thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.errorMessage ?? 'Đã có lỗi xảy ra'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StartupOnboardingTheme.goldAccent,
                          foregroundColor: isDark ? StartupOnboardingTheme.navyBg : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading 
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, 
                                  color: isDark ? StartupOnboardingTheme.navyBg : Colors.white,
                                ),
                              )
                            : Text(
                                'Cập nhật mật khẩu',
                                style: GoogleFonts.workSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFieldHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.displayLarge?.color?.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggleObscure,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.workSans(color: theme.textTheme.bodyLarge?.color),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.workSans(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark 
            ? StartupOnboardingTheme.navyBg.withOpacity(0.5) 
            : Colors.grey.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StartupOnboardingTheme.goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? LucideIcons.eye : LucideIcons.eyeOff,
            color: theme.iconTheme.color?.withOpacity(0.5),
            size: 20,
          ),
          onPressed: toggleObscure,
        ),
      ),
    );
  }
}
