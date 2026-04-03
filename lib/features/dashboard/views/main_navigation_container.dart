import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/startup_bottom_nav_bar.dart';
import 'package:aisep_capstone_mobile/features/profile/views/startup_profile_view.dart';

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({Key? key}) : super(key: key);

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const PlaceholderScreen(title: 'Tài liệu', icon: Icons.article_rounded),
    const PlaceholderScreen(title: 'Kết nối', icon: Icons.people_alt_rounded),
    const StartupProfileView(), // Index 3: Profile Screen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      // The body is wrapped in IndexedStack to preserve state between tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: StartupOnboardingTheme.navyBg,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            color: StartupOnboardingTheme.goldAccent,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Fixed Bottom Navigation Bar
      bottomNavigationBar: StartupBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Simple placeholder screen for tabs not yet fully implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: StartupOnboardingTheme.navySurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 64,
              color: StartupOnboardingTheme.goldAccent.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: StartupOnboardingTheme.softIvory,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tính năng đang được phát triển bộ giao diện mới.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              color: StartupOnboardingTheme.slateGray.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              foregroundColor: StartupOnboardingTheme.goldAccent,
              side: const BorderSide(color: StartupOnboardingTheme.goldAccent),
            ),
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }
}
