import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'package:aisep_capstone_mobile/features/onboarding/widgets/startup_card.dart';
import 'package:aisep_capstone_mobile/features/kyc/views/kyc_form_view.dart';

class KycTypeSelectionView extends StatefulWidget {
  const KycTypeSelectionView({super.key});

  @override
  State<KycTypeSelectionView> createState() => _KycTypeSelectionViewState();
}

class _KycTypeSelectionViewState extends State<KycTypeSelectionView> {
  int? _selectedIndex;

  void _onTypeSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onContinue() {
    if (_selectedIndex != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KycFormView(isIncorporated: _selectedIndex == 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: StartupOnboardingTheme.darkTheme,
      child: Scaffold(
        backgroundColor: StartupOnboardingTheme.navyBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: StartupOnboardingTheme.softIvory),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      FadeInDown(
                        child: Text(
                          'Chọn loại hình\nxác thực',
                          style: StartupOnboardingTheme.darkTheme.textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildSelectionCard(
                        0,
                        Icons.business_rounded,
                        'Startup đã có pháp nhân',
                        'Dành cho doanh nghiệp đã đăng ký kinh doanh chính thức, có mã số thuế.',
                      ),
                      const SizedBox(height: 24),
                      _buildSelectionCard(
                        1,
                        Icons.emoji_objects_rounded,
                        'Startup chưa có pháp nhân',
                        'Dành cho dự án mới, nhóm nghiên cứu hoặc Lab-to-Market đang phát triển.',
                      ),
                    ],
                  ),
                ),
              ),
              FadeInUp(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedIndex != null ? _onContinue : null,
                      child: const Text('Tiếp tục'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(int index, IconData icon, String title, String description) {
    bool isSelected = _selectedIndex == index;
    return FadeInLeft(
      delay: Duration(milliseconds: 100 * (index + 1)),
      child: InkWell(
        onTap: () => _onTypeSelected(index),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected ? StartupOnboardingTheme.goldAccent.withOpacity(0.08) : StartupOnboardingTheme.navySurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.goldAccent.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: StartupOnboardingTheme.goldAccent.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ] : [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? StartupOnboardingTheme.goldAccent : StartupOnboardingTheme.navyBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? StartupOnboardingTheme.navyBg : StartupOnboardingTheme.goldAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.workSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: StartupOnboardingTheme.softIvory,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        color: StartupOnboardingTheme.slateGray.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: StartupOnboardingTheme.goldAccent,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
