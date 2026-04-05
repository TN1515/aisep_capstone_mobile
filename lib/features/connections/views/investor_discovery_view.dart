import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import '../view_models/connection_view_model.dart';
import '../widgets/investor_discovery_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'investor_profile_view.dart';

class InvestorDiscoveryView extends StatefulWidget {
  const InvestorDiscoveryView({Key? key}) : super(key: key);

  @override
  State<InvestorDiscoveryView> createState() => _InvestorDiscoveryViewState();
}

class _InvestorDiscoveryViewState extends State<InvestorDiscoveryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = ConnectionViewModel();
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Tìm nhà đầu tư'),
          ),
          body: Column(
            children: [
              // Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.workSans(color: textColor),
                          onChanged: viewModel.setSearchQuery,
                          decoration: InputDecoration(
                            icon: Icon(LucideIcons.search, size: 20, color: theme.primaryColor),
                            hintText: 'Tên, quỹ, lĩnh vực...',
                            hintStyle: GoogleFonts.workSans(color: textColor.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(LucideIcons.sliders, color: theme.primaryColor, size: 20),
                    ),
                  ],
                ),
              ),

              // Filters Quick Select
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _QuickFilterChip(label: 'Tất cả', isSelected: true),
                    _QuickFilterChip(label: 'AI & Data'),
                    _QuickFilterChip(label: 'Fintech'),
                    _QuickFilterChip(label: 'EdTech'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Discovery List
              Expanded(
                child: viewModel.isLoading 
                  ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                  : viewModel.discoveryResults.isEmpty 
                    ? _buildEmptySearch(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: viewModel.discoveryResults.length,
                        itemBuilder: (context, index) {
                          final investor = viewModel.discoveryResults[index];
                          return InvestorDiscoveryCard(
                            investor: investor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => InvestorProfileView(investor: investor)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySearch(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 60, color: textColor.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhà đầu tư nào phù hợp.',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(color: textColor.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _QuickFilterChip({Key? key, required this.label, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.primaryColor : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Colors.transparent : theme.dividerColor),
      ),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
            ? (theme.brightness == Brightness.dark ? StartupOnboardingTheme.navyBg : Colors.white)
            : (theme.textTheme.bodyLarge?.color?.withOpacity(0.6) ?? Colors.white),
        ),
      ),
    );
  }
}
