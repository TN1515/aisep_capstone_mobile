import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/profile/views/profile_setup_view.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/profile_setup_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';

void main() {
  runApp(const ProfileSetupPreviewApp());
}

class ProfileSetupPreviewApp extends StatelessWidget {
  const ProfileSetupPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileSetupViewModel()),
        ChangeNotifierProvider(create: (_) => StartupProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Profile Setup Preview',
        debugShowCheckedModeBanner: false,
        theme: StartupOnboardingTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const ProfileSetupView(),
      ),
    );
  }
}
