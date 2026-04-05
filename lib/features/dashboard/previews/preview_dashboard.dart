import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';

import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';

void main() {
  runApp(const DashboardPreviewApp());
}

class DashboardPreviewApp extends StatelessWidget {
  const DashboardPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ConsultingViewModel()),
      ],
      child: MaterialApp(
        title: 'Dashboard Preview',
        debugShowCheckedModeBanner: false,
        theme: StartupOnboardingTheme.darkTheme,
        home: const DashboardView(),
      ),
    );
  }
}
