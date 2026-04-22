import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/dashboard/views/dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/dashboard/widgets/startup_bottom_nav_bar.dart';
import 'package:aisep_capstone_mobile/features/profile/views/startup_profile_view.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_form_view.dart';
import 'package:aisep_capstone_mobile/features/documents/views/document_list_view.dart';
import 'package:aisep_capstone_mobile/features/connections/views/connections_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/consulting_dashboard_view.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_discovery_view.dart';
import 'package:aisep_capstone_mobile/features/messages/views/chat_list_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/features/messages/view_models/chat_view_model.dart';
import 'package:aisep_capstone_mobile/features/connections/view_models/connection_view_model.dart';
import 'package:aisep_capstone_mobile/features/profile/view_models/startup_profile_view_model.dart';
import 'package:aisep_capstone_mobile/features/auth/view_models/auth_view_model.dart';
import 'dart:developer' as dev;

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({Key? key}) : super(key: key);

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;



  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Proactively refresh messaging data when switching to the Messaging tab
    if (index == 3) {
      try {
        final chatVm = context.read<ChatViewModel>();
        final connVm = context.read<ConnectionViewModel>();
        final authVm = context.read<AuthViewModel>();
        
        // Inject real account User ID for Me/Partner distinction
        // Using userId instead of startupId because backend usually uses Account ID for messaging
        final myId = authVm.currentUser?.userId ?? 0;
        chatVm.setCurrentUserId(myId);
        
        dev.log('ChatViewModel: Account User ID set to $myId');
        
        // Ensure connections are loaded as they are the source for data synthesis
        connVm.loadReceivedConnections();
        connVm.loadSentConnections();
        
        chatVm.loadConversations(connections: connVm.allConnections);
      } catch (e) {
        // ViewModel might not be available yet in some edge cases
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      resizeToAvoidBottomInset: false,
      // The body is wrapped in IndexedStack to preserve state between tabs
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ConnectionsView(), // Index 0
          const ConsultingDashboardView(), // Index 1
          const DashboardView(), // Index 2
          const ChatListView(), // Index 3: Messaging [FIXED]
          const DocumentListView(), // Index 4: Documents [FIXED]
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdvisorDiscoveryView()),
                  );
                },
                backgroundColor: StartupOnboardingTheme.goldAccent,
                foregroundColor: StartupOnboardingTheme.navyBg,
                icon: const Icon(LucideIcons.search),
                label: Text(
                  'Tìm Cố vấn',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            )
          : Container(
              height: 64,
              width: 64,
              margin: const EdgeInsets.only(top: 10),
              child: FloatingActionButton(
                onPressed: () => _onTabTapped(2),
                backgroundColor: _currentIndex == 2 ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navySurface,
                elevation: 4,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.home_rounded,
                  color: _currentIndex == 2 ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.goldAccent,
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
