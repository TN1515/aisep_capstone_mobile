import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';

/// File Preview cho màn hình Onboarding.
/// 
/// Cách chạy:
/// 1. Chuột phải vào file này -> Run 'preview_onboarding.dart'
/// 2. Hoặc chạy lệnh: flutter run lib/features/onboarding/previews/preview_onboarding.dart
void main() {
  runApp(const OnboardingPreviewApp());
}

class OnboardingPreviewApp extends StatelessWidget {
  const OnboardingPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding Preview',
      debugShowCheckedModeBanner: false,
      theme: StartupOnboardingTheme.darkTheme,
      home: const StartupOnboardingScreen(),
      // Mock routes if navigation is needed
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Target Screen')),
            body: Center(child: Text('Navigated to: ${settings.name}')),
          ),
        );
      },
    );
  }
}
