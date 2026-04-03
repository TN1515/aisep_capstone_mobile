import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/main_navigation_container.dart';

void main() {
  runApp(const PreviewMainNavigationApp());
}

class PreviewMainNavigationApp extends StatelessWidget {
  const PreviewMainNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Navigation Preview',
      theme: StartupOnboardingTheme.darkTheme,
      home: const MainNavigationContainer(),
    );
  }
}
