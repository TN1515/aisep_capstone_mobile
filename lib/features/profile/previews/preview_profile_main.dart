import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/profile/views/startup_profile_view.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';

void main() {
  runApp(const StartupProfilePreviewApp());
}

class StartupProfilePreviewApp extends StatelessWidget {
  const StartupProfilePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StartupProfileViewModel(),
      child: MaterialApp(
        title: 'Startup Profile Preview',
        debugShowCheckedModeBanner: false,
        theme: StartupOnboardingTheme.darkTheme,
        home: const StartupProfileView(),
      ),
    );
  }
}
