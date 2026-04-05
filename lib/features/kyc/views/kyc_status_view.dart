import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aisep_capstone_mobile/core/theme/startup_onboarding_theme.dart';

class KycStatusView extends StatelessWidget {
  const KycStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: StartupOnboardingTheme.goldAccent.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: StartupOnboardingTheme.goldAccent.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    size: 80,
                    color: StartupOnboardingTheme.goldAccent,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  'Đang xét duyệt hồ sơ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Hồ sơ xác thực của bạn hiện đang được các chuyên gia AISEP đánh giá. Quy trình này thường mất từ 1-3 ngày làm việc.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: StartupOnboardingTheme.goldAccent, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Chúng tôi sẽ gửi thông báo đến bạn ngay khi có kết quả.',
                          style: TextStyle(
                            color: StartupOnboardingTheme.goldAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return to Dashboard / Home
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Quay về trang chủ'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
