import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../models/investor_model.dart';
import '../widgets/investor_profile_header.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'connection_request_form_view.dart';

class InvestorProfileView extends StatelessWidget {
  final InvestorModel investor;

  const InvestorProfileView({Key? key, required this.investor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = StartupOnboardingTheme.softIvory;

    return Scaffold(
      backgroundColor: StartupOnboardingTheme.navyBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: InvestorProfileHeader(investor: investor),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle('TÓM TẮT THESIS'),
                    const SizedBox(height: 12),
                    Text(
                      investor.thesis,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: textColor.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('LĨNH VỰC QUAN TÂM'),
                    const SizedBox(height: 12),
                    _buildChipGroup(investor.preferredIndustries),
                    const SizedBox(height: 32),
                    _buildSectionTitle('GIAI ĐOẠN ĐẦU TƯ'),
                    const SizedBox(height: 12),
                    _buildChipGroup(investor.preferredStages),
                    const SizedBox(height: 32),
                    _buildSectionTitle('HỖ TRỢ CUNG CẤP'),
                    const SizedBox(height: 12),
                    Text(
                      investor.supportOffered,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: textColor.withOpacity(0.8),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 120), // Space for bottom button
                  ]),
                ),
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: StartupOnboardingTheme.softIvory),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Global CTA
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Container(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToRequestForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: StartupOnboardingTheme.goldAccent,
                  foregroundColor: StartupOnboardingTheme.navyBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: StartupOnboardingTheme.goldAccent.withOpacity(0.3),
                ),
                child: Text(
                  'Gửi yêu cầu kết nối',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: StartupOnboardingTheme.goldAccent,
      ),
    );
  }

  Widget _buildChipGroup(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: StartupOnboardingTheme.navySurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          item,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: StartupOnboardingTheme.softIvory.withOpacity(0.8),
          ),
        ),
      )).toList(),
    );
  }

  void _navigateToRequestForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectionRequestFormView(investor: investor),
      ),
    );
  }
}
