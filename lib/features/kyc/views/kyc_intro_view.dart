import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';
import 'kyc_type_selection_view.dart';

class KycIntroView extends StatelessWidget {
  const KycIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
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
                    children: [
                      const SizedBox(height: 24),
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            size: 80,
                            color: StartupOnboardingTheme.goldAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeInDown(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Xác thực Startup\ncủa bạn',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'Xác thực danh tính giúp tăng mức độ tin cậy và mở khóa toàn bộ tính năng hỗ trợ AI cho doanh nghiệp của bạn.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 48),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            _buildBenefitRow(Icons.check_circle_outline_rounded, 'Huy hiệu "Xác thực" trên hồ sơ công khai.'),
                            _buildBenefitRow(Icons.check_circle_outline_rounded, 'Ưu tiên kết nối trực tiếp với Nhà đầu tư.'),
                            _buildBenefitRow(Icons.check_circle_outline_rounded, 'Chạy bộ đánh giá AI (AI Analysis) chuyên sâu.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const KycTypeSelectionView()),
                        );
                      },
                      child: const Text('Bắt đầu ngay'),
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

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: StartupOnboardingTheme.goldAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.workSans(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
