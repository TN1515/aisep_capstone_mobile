import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/investor_discovery_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'investor_profile_view.dart';

class FavoriteInvestorsView extends StatelessWidget {
  const FavoriteInvestorsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();

    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      appBar: AppBar(
        backgroundColor: StartupOnboardingTheme.navyBg,
        elevation: 0,
        title: Text(
          'Danh sách yêu thích',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: StartupOnboardingTheme.softIvory,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          final favorites = viewModel.favoriteInvestors;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.heart, size: 64, color: StartupOnboardingTheme.softIvory.withOpacity(0.1)),
                  const SizedBox(height: 24),
                  Text(
                    'Chưa có nhà đầu tư yêu thích nào.',
                    style: GoogleFonts.workSans(color: StartupOnboardingTheme.softIvory.withOpacity(0.4)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final investor = favorites[index];
              return InvestorDiscoveryCard(
                investor: investor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InvestorProfileView(investor: investor)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
