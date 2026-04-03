import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/profile/views/profile_setup_view.dart';

void main() {
  runApp(const ProfileSetupPreviewApp());
}

class ProfileSetupPreviewApp extends StatelessWidget {
  const ProfileSetupPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Setup Preview',
      debugShowCheckedModeBanner: false,
      theme: StartupOnboardingTheme.darkTheme,
      home: const ProfileSetupView(),
    );
  }
}
