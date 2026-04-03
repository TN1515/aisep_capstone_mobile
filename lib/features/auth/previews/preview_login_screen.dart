import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_login_view.dart';

/// Một file preview riêng biệt cho màn hình Đăng nhập (Login).
/// Giúp preview UI nhanh mà không cần qua splash/onboarding.
void main() {
  runApp(const LoginPreviewApp());
}

class LoginPreviewApp extends StatelessWidget {
  const LoginPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login UI Preview',
      debugShowCheckedModeBanner: false,
      theme: StartupOnboardingTheme.darkTheme,
      home: const StartupLoginView(),
      // Giả lập route để tránh crash khi nhấn nút đăng ký/quên mật khẩu
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text('Trang đích: ${settings.name}')),
        ),
      ),
    );
  }
}
