import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aisep_capstone_mobile/core/view_models/base_view_model.dart';
import 'package:aisep_capstone_mobile/features/onboarding/models/onboarding_page_model.dart';
import 'package:aisep_capstone_mobile/features/auth/views/startup_registration_view.dart';

class OnboardingViewModel extends BaseViewModel {
  final PageController pageController = PageController();
  final _storage = const FlutterSecureStorage();
  int currentPage = 0;

  final List<OnboardingPageModel> pages = const [
    OnboardingPageModel(
      title: 'Chào mừng đến với AISEP',
      description: 'Nền tảng đồng hành cùng startup trên hành trình phát triển',
      imagePath: 'assets/onboarding/welcome.png',
    ),
    OnboardingPageModel(
      title: 'Xây dựng hồ sơ startup nổi bật',
      description: 'Thể hiện tầm nhìn, giai đoạn phát triển và đội ngũ một cách chuyên nghiệp.',
      imagePath: 'assets/onboarding/profile.png',
    ),
    OnboardingPageModel(
      title: 'Nhận đánh giá và insight từ AI',
      description: 'Tải pitch deck để nhận phân tích, chấm điểm và gợi ý cải thiện từ chuyên gia AI.',
      imagePath: 'assets/onboarding/ai_analysis.png',
    ),
    OnboardingPageModel(
      title: 'Kết nối đúng investor và advisor',
      description: 'Mở rộng cơ hội gặp gỡ nhà đầu tư và cố vấn phù hợp với startup của bạn.',
      imagePath: 'assets/onboarding/connection.png',
    ),
    OnboardingPageModel(
      title: 'Sẵn sàng bắt đầu?',
      description: 'Tạo tài khoản startup và bắt đầu hành trình trên AISEP ngay hôm nay.',
      imagePath: 'assets/onboarding/ready.png',
    ),
  ];

  void onPageChanged(int index) {
    currentPage = index;
    notifyListeners();
  }

  void next(BuildContext context) async {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark as seen
      await _storage.write(key: 'has_seen_onboarding', value: 'true');
      
      if (context.mounted) {
        // Final Navigation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const StartupRegistrationView(),
          ),
        );
      }
    }
  }

  void skip() {
    pageController.animateToPage(
      pages.length - 1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
