import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';

void main() {
  runApp(const DashboardPreviewApp());
}

class DashboardPreviewApp extends StatelessWidget {
  const DashboardPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard Preview',
      debugShowCheckedModeBanner: false,
      theme: StartupOnboardingTheme.darkTheme,
      home: const DashboardView(),
    );
  }
}
