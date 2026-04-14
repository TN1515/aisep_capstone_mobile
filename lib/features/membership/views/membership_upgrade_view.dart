import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../view_models/membership_upgrade_view_model.dart';
import '../widgets/plan_card.dart';
import '../widgets/feature_comparison_table.dart';
import 'membership_payment_view.dart';

class MembershipUpgradeView extends StatelessWidget {
  const MembershipUpgradeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembershipUpgradeViewModel(),
      child: Consumer<MembershipUpgradeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Nâng cấp thành viên'),
            ),
            body: Stack(
              children: [
                // Background Gradient Glow
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.7, -0.2),
                        radius: 1.2,
                        colors: [
                          viewModel.selectedPlan.accentColor?.withOpacity(0.05) ?? StartupOnboardingTheme.goldAccent.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(context),
                      const SizedBox(height: 32),
                      _buildPlansHorizontalList(viewModel),
                      const SizedBox(height: 48),
                      FeatureComparisonTable(
                        plans: viewModel.plans,
                        selectedTier: viewModel.selectedPlan.tier,
                      ),
                      const SizedBox(height: 140), // More space for sticky footer
                    ],
                  ),
                ),
                _buildStickyCTA(context, viewModel),
                if (viewModel.isLoading)
                  _buildLoadingOverlay(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, size: 14, color: StartupOnboardingTheme.goldAccent),
                const SizedBox(width: 6),
                Text(
                  'TIẾT KIỆM TỚI 20% KHI THANH TOÁN NĂM',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chọn gói hội viên\ncủa bạn',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.displayLarge?.color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mở khóa các tính năng cao cấp để tăng tốc hành trình gọi vốn của bạn.',
            style: GoogleFonts.workSans(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansHorizontalList(MembershipUpgradeViewModel viewModel) {
    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: viewModel.plans.length,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final plan = viewModel.plans[index];
          final bool isLocked = plan.tier.index < viewModel.currentPlan.tier.index;
          return Opacity(
            opacity: isLocked ? 0.4 : 1.0,
            child: PlanCard(
              plan: plan,
              isSelected: viewModel.selectedPlan.tier == plan.tier,
              isCurrentPlan: viewModel.currentPlan.tier == plan.tier,
              onSelect: () {
                if (!isLocked) viewModel.selectPlan(plan);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickyCTA(BuildContext context, MembershipUpgradeViewModel viewModel) {
    final isCurrent = viewModel.selectedPlan.tier == viewModel.currentPlan.tier;
    final isLower = viewModel.selectedPlan.tier.index < viewModel.currentPlan.tier.index;
    final accentColor = viewModel.selectedPlan.accentColor ?? StartupOnboardingTheme.goldAccent;

    String ctaText = 'NÂNG CẤP LÊN ${viewModel.selectedPlan.name.toUpperCase()}';
    if (isCurrent) ctaText = 'GÓI CỦA BẠN';
    if (isLower) ctaText = 'KHÔNG THỂ HẠ CẤP';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0, 0.4],
          ),
        ),
        child: ElevatedButton(
          onPressed: (isCurrent || isLower) 
              ? null 
              : () => _navigateToPayment(context, viewModel),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: StartupOnboardingTheme.navyBg,
            disabledBackgroundColor: StartupOnboardingTheme.navySurface,
            disabledForegroundColor: StartupOnboardingTheme.softIvory.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            ctaText,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context, MembershipUpgradeViewModel viewModel) async {
    final paymentInfo = await viewModel.initiateUpgrade();
    
    if (paymentInfo != null && context.mounted) {
      final Uri url = Uri.parse(paymentInfo.checkoutUrl);
      
      try {
        final bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
        
        if (launched && context.mounted) {
          // Show helpful instruction dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: StartupOnboardingTheme.navySurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                   const Icon(Icons.payment_rounded, color: StartupOnboardingTheme.goldAccent),
                   const SizedBox(width: 12),
                   Text('Thanh toán PayOS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18)),
                ],
              ),
              content: Text(
                'Ứng dụng đang mở cổng thanh toán trên trình duyệt. Sau khi hoàn thành, vui lòng quay lại đây để tiếp tục.',
                style: GoogleFonts.workSans(color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ĐÃ HIỂU', style: GoogleFonts.outfit(color: StartupOnboardingTheme.goldAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else if (context.mounted) {
          throw 'Could not launch URL';
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.orange,
              content: Text('Không thể mở trình duyệt tự động. Vui lòng kiểm tra cài đặt máy.'),
            ),
          );
        }
      }
    } else if (viewModel.errorMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(viewModel.errorMessage!),
        ),
      );
    }
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      child: const Center(
        child: CircularProgressIndicator(color: StartupOnboardingTheme.goldAccent),
      ),
    );
  }
}
