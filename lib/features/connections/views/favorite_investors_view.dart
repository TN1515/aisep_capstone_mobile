import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:provider/provider.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/investor_discovery_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'investor_profile_view.dart';

class FavoriteInvestorsView extends StatelessWidget {
  const FavoriteInvestorsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ConnectionViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Theme.of(context).textTheme.displayLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Danh sách yêu thích',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.displayLarge?.color,
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
                  Icon(LucideIcons.heart, size: 64, color: Theme.of(context).dividerColor),
                  const SizedBox(height: 24),
                  Text(
                    'Chưa có nhà đầu tư yêu thích nào.',
                    style: GoogleFonts.workSans(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.4),
                    ),
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
