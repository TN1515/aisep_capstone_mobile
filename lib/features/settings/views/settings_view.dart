import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/features/settings/view_models/settings_view_model.dart';
import '../widgets/settings_widgets.dart';
import 'change_password_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<SettingsViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cài đặt', style: theme.appBarTheme.titleTextStyle),
      ),
      body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Privacy Section
                      SettingsSection(
                        title: 'Quyền riêng tư',
                        children: [
                          SettingsTile(
                            icon: LucideIcons.eye,
                            title: 'Hiển thị hồ sơ',
                            subtitle: 'Cho phép Nhà đầu tư và Cố vấn tìm thấy hồ sơ của bạn',
                            isLast: true,
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.isVisible,
                              (value) async {
                                await viewModel.toggleProfileVisibility(value);
                                if (viewModel.errorMessage != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(viewModel.errorMessage!),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      // Account Section
                      SettingsSection(
                        title: 'Tài khoản',
                        children: [
                          SettingsTile(
                            icon: LucideIcons.lock,
                            title: 'Đổi mật khẩu',
                            subtitle: 'Cập nhật mật khẩu để bảo vệ tài khoản',
                            isLast: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ChangePasswordView()),
                              );
                            },
                          ),
                        ],
                      ),

                      // System Section
                      SettingsSection(
                        title: 'Hệ thống',
                        children: [
                          SettingsTile(
                            icon: LucideIcons.moon,
                            title: 'Giao diện tối',
                            subtitle: 'Kích hoạt giao diện chế độ ban đêm',
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.isDarkMode,
                              viewModel.toggleDarkMode,
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.logOut,
                            title: 'Đăng xuất',
                            isDestructive: true,
                            isLast: true,
                            onTap: () => _confirmLogout(context, viewModel, authViewModel),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSwitch(BuildContext context, bool value, Function(bool) onChanged) {
    return Switch.adaptive(
      value: value,
      activeColor: StartupOnboardingTheme.goldAccent,
      onChanged: onChanged,
    );
  }

  void _confirmLogout(BuildContext context, SettingsViewModel viewModel, AuthViewModel authViewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Xác nhận đăng xuất?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng ứng dụng.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.dividerColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.workSans(
                        color: theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      authViewModel.logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const StartupOnboardingScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Đăng xuất',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
