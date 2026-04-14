import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/consulting/view_models/consulting_view_model.dart';
import 'package:aisep_capstone_mobile/features/consulting/widgets/advisor_card.dart';
import 'package:aisep_capstone_mobile/features/consulting/views/advisor_profile_view.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class BookmarkedAdvisorsView extends StatelessWidget {
  const BookmarkedAdvisorsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Danh sách theo dõi',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Consumer<ConsultingViewModel>(
          builder: (context, viewModel, child) {
            final bookmarked = viewModel.advisors.where((a) => a.isBookmarked).toList();

            if (bookmarked.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.heartOff, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.2)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có cố vấn nào trong danh sách.',
                      style: GoogleFonts.workSans(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Khám phá Cố vấn ngay',
                        style: GoogleFonts.workSans(color: StartupOnboardingTheme.goldAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: bookmarked.length,
              itemBuilder: (context, index) {
                final advisor = bookmarked[index];
                return AdvisorCard(
                  advisor: advisor,
                  onBookmark: () => viewModel.toggleBookmark(advisor.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdvisorProfileView(advisor: advisor),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
