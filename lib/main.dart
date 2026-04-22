import 'package:flutter/material.dart';
import 'package:aisep_capstone_mobile/features/onboarding/views/startup_onboarding_screen.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/core/services/token_service.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_login_view.dart';
import 'package:aisep_capstone_mobile/features/profile/views/profile_setup_view.dart';
import 'package:aisep_capstone_mobile/features/profile/services/startup_service.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/settings/view_models/settings_view_model.dart';
import 'package:aisep_capstone_mobile/features/kyc/view_models/kyc_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/models/startup_models.dart';
import 'package:aisep_capstone_mobile/core/network/api_response.dart';
import 'package:aisep_capstone_mobile/features/evaluation/view_models/evaluation_view_model.dart';
import 'package:aisep_capstone_mobile/features/connections/view_models/connection_view_model.dart';
import 'package:aisep_capstone_mobile/features/messages/view_models/chat_view_model.dart';
import 'package:aisep_capstone_mobile/features/documents/view_models/document_view_model.dart';
import 'package:aisep_capstone_mobile/features/notifications/view_models/notification_view_model.dart';
import 'package:aisep_capstone_mobile/core/navigation/navigator_service.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        ChangeNotifierProvider(create: (_) => EvaluationViewModel()),
        ChangeNotifierProvider(create: (_) => ConnectionViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => DocumentViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: MaterialApp(
              title: 'AISEP Startup',
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigatorService.navigatorKey,
              theme: StartupOnboardingTheme.lightTheme,
              darkTheme: StartupOnboardingTheme.darkTheme,
              themeMode: settingsViewModel.settings.isDarkMode 
                  ? ThemeMode.dark 
                  : ThemeMode.light,
              home: _RootWrapper(isLoggedIn: isLoggedIn),
            ),
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
    debugPrint('🚀 Bootstrap Started...');
    try {
      final service = StartupService();
      
      // Chạy song song: Kiểm tra hồ sơ VÀ lấy danh mục (Industries)
      // Thêm timeout 5 giây để tránh treo màn hình splash quá lâu
      final results = await Future.wait([
        service.getMyProfile(),
        service.getIndustries(mode: 'tree'),
      ]).timeout(const Duration(seconds: 5));

      final profileResponse = results[0] as ApiResponse<StartupProfileDto?>;
      final industriesResponse = results[1] as ApiResponse<List<IndustryDto>>;

      debugPrint('✅ Bootstrap Data Received. Status: ${profileResponse.statusCode}');

      if (mounted) {
        final profileDto = profileResponse.data;
        
        // Push dữ liệu vào tất cả ViewModel cùng lúc
        final profileVm = context.read<StartupProfileViewModel>();
        final settingsVm = context.read<SettingsViewModel>();
        final consultingVm = context.read<ConsultingViewModel>();
        
        profileVm.setInitialData(
          profileDto: profileDto,
          industries: industriesResponse.data,
        );
        
        if (profileDto != null) {
          settingsVm.setInitialData(profileDto);
          consultingVm.setInitialProfile(profileDto);
        }

        if (profileResponse.statusCode == 401) {
          await TokenService.clearAuthData();
          setState(() {
            _hasProfile = false;
            _isChecking = false;
          });
          return;
        } 
        
        if (profileResponse.statusCode == 404) {
          setState(() {
            _hasProfile = false;
            _isChecking = false;
          });
        } else {
          setState(() {
            _hasProfile = true; // Mặc định là True để vào Home, trừ khi chắc chắn chưa có (404)
            _isChecking = false;
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Bootstrap Timeout or Error: $e');
      if (mounted) {
        setState(() {
          _hasProfile = true; // An toàn là trên hết, cho vào Home để người dùng tự refresh
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa đăng nhập -> Ưu tiên hiện Onboarding để giới thiệu App
    if (!widget.isLoggedIn) {
      return const StartupOnboardingScreen();
    }

    // Nếu đã đăng nhập -> Kiểm tra xem có profile chưa
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
    
    return const ProfileSetupView();
  }
}
