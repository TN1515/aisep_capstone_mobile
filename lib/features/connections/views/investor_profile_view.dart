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
    final theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    _buildSectionTitle(context, 'TÓM TẮT THESIS'),
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
                    _buildSectionTitle(context, 'LĨNH VỰC QUAN TÂM'),
                    const SizedBox(height: 12),
                    _buildChipGroup(context, investor.preferredIndustries),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'GIAI ĐOẠN ĐẦU TƯ'),
                    const SizedBox(height: 12),
                    _buildChipGroup(context, investor.preferredStages),
                    const SizedBox(height: 32),
                    _buildSectionTitle(context, 'HỖ TRỢ CUNG CẤP'),
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
              icon: const Icon(LucideIcons.arrowLeft),
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
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: theme.primaryColor.withOpacity(0.3),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildChipGroup(BuildContext context, List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          item,
          style: GoogleFonts.workSans(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
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
