import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/settings/view_models/settings_view_model.dart';
import '../widgets/settings_widgets.dart';
import 'change_password_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cài đặt'),
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
                            title: 'Hiển thị cho Nhà đầu tư',
                            subtitle: 'Nhà đầu tư sẽ thấy hồ sơ và có thể kết nối với bạn',
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.showToInvestors,
                              viewModel.toggleShowToInvestors,
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.userPlus,
                            title: 'Hiển thị cho Cố vấn',
                            subtitle: 'Cố vấn có thể tìm thấy và gửi lời mời tư vấn cho bạn',
                            isLast: true,
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.showToAdvisors,
                              viewModel.toggleShowToAdvisors,
                            ),
                          ),
                        ],
                      ),

                      // Notifications Section
                      SettingsSection(
                        title: 'Thông báo',
                        children: [
                          SettingsTile(
                            icon: LucideIcons.bell,
                            title: 'Thông báo đẩy (Push)',
                            subtitle: 'Nhận thông báo quan trọng ngay trên điện thoại',
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.pushNotifications,
                              viewModel.togglePushNotifications,
                            ),
                          ),
                          SettingsTile(
                            icon: LucideIcons.mail,
                            title: 'Thông báo Email',
                            subtitle: 'Nhận báo cáo định kỳ và tin nhắn qua email',
                            isLast: true,
                            trailing: _buildSwitch(
                              context,
                              viewModel.settings.emailNotifications,
                              viewModel.toggleEmailNotifications,
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

                      // Logout Section
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
                            onTap: () => _confirmLogout(context, viewModel),
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

  void _confirmLogout(BuildContext context, SettingsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: StartupOnboardingTheme.navySurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Xác nhận đăng xuất?',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StartupOnboardingTheme.softIvory,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng ứng dụng.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 14,
                color: StartupOnboardingTheme.softIvory.withOpacity(0.6),
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
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.workSans(
                        color: StartupOnboardingTheme.softIvory,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.logout();
                      Navigator.pop(context); // Close bottom sheet
                      Navigator.pop(context); // Logout
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Đăng xuất',
                      style: GoogleFonts.workSans(
                        color: Colors.white,
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
