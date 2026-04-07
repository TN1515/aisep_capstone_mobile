import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/views/create_startup_profile_view.dart';
import 'package:aisep_capstone_mobile/features/startup_profile/services/startup_service.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/settings/view_models/settings_view_model.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';
import 'package:aisep_capstone_mobile/core/navigation/navigator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Chỉ kiểm tra Token nhanh ở tầng native
  final bool isLoggedIn = await TokenService.hasToken();
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConsultingViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => KycViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StartupProfileViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'AISEP Startup',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigatorService.navigatorKey,
            theme: StartupOnboardingTheme.lightTheme,
            darkTheme: StartupOnboardingTheme.darkTheme,
            themeMode: settingsViewModel.settings.isDarkMode 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: _RootWrapper(isLoggedIn: isLoggedIn),
          );
        },
      ),
    );
  }
}

/// Widget trung gian kiểm tra trạng thái hồ sơ sau khi đã có Token
class _RootWrapper extends StatefulWidget {
  final bool isLoggedIn;
  const _RootWrapper({required this.isLoggedIn});

  @override
  State<_RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends State<_RootWrapper> {
  bool? _hasProfile;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _checkProfile();
    } else {
      _hasProfile = false;
    }
  }

  Future<void> _checkProfile() async {
    setState(() => _isChecking = true);
    try {
      final profileResponse = await StartupService().getMyProfile();
      
      if (mounted) {
        if (profileResponse.success && profileResponse.data != null) {
          setState(() {
            _hasProfile = true;
            _isChecking = false;
          });
        } else if (profileResponse.statusCode == 401) {
          await TokenService.clearAuthData();
          setState(() {
            _hasProfile = false;
            _isChecking = false;
          });
          // Redirect handled by Navigator if needed, but here we just update state
        } else {
          setState(() {
            _hasProfile = false;
            _isChecking = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasProfile = false;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn && !_isChecking) {
      return const StartupOnboardingScreen();
    }

    if (_isChecking || _hasProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              const Text('Đang tải...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (_hasProfile!) {
      return const DashboardView();
    }
    
    return const CreateStartupProfileView();
  }
}
