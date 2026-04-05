import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/settings/view_models/settings_view_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConsultingViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'AISEP Startup',
            debugShowCheckedModeBanner: false,
            theme: settingsViewModel.settings.isDarkMode 
                ? StartupOnboardingTheme.darkTheme 
                : StartupOnboardingTheme.lightTheme,
            home: const StartupOnboardingScreen(),
          );
        },
      ),
    );
  }
}
